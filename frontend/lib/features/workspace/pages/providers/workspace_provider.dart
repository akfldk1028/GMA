import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/marker_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../../utils/note_storage_service.dart';
import '../../../content_bridge/stroke_render_service.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../../note_editor/pages/providers/note_editor_provider.dart';
import '../../../note_editor/pages/providers/note_provider.dart';
import '../../../scrapnote/providers/note_scrap_provider.dart';
import '../../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../../ocr/ocr_service.dart';
import '../../../ocr/pages/providers/ocr_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/models/scrapnote_canvas_model.dart';
import '../../../scrapnote/pages/providers/scrapnote_canvas_provider.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/scrap_annotation_provider.dart';
import '../../../scrapnote/providers/scrapnote_service_provider.dart';
import '../../../scrapnote/services/scrap_insertion_service.dart';
import '../../../scrapnote/utils/scrapnote_block_editor.dart';
import '../../../pdf_viewer/pages/providers/pdf_document_provider.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../../models/pdf_marker_model.dart';
import '../../models/workspace_state.dart';

part 'workspace_provider.g.dart';

/// Main workspace provider managing PDF-Note bidirectional linking
@Riverpod(keepAlive: true)
class WorkspaceProvider extends _$WorkspaceProvider {
  @override
  FutureOr<WorkspaceState> build() async {
    // Load panel sizes from Hive if available
    final box = await Hive.openBox('workspace_settings');
    final savedSizes = box.get('panel_sizes');

    final panelSizes = savedSizes != null
        ? PanelSizes.fromJson(Map<String, dynamic>.from(savedSizes as Map))
        : const PanelSizes();

    return WorkspaceState(
      panelSizes: panelSizes,
    );
  }

  /// Load a PDF file into the workspace.
  /// Also loads the document into pdfDocumentProvider for rendering.
  /// Auto-creates a linked note if no note is currently open.
  Future<void> loadPdf(String pdfPath) async {
    debugPrint('[WorkspaceProvider.loadPdf] pdfPath: $pdfPath');
    var currentState = state.valueOrNull;
    if (currentState == null) {
      try {
        currentState = await future;
      } catch (_) {
        currentState = const WorkspaceState();
        state = AsyncData(currentState);
      }
    }
    debugPrint('[WorkspaceProvider.loadPdf] currentNoteId: ${currentState.currentNoteId}, currentPdfPath: ${currentState.currentPdfPath}');

    final isAsset = pdfPath.startsWith('assets/');

    // Verify PDF file exists (skip for assets and web)
    if (!isAsset && !kIsWeb) {
      final file = File(pdfPath);
      if (!await file.exists()) {
        throw Exception('PDF file not found: $pdfPath');
      }
    }

    // Update open tabs list — add if not already open
    final openPdfs = List<String>.from(currentState.openPdfPaths);
    if (!openPdfs.contains(pdfPath)) {
      openPdfs.add(pdfPath);
    }

    // Clear markers from previous PDF
    state = AsyncData(
      currentState.copyWith(
        currentPdfPath: pdfPath,
        markers: [],
        openPdfPaths: openPdfs,
      ),
    );

    // Load the actual PDF document for rendering
    if (isAsset) {
      await ref.read(pdfDocumentProvider.notifier).loadFromAsset(pdfPath);
    } else {
      await ref.read(pdfDocumentProvider.notifier).loadFromFile(pdfPath);
    }

    // Register PDF in PdfRegistry for ScrapNote UUID tracking
    await ref.read(pdfRegistryProvProvider.notifier).register(pdfPath);

    // Auto-create a linked note if none is currently open (skip on web for assets)
    if (currentState.currentNoteId == null && !isAsset) {
      debugPrint('[WorkspaceProvider.loadPdf] no note open, auto-creating for: $pdfPath');
      await _autoCreateNote(pdfPath);
    }

    // On web with asset PDF, create virtual note ID for UI (capture button needs noteId)
    if (isAsset && state.valueOrNull?.currentNoteId == null) {
      final virtualNoteId = 'web-sample-${DateTime.now().millisecondsSinceEpoch}';
      state = AsyncData(state.value!.copyWith(currentNoteId: virtualNoteId));
    }
  }

  /// Switch to an already-open PDF tab.
  Future<void> switchPdfTab(String pdfPath) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (currentState.currentPdfPath == pdfPath) return;
    await loadPdf(pdfPath);
  }

  /// Close a PDF tab. If it's the active tab, switch to adjacent tab.
  void closePdfTab(String pdfPath) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final openPdfs = List<String>.from(currentState.openPdfPaths);
    final idx = openPdfs.indexOf(pdfPath);
    if (idx == -1) return;

    openPdfs.removeAt(idx);

    // If closing the active tab, switch to an adjacent one
    if (currentState.currentPdfPath == pdfPath) {
      if (openPdfs.isEmpty) {
        state = AsyncData(currentState.copyWith(
          currentPdfPath: null,
          openPdfPaths: [],
          markers: [],
        ));
      } else {
        final newIdx = idx.clamp(0, openPdfs.length - 1);
        state = AsyncData(currentState.copyWith(
          openPdfPaths: openPdfs,
        ));
        // Load the new active PDF
        loadPdf(openPdfs[newIdx]);
      }
    } else {
      state = AsyncData(currentState.copyWith(openPdfPaths: openPdfs));
    }
  }

  /// Load a note into the workspace
  /// Optionally loads the note content from filesystem if available
  Future<String?> loadNote(String noteId) async {
    debugPrint('[WorkspaceProvider.loadNote] noteId: $noteId');
    var currentState = state.valueOrNull;
    if (currentState == null) {
      try {
        currentState = await future;
      } catch (_) {
        currentState = const WorkspaceState();
        state = AsyncData(currentState);
      }
    }
    debugPrint('[WorkspaceProvider.loadNote] previousNoteId: ${currentState.currentNoteId}');

    // Update workspace state with current note ID
    state = AsyncData(
      currentState.copyWith(currentNoteId: noteId),
    );

    // Load note content from filesystem using NoteStorageService
    final noteStorage = ref.read(noteStorageServiceProvider);
    final content = await noteStorage.loadNote(noteId: noteId);
    debugPrint('[WorkspaceProvider.loadNote] loaded content length: ${content?.length ?? 0}');

    // Ensure ::: scrapnote block exists in loaded note
    var latestContent = content;
    if (content != null && !ScrapnoteBlockEditor.hasBlock(content)) {
      debugPrint('[WorkspaceProvider.loadNote] adding ::: scrapnote block to existing note');
      latestContent = ScrapnoteBlockEditor.ensureBlock(content);
      await noteStorage.saveNoteImmediate(noteId: noteId, content: latestContent!);
    }

    // Backfill: sync existing Hive elements into ::: scrapnote block
    await syncElementsToBlock(noteId);

    return latestContent;
  }

  /// Sync existing Hive elements into the ::: scrapnote block of a note.
  ///
  /// Reads the note from disk, looks up all elements for the current PDF,
  /// and appends any missing @el references to the block. No-op if all
  /// elements are already referenced.
  Future<void> syncElementsToBlock(String noteId) async {
    final noteStorage = ref.read(noteStorageServiceProvider);
    final content = await noteStorage.loadNote(noteId: noteId);
    if (content == null || content.isEmpty) return;

    // Need current PDF to find elements
    final currentState = state.valueOrNull;
    final pdfPath = currentState?.currentPdfPath;
    if (pdfPath == null) return;

    final pdfId = ref.read(pdfRegistryProvProvider.notifier).getIdByPath(pdfPath);
    if (pdfId == null) return;

    // Get all elements for this PDF from Hive
    final elements = ref.read(elementStoreProvider.notifier).getByPdfId(pdfId);
    if (elements.isEmpty) return;

    // Get IDs already in the block
    final existingIds = ScrapnoteBlockEditor.getElementIds(content).toSet();

    // Find missing elements
    final missingElements = elements.where((e) => !existingIds.contains(e.id)).toList();
    if (missingElements.isEmpty) {
      debugPrint('[syncElementsToBlock] all ${elements.length} elements already in block');
      return;
    }

    // Append missing elements to block
    var updated = content;
    for (final el in missingElements) {
      updated = ScrapnoteBlockEditor.appendElement(updated, el.id);
    }

    // Save to disk
    await noteStorage.saveNoteImmediate(noteId: noteId, content: updated);
    debugPrint('[syncElementsToBlock] backfilled ${missingElements.length} elements into block');

    // Immediately update controller text so noteScrapProvider sees @el IDs
    // on its next synchronous rebuild (invalidate alone is async and too late)
    final controller = ref.read(noteEditorProvider(noteId));
    if (controller != null && controller.text != updated) {
      controller.text = updated;
    }
    // Also invalidate noteStateProvider to keep disk↔provider in sync
    ref.invalidate(noteStateProvider(noteId));
  }

  /// Append a single element ID to the note's ::: scrapnote block.
  /// Used by the import dialog to add cross-PDF scraps.
  Future<void> appendElementToBlock(String noteId, String elementId) async {
    final noteStorage = ref.read(noteStorageServiceProvider);
    final content = await noteStorage.loadNote(noteId: noteId);
    if (content == null) return;

    final updated = ScrapnoteBlockEditor.appendElement(content, elementId);
    await noteStorage.saveNoteImmediate(noteId: noteId, content: updated);

    // Update live controller if available
    final controller = ref.read(noteEditorProvider(noteId));
    if (controller != null && controller.text != updated) {
      controller.text = updated;
    }
    ref.invalidate(noteStateProvider(noteId));
  }

  /// Auto-create a note linked to the given PDF. Returns the note ID or null.
  /// Directly creates file instead of using CreateNoteMutation to avoid
  /// Riverpod "Future already completed" bug.
  Future<String?> _autoCreateNote(String pdfPath) async {
    debugPrint('[WorkspaceProvider._autoCreateNote] pdfPath: $pdfPath');
    try {
      final pdfName = p.basenameWithoutExtension(pdfPath);
      final notesDir = await ref.read(notesRootDirectoryProvider.future);
      final noteUuid = const Uuid().v4();
      final noteFile = File('${notesDir.path}/$noteUuid.md');

      // Write frontmatter + initial content with scrapnote block
      final now = DateTime.now();
      final content = StringBuffer()
        ..writeln('---')
        ..writeln('title: $pdfName')
        ..writeln('linkedPdfPath: $pdfPath')
        ..writeln('createdAt: ${now.toIso8601String()}')
        ..writeln('modifiedAt: ${now.toIso8601String()}')
        ..writeln('---')
        ..writeln()
        ..writeln('# $pdfName')
        ..writeln()
        ..writeln('::: scrapnote Scraps')
        ..writeln(':::')
        ..writeln();
      await noteFile.writeAsString(content.toString());

      // Load the note into workspace and refresh file manager
      debugPrint('[WorkspaceProvider._autoCreateNote] created noteUuid: $noteUuid, loading...');
      await loadNote(noteUuid);
      debugPrint('[WorkspaceProvider._autoCreateNote] refreshing fileManager');
      ref.read(fileManagerProvider.notifier).refresh();
      return noteUuid;
    } catch (e) {
      debugPrint('[WorkspaceProvider._autoCreateNote] FAILED: $e');
      return null;
    }
  }

  /// Update note content with auto-save (debounced)
  /// This should be called when the user types in the note editor
  Future<void> updateNoteContent({
    required String noteId,
    required String content,
  }) async {
    // Validate noteId
    if (noteId.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }

    // Trigger auto-save with debouncing via NoteStorageService
    final noteStorage = ref.read(noteStorageServiceProvider);
    await noteStorage.saveNote(
      noteId: noteId,
      content: content,
    );
  }

  /// Save note content immediately without debouncing
  /// Use this for explicit save operations (e.g., user clicks Save button)
  Future<void> saveNoteImmediate({
    required String noteId,
    required String content,
  }) async {
    // Validate noteId
    if (noteId.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }

    // Save immediately without debouncing
    final noteStorage = ref.read(noteStorageServiceProvider);
    await noteStorage.saveNoteImmediate(
      noteId: noteId,
      content: content,
    );
  }

  /// Toggle sidebar mode between fileBrowser and elementNavigator
  void toggleSidebarMode() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newMode = currentState.sidebarMode == SidebarMode.fileBrowser
        ? SidebarMode.elementNavigator
        : SidebarMode.fileBrowser;

    state = AsyncData(
      currentState.copyWith(sidebarMode: newMode),
    );
  }

  /// Toggle sticky note visibility
  void toggleStickyNote() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isStickyNoteVisible: !s.isStickyNoteVisible));
  }

  /// Toggle the left page navigation panel
  void togglePageNav() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isPageNavOpen: !s.isPageNavOpen));
  }

  /// Toggle the right live scraps panel
  void toggleLiveScraps() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isLiveScrapsOpen: !s.isLiveScrapsOpen));
  }

  /// Navigate to an element by ID.
  /// Looks up the element from ElementStore, gets the PDF path from PdfRegistry,
  /// loads the PDF if it's different from the current one, and returns the page number
  /// for the caller to navigate to using goToPage().
  ///
  /// Returns the page number to navigate to, or null if element not found.
  Future<int?> navigateToElement(String elementId) async {
    try {
      final element = ref.read(elementStoreProvider.notifier).getById(elementId);
      if (element == null) {
        debugPrint('Element not found: $elementId');
        return null;
      }

      // Ensure registry is initialized before lookup
      await ref.read(pdfRegistryProvProvider.notifier).ensureReady();
      final pdfPath = ref.read(pdfRegistryProvProvider.notifier).getPathById(element.pdfId);
      if (pdfPath == null) {
        debugPrint('PDF path not found for pdfId: ${element.pdfId}');
        return null;
      }

      final currentState = state.valueOrNull;
      if (currentState == null) return null;

      // Load PDF if it's different from the current one
      if (currentState.currentPdfPath != pdfPath) {
        await loadPdf(pdfPath);
      }

      return element.pageNumber;
    } catch (e) {
      debugPrint('Failed to navigate to element $elementId: $e');
      return null;
    }
  }

  /// Create a marker from PDF text selection
  /// This is called when user selects text in PDF viewer
  Future<PdfMarker> createMarker({
    required int pageNumber,
    required MarkerColor color,
    String? selectedText,
    PdfRect? textRect,
    String? capturedImagePath,
    ElementType? elementTypeOverride,
  }) async {
    debugPrint('[WorkspaceProvider.createMarker] page: $pageNumber, color: ${color.name}, text: ${selectedText != null ? selectedText.substring(0, selectedText.length.clamp(0, 50)) : null}, hasImage: ${capturedImagePath != null}');
    final currentState = state.valueOrNull;
    if (currentState == null) {
      throw Exception('Workspace state not initialized');
    }

    // Validate page number is positive
    if (pageNumber <= 0) {
      throw ArgumentError('Invalid page number: $pageNumber');
    }

    // Create new marker with unique ID
    const uuid = Uuid();
    final marker = PdfMarker(
      id: uuid.v4(),
      pageNumber: pageNumber,
      color: color,
      selectedText: selectedText,
      textRect: textRect,
      capturedImagePath: capturedImagePath,
    );

    // Add marker to state
    final updatedMarkers = [...currentState.markers, marker];
    state = AsyncData(
      currentState.copyWith(markers: updatedMarkers),
    );

    // Insert marker into note editor. Auto-create note if none is open.
    var currentNoteId = state.valueOrNull?.currentNoteId;
    debugPrint('[WorkspaceProvider.createMarker] currentNoteId: $currentNoteId, currentPdfPath: ${currentState.currentPdfPath}');
    if (currentNoteId == null && currentState.currentPdfPath != null) {
      debugPrint('[WorkspaceProvider.createMarker] no note open, auto-creating...');
      currentNoteId = await _autoCreateNote(currentState.currentPdfPath!);
      debugPrint('[WorkspaceProvider.createMarker] auto-created noteId: $currentNoteId');
    }
    if (currentNoteId != null) {
      if (capturedImagePath != null) {
        // Area capture → insert image markdown with absolute path + context text
        final capturesDir = await ref.read(capturesDirectoryProvider.future);
        await ref
            .read(noteEditorProvider(currentNoteId).notifier)
            .insertCapture(
              pageNumber: pageNumber,
              filename: capturedImagePath,
              capturesDir: capturesDir.path,
              contextText: selectedText,
            );
      } else {
        // Text selection or drawing stroke → insert marker line
        await ref
            .read(noteEditorProvider(currentNoteId).notifier)
            .insertMarker(
              color: color,
              pageNumber: pageNumber,
              text: selectedText ?? '',
            );
      }
    }

    // Create ScrapElement alongside the marker for ScrapNote system
    if (currentState.currentPdfPath != null) {
      try {
        final pdfId = await ref
            .read(pdfRegistryProvProvider.notifier)
            .register(currentState.currentPdfPath!);

        final ElementType elementType;
        if (elementTypeOverride != null) {
          elementType = elementTypeOverride;
        } else if (capturedImagePath != null) {
          elementType = ElementType.capture;
        } else if (color == MarkerColor.pen) {
          elementType = ElementType.drawing;
        } else {
          elementType = ElementType.highlight;
        }

        final element = ScrapElement(
          id: marker.id,
          pdfId: pdfId,
          pageNumber: pageNumber,
          type: elementType,
          rect: textRect,
          selectedText: selectedText,
          imagePath: capturedImagePath,
          createdAt: DateTime.now(),
        );

        ref.read(elementStoreProvider.notifier).add(element);

        // Append @el reference to the ::: scrapnote block.
        // Prefer controller text (has unsaved insertMarker changes),
        // fall back to disk when controller is null (editor not yet built).
        if (currentNoteId != null) {
          final controller = ref.read(noteEditorProvider(currentNoteId));
          final baseContent = controller?.text;

          if (baseContent != null && baseContent.isNotEmpty) {
            // Controller available — append to live text, save, notify chain
            final updatedContent = ScrapnoteBlockEditor.appendElement(
              baseContent,
              element.id,
            );
            controller!.text = updatedContent;
            await ref
                .read(noteEditorProvider(currentNoteId).notifier)
                .saveContent(currentNoteId);
          } else {
            // No controller — disk-based fallback
            final noteStorage = ref.read(noteStorageServiceProvider);
            final diskContent =
                await noteStorage.loadNote(noteId: currentNoteId);
            if (diskContent != null && diskContent.isNotEmpty) {
              final updatedContent = ScrapnoteBlockEditor.appendElement(
                diskContent,
                element.id,
              );
              await noteStorage.saveNoteImmediate(
                noteId: currentNoteId,
                content: updatedContent,
              );
              ref.invalidate(noteStateProvider(currentNoteId));
            }
          }
        }

        // Also create CanvasElement on the scrapnote canvas
        try {
          final service = await ref.read(scrapnoteServiceProvProvider.future);
          final scrapnoteId = await service.getOrCreateScrapnote(
            currentState.currentPdfPath!,
          );

          // Get existing elements for auto-positioning
          final canvasData = ref
              .read(scrapnoteCanvasStateProvider(scrapnoteId))
              .valueOrNull;
          final existingElements = canvasData?.elements ?? [];
          final pos = ScrapInsertionService.calculateAutoPosition(
            existingElements,
          );

          final canvasElement = CanvasElement(
            id: marker.id,
            type: capturedImagePath != null
                ? CanvasElementType.capture
                : CanvasElementType.highlight,
            x: pos.x,
            y: pos.y,
            width: capturedImagePath != null ? 400 : 500,
            height: capturedImagePath != null ? 300 : 80,
            imagePath: capturedImagePath,
            selectedText: selectedText,
            colorValue: color.color.toARGB32(),
            sourcePageNumber: pageNumber,
            sourcePdfPath: currentState.currentPdfPath,
            createdAt: DateTime.now(),
          );

          ref
              .read(scrapnoteCanvasStateProvider(scrapnoteId).notifier)
              .addElement(canvasElement);
        } catch (e) {
          debugPrint('Failed to create CanvasElement: $e');
        }
      } catch (e) {
        debugPrint('Failed to create ScrapElement: $e');
      }
    }

    return marker;
  }

  /// Create a drawing marker for a pen/highlighter stroke.
  ///
  /// Each stroke gets its own marker line — even on the same page,
  /// because stroke location matters. [extractedText] is the PDF text
  /// near the stroke's bounding box (auto-extracted).
  ///
  /// When [strokes] is provided, renders them to PNG and inserts as image.
  /// Falls back to text marker if rendering fails.
  Future<void> createDrawingMarker({
    required int pageNumber,
    String? extractedText,
    PdfRect? textRect,
    List<DrawingStroke>? strokes,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    if (currentState.currentNoteId == null) return;

    // Render strokes to PNG if provided
    String? imagePath;
    if (strokes != null && strokes.isNotEmpty) {
      try {
        final capturesDir = await ref.read(capturesDirectoryProvider.future);
        imagePath = await StrokeRenderService.renderStrokes(
          strokes: strokes,
          capturesDir: capturesDir.path,
          pageNumber: pageNumber,
        );
      } catch (e) {
        debugPrint('Stroke render failed, fallback to text marker: $e');
      }
    }

    await createMarker(
      pageNumber: pageNumber,
      color: MarkerColor.pen,
      selectedText: extractedText,
      textRect: textRect,
      capturedImagePath: imagePath,
      elementTypeOverride: ElementType.drawing,
    );
  }

  /// Run OCR on a full PDF page and insert result as marker/text.
  ///
  /// Requires a [PdfViewerController] to access the document pages.
  /// The extracted text is inserted as a marker in the current note.
  Future<void> ocrCurrentPage({
    required int pageNumber,
    required PdfViewerController controller,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final ocrSettings = await ref.read(ocrSettingsProvider.future);
    if (!ocrSettings.isEnabled) return;

    final text = await controller.useDocument<String?>((document) async {
      if (pageNumber < 1 || pageNumber > document.pages.length) return null;
      final page = document.pages[pageNumber - 1];
      return OcrService.recognizePage(
        page,
        pageNumber,
        backendId: ocrSettings.backendId,
        baseUrl: ocrSettings.ollamaUrl,
        model: ocrSettings.modelName,
      );
    });

    if (text != null && text.trim().isNotEmpty) {
      await createMarker(
        pageNumber: pageNumber,
        color: MarkerColor.blue,
        selectedText: text,
      );
    }
  }

  /// Navigate PDF viewer to a specific marker
  /// Returns the marker if found, null if marker ID is invalid
  Future<PdfMarker?> navigateToMarker(String markerId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    // Find marker by ID
    try {
      final marker = currentState.markers.firstWhere(
        (m) => m.id == markerId,
      );

      // Validate page number is within reasonable bounds
      if (marker.pageNumber <= 0) {
        throw ArgumentError(
          'Invalid page number in marker: ${marker.pageNumber}',
        );
      }

      return marker;
    } catch (e) {
      // Marker not found or invalid
      return null;
    }
  }

  /// Save panel sizes to persistent storage
  Future<void> savePanelSizes(PanelSizes sizes) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Validate panel sizes sum to approximately 1.0 (allowing small float precision errors)
    final sum = sizes.left + sizes.center + sizes.right;
    if ((sum - 1.0).abs() > 0.01) {
      throw ArgumentError(
        'Panel sizes must sum to 1.0, got: $sum',
      );
    }

    // Validate all sizes are positive
    if (sizes.left <= 0 || sizes.center <= 0 || sizes.right <= 0) {
      throw ArgumentError('All panel sizes must be positive');
    }

    // Update state
    state = AsyncData(
      currentState.copyWith(panelSizes: sizes),
    );

    // Persist to Hive
    final box = await Hive.openBox('workspace_settings');
    await box.put('panel_sizes', sizes.toJson());
  }

  // ─── Scrap element operations ────────────────────────────

  /// Remove a scrap element from the note and all associated data.
  Future<void> removeScrapElement(String noteId, String elementId) async {
    final noteStorage = ref.read(noteStorageServiceProvider);
    final controller = ref.read(noteEditorProvider(noteId));

    // 1. Remove @el from markdown
    final content = controller?.text ??
        await noteStorage.loadNote(noteId: noteId) ??
        '';
    if (content.isNotEmpty) {
      final updated = ScrapnoteBlockEditor.removeElement(content, elementId);
      if (controller != null) {
        controller.text = updated;
      }
      await noteStorage.saveNoteImmediate(noteId: noteId, content: updated);
    }

    // 2. Delete element from Hive store
    final element = ref.read(elementStoreProvider.notifier).getById(elementId);
    ref.read(elementStoreProvider.notifier).delete(elementId);

    // 3. Clear annotation strokes
    ref.read(scrapAnnotationStoreProvider.notifier).clearStrokes(elementId);

    // 4. Delete image file if exists
    if (element?.imagePath != null && element!.imagePath!.isNotEmpty && !kIsWeb) {
      try {
        final capturesDir = await ref.read(capturesDirectoryProvider.future);
        final imgPath = p.isAbsolute(element.imagePath!)
            ? element.imagePath!
            : p.join(capturesDir.path, element.imagePath!);
        final file = File(imgPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('[removeScrapElement] failed to delete image: $e');
      }
    }

    // 5. Invalidate providers
    ref.invalidate(noteStateProvider(noteId));
  }

  /// Reorder scraps within the note's scrapnote block.
  ///
  /// [oldIndex] and [newIndex] are indices into the filtered capture/lasso list
  /// (as shown in the UI), not the full @el list in the block.
  Future<void> reorderScraps(String noteId, int oldIndex, int newIndex) async {
    final noteStorage = ref.read(noteStorageServiceProvider);
    final controller = ref.read(noteEditorProvider(noteId));

    final content = controller?.text ??
        await noteStorage.loadNote(noteId: noteId) ??
        '';
    if (content.isEmpty) return;

    // Get ALL element IDs from the block (includes highlight/drawing)
    final allIds = ScrapnoteBlockEditor.getElementIds(content);
    if (allIds.isEmpty) return;

    // Filter to capture/lasso only (matching noteScrapProvider logic)
    final elementStore = ref.read(elementStoreProvider.notifier);
    final captureIds = <String>[];
    for (final id in allIds) {
      final el = elementStore.getById(id);
      if (el != null &&
          (el.type == ElementType.capture || el.type == ElementType.lasso)) {
        captureIds.add(id);
      }
    }
    if (captureIds.isEmpty || oldIndex >= captureIds.length) return;

    // Perform reorder on the filtered ID list
    final movedId = captureIds.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    captureIds.insert(insertAt.clamp(0, captureIds.length), movedId);

    // Rebuild full ID list: non-capture IDs stay in original positions,
    // capture IDs replaced in new order.
    int captureIdx = 0;
    final reorderedIds = <String>[];
    for (final id in allIds) {
      final el = elementStore.getById(id);
      if (el != null &&
          (el.type == ElementType.capture || el.type == ElementType.lasso)) {
        reorderedIds.add(captureIds[captureIdx++]);
      } else {
        reorderedIds.add(id);
      }
    }

    // Rewrite block with new order
    final updated =
        ScrapnoteBlockEditor.reorderElements(content, null, reorderedIds);
    if (controller != null) {
      controller.text = updated;
    }
    await noteStorage.saveNoteImmediate(noteId: noteId, content: updated);
    ref.invalidate(noteStateProvider(noteId));
  }

  /// Reorder ALL capture/lasso elements to match a given ID order.
  /// Used by canvas panel to sync 2D layout positions to markdown order.
  Future<void> reorderAllScraps(String noteId, List<String> orderedCaptureIds) async {
    final noteStorage = ref.read(noteStorageServiceProvider);
    final controller = ref.read(noteEditorProvider(noteId));

    final content = controller?.text ??
        await noteStorage.loadNote(noteId: noteId) ??
        '';
    if (content.isEmpty) return;

    final allIds = ScrapnoteBlockEditor.getElementIds(content);
    if (allIds.isEmpty) return;

    final elementStore = ref.read(elementStoreProvider.notifier);
    final orderedSet = orderedCaptureIds.toSet();

    // Rebuild full ID list: replace capture/lasso IDs with orderedCaptureIds
    int captureIdx = 0;
    final reorderedIds = <String>[];
    for (final id in allIds) {
      final el = elementStore.getById(id);
      if (el != null &&
          (el.type == ElementType.capture || el.type == ElementType.lasso) &&
          orderedSet.contains(id)) {
        if (captureIdx < orderedCaptureIds.length) {
          reorderedIds.add(orderedCaptureIds[captureIdx++]);
        } else {
          reorderedIds.add(id);
        }
      } else {
        reorderedIds.add(id);
      }
    }

    final updated =
        ScrapnoteBlockEditor.reorderElements(content, null, reorderedIds);
    if (controller != null) {
      controller.text = updated;
    }
    await noteStorage.saveNoteImmediate(noteId: noteId, content: updated);
    ref.invalidate(noteStateProvider(noteId));
    // Wait for note state to rebuild, then force scrap provider refresh
    await ref.read(noteStateProvider(noteId).future);
    ref.invalidate(noteScrapProvider(noteId));
  }

  // ─── Layout control ─────────────────────────────────────

  /// Set which panel is focused (determines size ratio)
  void setFocusedPanel(FocusedPanel panel) {
    debugPrint('[WorkspaceProvider.setFocusedPanel] panel: ${panel.name}');
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(focusedPanel: panel));
  }

  /// Swap PDF and ScrapNote positions (left↔right)
  void swapLayout() {
    debugPrint('[WorkspaceProvider.swapLayout] current isLayoutSwapped: ${state.valueOrNull?.isLayoutSwapped}');
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isLayoutSwapped: !s.isLayoutSwapped));
  }

  // ─── Modal / Drawer control ──────────────────────────────

  /// Open the markdown editor modal
  void openEditorModal() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isEditorModalOpen: true));
  }

  /// Close the markdown editor modal
  void closeEditorModal() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isEditorModalOpen: false));
  }

  /// Toggle the file browser drawer
  void toggleFileBrowser() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isFileBrowserOpen: !s.isFileBrowserOpen));
  }

  /// Close the file browser drawer
  void closeFileBrowser() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isFileBrowserOpen: false));
  }

  /// Toggle quick scrap mode (skip popup, create instantly)
  void toggleQuickScrapMode() {
    debugPrint('[WorkspaceProvider.toggleQuickScrapMode] current: ${state.valueOrNull?.isQuickScrapMode}');
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isQuickScrapMode: !s.isQuickScrapMode));
  }

  // ─── Scrap selection control ─────────────────────────────

  /// Toggle selection of a scrap element
  void toggleScrapSelection(String elementId) {
    debugPrint('[WorkspaceProvider.toggleScrapSelection] elementId: $elementId');
    final s = state.valueOrNull;
    if (s == null) return;
    final ids = Set<String>.from(s.selectedScrapIds);
    if (ids.contains(elementId)) {
      ids.remove(elementId);
      debugPrint('[WorkspaceProvider.toggleScrapSelection] removed, count: ${ids.length}');
    } else {
      ids.add(elementId);
      debugPrint('[WorkspaceProvider.toggleScrapSelection] added, count: ${ids.length}');
    }
    state = AsyncData(s.copyWith(selectedScrapIds: ids));
  }

  /// Clear all scrap selections
  void clearScrapSelection() {
    debugPrint('[WorkspaceProvider.clearScrapSelection] clearing ${state.valueOrNull?.selectedScrapIds.length ?? 0} selections');
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(selectedScrapIds: {}));
  }

  /// Select specific scrap IDs
  void setScrapSelection(Set<String> ids) {
    debugPrint('[WorkspaceProvider.setScrapSelection] ids: ${ids.length}');
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(selectedScrapIds: ids));
  }

  // ─── Scrap Board Popup control ──────────────────────────

  /// Open the scrap board popup after capture/highlight
  void openScrapBoard({
    required int pageNumber,
    String? selectedText,
    String? imagePath,
    PdfRect? textRect,
    ElementType? elementType,
  }) {
    debugPrint('[WorkspaceProvider.openScrapBoard] page: $pageNumber, text: ${selectedText != null ? selectedText.substring(0, selectedText.length.clamp(0, 50)) : null}, hasImage: ${imagePath != null}, type: ${elementType?.name}');
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      isScrapBoardOpen: true,
      pendingScrapPageNumber: pageNumber,
      pendingScrapText: selectedText,
      pendingScrapImagePath: imagePath,
      pendingScrapTextRect: textRect,
      pendingScrapElementType: elementType,
    ));
  }

  /// Close the scrap board popup
  void closeScrapBoard() {
    debugPrint('[WorkspaceProvider.closeScrapBoard] closing');
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      isScrapBoardOpen: false,
      pendingScrapPageNumber: null,
      pendingScrapText: null,
      pendingScrapImagePath: null,
      pendingScrapTextRect: null,
      pendingScrapElementType: null,
    ));
  }

  /// Open the marker edit modal for a new marker from text selection
  void openMarkerEditModal({
    required int pageNumber,
    String? selectedText,
    PdfRect? textRect,
  }) {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      isMarkerEditModalOpen: true,
      editingMarkerId: null,
      pendingMarkerPageNumber: pageNumber,
      pendingMarkerText: selectedText,
      pendingMarkerTextRect: textRect,
    ));
  }

  /// Open the marker edit modal for editing an existing marker
  void editMarker(String markerId) {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      isMarkerEditModalOpen: true,
      editingMarkerId: markerId,
    ));
  }

  /// Close the marker edit modal
  void closeMarkerEditModal() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      isMarkerEditModalOpen: false,
      editingMarkerId: null,
      pendingMarkerPageNumber: null,
      pendingMarkerText: null,
      pendingMarkerTextRect: null,
    ));
  }

  /// Update an existing marker
  /// This is called when user edits a marker in the marker edit modal
  Future<void> updateMarker({
    required String markerId,
    required MarkerColor color,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      throw Exception('Workspace state not initialized');
    }

    // Find the marker by ID
    final markerIndex = currentState.markers.indexWhere((m) => m.id == markerId);
    if (markerIndex == -1) {
      throw ArgumentError('Marker not found: $markerId');
    }

    final existingMarker = currentState.markers[markerIndex];

    // Create updated marker with new color but same ID
    final updatedMarker = existingMarker.copyWith(color: color);

    // Update markers list using map for immutability
    final updatedMarkers = currentState.markers.map((m) {
      return m.id == markerId ? updatedMarker : m;
    }).toList();

    state = AsyncData(
      currentState.copyWith(markers: updatedMarkers),
    );
  }

  /// Remove a marker by ID
  Future<void> removeMarker(String markerId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedMarkers = currentState.markers
        .where((m) => m.id != markerId)
        .toList();

    state = AsyncData(
      currentState.copyWith(markers: updatedMarkers),
    );
  }

  /// Clear all markers
  Future<void> clearMarkers() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(markers: []),
    );
  }

  /// Reset workspace to initial state
  Future<void> reset() async {
    state = const AsyncData(WorkspaceState());
  }
}

/// Helper provider to check if a PDF is currently loaded
@riverpod
bool isPdfLoaded(Ref ref) {
  final workspaceState = ref.watch(workspaceProviderProvider);
  return workspaceState.valueOrNull?.currentPdfPath != null;
}

/// Helper provider to check if a note is currently loaded
@riverpod
bool isNoteLoaded(Ref ref) {
  final workspaceState = ref.watch(workspaceProviderProvider);
  return workspaceState.valueOrNull?.currentNoteId != null;
}

/// Helper provider to get current markers
@riverpod
List<PdfMarker> currentMarkers(Ref ref) {
  final workspaceState = ref.watch(workspaceProviderProvider);
  return workspaceState.valueOrNull?.markers ?? [];
}
