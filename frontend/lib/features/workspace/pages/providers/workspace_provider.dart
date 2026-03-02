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
import '../../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../../ocr/ocr_service.dart';
import '../../../ocr/pages/providers/ocr_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';
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
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Verify PDF file exists
    final file = File(pdfPath);
    if (!await file.exists()) {
      throw Exception('PDF file not found: $pdfPath');
    }

    // Clear markers from previous PDF
    state = AsyncData(
      currentState.copyWith(currentPdfPath: pdfPath, markers: []),
    );

    // Load the actual PDF document for rendering
    await ref.read(pdfDocumentProvider.notifier).loadFromFile(pdfPath);

    // Register PDF in PdfRegistry for ScrapNote UUID tracking
    await ref.read(pdfRegistryProvProvider.notifier).register(pdfPath);

    // Auto-create a linked note if none is currently open
    if (currentState.currentNoteId == null) {
      await _autoCreateNote(pdfPath);
    }
  }

  /// Load a note into the workspace
  /// Optionally loads the note content from filesystem if available
  Future<String?> loadNote(String noteId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    // Update workspace state with current note ID
    state = AsyncData(
      currentState.copyWith(currentNoteId: noteId),
    );

    // Load note content from filesystem using NoteStorageService
    final noteStorage = ref.read(noteStorageServiceProvider);
    final content = await noteStorage.loadNote(noteId: noteId);

    return content;
  }

  /// Auto-create a note linked to the given PDF. Returns the note ID or null.
  /// Directly creates file instead of using CreateNoteMutation to avoid
  /// Riverpod "Future already completed" bug.
  Future<String?> _autoCreateNote(String pdfPath) async {
    try {
      final pdfName = p.basenameWithoutExtension(pdfPath);
      final notesDir = await ref.read(notesRootDirectoryProvider.future);
      final noteUuid = const Uuid().v4();
      final noteFile = File('${notesDir.path}/$noteUuid.md');

      // Write frontmatter + initial content
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
        ..writeln();
      await noteFile.writeAsString(content.toString());

      // Load the note into workspace and refresh file manager
      await loadNote(noteUuid);
      ref.read(fileManagerProvider.notifier).refresh();
      return noteUuid;
    } catch (e) {
      debugPrint('Auto-create note failed: $e');
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
  }) async {
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
    if (currentNoteId == null && currentState.currentPdfPath != null) {
      currentNoteId = await _autoCreateNote(currentState.currentPdfPath!);
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
        if (capturedImagePath != null) {
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
