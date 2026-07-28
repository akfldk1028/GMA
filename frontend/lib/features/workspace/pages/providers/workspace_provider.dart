import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/marker_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../../utils/note_storage_service.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../../note_editor/pages/providers/note_editor_provider.dart';
import '../../../note_editor/pages/providers/note_provider.dart';
import '../../../pdf_structure/services/pdf_text_extraction_service.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/note_scrap_provider.dart';
import '../../../scrapnote/providers/scrap_annotation_provider.dart';
import '../../../scrapnote/utils/scrapnote_block_editor.dart';
import '../../../pdf_viewer/pages/providers/pdf_document_provider.dart';
import '../../../pdf_viewer/pages/providers/pdf_marker_provider.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../../../pdf_structure/providers/pdf_structure_provider.dart';
import '../../models/pdf_marker_model.dart';
import '../../services/marker_creation_service.dart';
import '../../services/workspace_persistence.dart';
import '../../models/workspace_state.dart';

part 'workspace_provider.g.dart';

/// Main workspace provider managing PDF-Note bidirectional linking
@Riverpod(keepAlive: true)
class WorkspaceProvider extends _$WorkspaceProvider {
  /// Guard: current loadNote operation ID (prevents re-entrant interleave)
  int _loadNoteGeneration = 0;

  @override
  FutureOr<WorkspaceState> build() async {
    // All persistence through WorkspacePersistence
    final savedSizes = await WorkspacePersistence.loadPanelSizes();
    final panelSizes = savedSizes != null
        ? PanelSizes.fromJson(savedSizes)
        : const PanelSizes();

    final session = await WorkspacePersistence.loadLastSession();

    // If user already called loadNote/resetForNewNote while we were awaiting,
    // don't override their state and don't schedule session restore.
    if (_loadNoteGeneration > 0) {
      final current = state.valueOrNull;
      // User already navigated while we were loading — preserve their state
      return current?.copyWith(panelSizes: panelSizes)
          ?? WorkspaceState(panelSizes: panelSizes);
    }

    final lastNoteId = session.noteId;
    final lastPdfPath = session.pdfPath;

    // Schedule async session restore after build (only when no user action).
    if (lastNoteId != null) {
      Future.microtask(() async {
        // Double-check: user might call loadNote between build return and microtask
        if (_loadNoteGeneration > 0) return;
        try {
          await loadNote(lastNoteId, linkedPdfPath: lastPdfPath);
        } catch (_) {}
      });
    }

    return WorkspaceState(panelSizes: panelSizes);
  }

  /// Reset workspace to clean state (new note without PDF).
  void resetForNewNote(String noteId) {
    // Bump generation so any pending session restore aborts
    _loadNoteGeneration++;
    final s = state.valueOrNull ?? const WorkspaceState();
    state = AsyncData(WorkspaceState(
      currentNoteId: noteId,
      panelSizes: s.panelSizes,
      // markers=[], openPdfPaths=[], currentPdfPath=null → clean slate
    ));
    // Clear last PDF so it doesn't auto-restore
    WorkspacePersistence.saveLastSession(noteId: noteId, pdfPath: '');
    // Clear cached PDF document so previous PDF doesn't show
    ref.read(pdfDocumentProvider.notifier).clearDocument();
    // Clear PDF structure cache
    ref.read(pdfStructureProvider.notifier).clear();
  }

  /// Load a PDF file into the workspace.
  /// Also loads the document into pdfDocumentProvider for rendering.
  /// Auto-creates a linked note if no note is currently open.
  Future<void> loadPdf(String pdfPath) async {
    // Capture generation to detect if another loadNote cancelled us
    final gen = _loadNoteGeneration;
    var currentState = state.valueOrNull;
    if (currentState == null) {
      try {
        currentState = await future;
      } catch (_) {
        currentState = const WorkspaceState();
        state = AsyncData(currentState);
      }
    }
    if (_loadNoteGeneration != gen) return; // cancelled

    final isAsset = pdfPath.startsWith('assets/');

    // Verify PDF file exists (skip for assets and web).
    // Missing file is treated as a soft failure: clear the persisted path
    // so a stale Hive entry from a cleared OS cache does not break the
    // session restore. Caller can re-pick the file via the file picker.
    if (!isAsset && !kIsWeb) {
      final file = File(pdfPath);
      if (!await file.exists()) {
        debugPrint('[loadPdf] PDF not found, clearing path: $pdfPath');
        final clearedState = (state.valueOrNull ?? const WorkspaceState())
            .copyWith(currentPdfPath: null);
        state = AsyncData(clearedState);
        await WorkspacePersistence.saveLastSession(
          noteId: clearedState.currentNoteId,
          pdfPath: '',
        );
        return;
      }
    }
    if (_loadNoteGeneration != gen) return; // cancelled

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

    // Persist note + PDF pair together
    final noteId = state.valueOrNull?.currentNoteId;
    await WorkspacePersistence.saveLastSession(
      noteId: noteId,
      pdfPath: pdfPath,
    );
    if (_loadNoteGeneration != gen) return; // cancelled

    // Load the actual PDF document for rendering
    if (isAsset) {
      await ref.read(pdfDocumentProvider.notifier).loadFromAsset(pdfPath);
    } else {
      await ref.read(pdfDocumentProvider.notifier).loadFromFile(pdfPath);
    }
    if (_loadNoteGeneration != gen) return; // cancelled

    // Register PDF in PdfRegistry for ScrapNote UUID tracking
    await ref.read(pdfRegistryProvProvider.notifier).register(pdfPath);
    if (_loadNoteGeneration != gen) return; // cancelled

    // Auto-create a linked note if none is currently open (skip on web for assets)
    if (currentState.currentNoteId == null && !isAsset) {
      // No note open — auto-create linked note
      await _autoCreateNote(pdfPath);
    } else if (!isAsset) {
      // Note already open — keep its frontmatter linkedPdfPath in sync.
      // This makes session restore reliable: next time we'll extract the
      // current path from frontmatter, not a stale cache path.
      final noteId = currentState.currentNoteId;
      if (noteId != null) {
        await _writeLinkedPdfPathToFrontmatter(noteId, pdfPath);
      }
    }

    // On web with asset PDF, create virtual note ID for UI (capture button needs noteId)
    if (isAsset && state.valueOrNull?.currentNoteId == null) {
      final virtualNoteId = 'web-sample-${DateTime.now().millisecondsSinceEpoch}';
      state = AsyncData(state.value!.copyWith(currentNoteId: virtualNoteId));
    }
  }

  /// Update or insert `linkedPdfPath` in the note's YAML frontmatter so the
  /// next session restore can find the PDF without relying on Hive caches.
  ///
  /// Operates on disk content directly — NOT on `noteEditorProvider`
  /// controller text — because note_provider strips frontmatter when
  /// constructing Note.content. Reading controller.text would return body
  /// only and writing it back would wipe the frontmatter.
  Future<void> _writeLinkedPdfPathToFrontmatter(
      String noteId, String pdfPath) async {
    try {
      final noteStorage = ref.read(noteStorageServiceProvider);
      final original = await noteStorage.loadNote(noteId: noteId);
      if (original == null || original.isEmpty) return;

      String updated;
      if (original.startsWith('---')) {
        // Has frontmatter — replace existing key or insert before closing ---
        final fmEnd = original.indexOf('\n---', 3);
        if (fmEnd < 0) return; // malformed; bail
        final fm = original.substring(4, fmEnd); // between opening --- and closing
        final body = original.substring(fmEnd + 4); // after \n---
        final keyRe = RegExp(r'^linkedPdfPath:.*$', multiLine: true);
        String newFm;
        if (keyRe.hasMatch(fm)) {
          newFm = fm.replaceFirst(keyRe, 'linkedPdfPath: $pdfPath');
        } else {
          newFm = '$fm\nlinkedPdfPath: $pdfPath';
        }
        updated = '---\n$newFm\n---$body';
      } else {
        // No frontmatter — prepend one
        final now = DateTime.now().toIso8601String();
        updated = '---\n'
            'linkedPdfPath: $pdfPath\n'
            'createdAt: $now\n'
            'modifiedAt: $now\n'
            '---\n\n$original';
      }
      if (updated == original) return;
      await noteStorage.saveNoteImmediate(noteId: noteId, content: updated);
      // Re-parse so noteStateProvider sees the updated frontmatter.
      ref.invalidate(noteStateProvider(noteId));
    } catch (e) {
      debugPrint('[_writeLinkedPdfPathToFrontmatter] failed: $e');
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
    ref.read(pdfDocumentProvider.notifier).evict(pdfPath);

    // If closing the active tab, switch to an adjacent one
    if (currentState.currentPdfPath == pdfPath) {
      if (openPdfs.isEmpty) {
        state = AsyncData(currentState.copyWith(
          currentPdfPath: null,
          openPdfPaths: [],
          markers: [],
        ));
        ref.read(pdfStructureProvider.notifier).clear();
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

  /// Load a note into the workspace.
  ///
  /// Handles PDF association: if the note has a linkedPdfPath in frontmatter,
  /// load that PDF. Otherwise clear the current PDF so stale state doesn't
  /// leak across notes.
  ///
  /// Pass [linkedPdfPath] if the caller already knows it (e.g. from
  /// NoteMetadata). Otherwise the method reads it from the note's frontmatter.
  Future<String?> loadNote(
    String noteId, {
    String? linkedPdfPath,
  }) async {
    // Re-entrance guard: bump generation so any in-flight loadNote bails out
    final generation = ++_loadNoteGeneration;
    var currentState = state.valueOrNull;
    if (currentState == null) {
      try {
        currentState = await future;
      } catch (_) {
        currentState = const WorkspaceState();
        state = AsyncData(currentState);
      }
    }
    // Update workspace state with current note ID and clear stale PDF
    ref.read(pdfDocumentProvider.notifier).clearDocument();
    state = AsyncData(
      currentState.copyWith(
        currentNoteId: noteId,
        currentPdfPath: null,
        openPdfPaths: [],
        markers: [],
      ),
    );

    // Persist session
    await WorkspacePersistence.saveLastSession(noteId: noteId, pdfPath: '');

    // Bail out if a newer loadNote was called while we awaited
    if (_loadNoteGeneration != generation) {
      // Superseded by a newer loadNote call
      return null;
    }

    // Load note content from filesystem using NoteStorageService
    final noteStorage = ref.read(noteStorageServiceProvider);
    final content = await noteStorage.loadNote(noteId: noteId);
    if (_loadNoteGeneration != generation) return null;

    // Ensure ::: scrapnote block exists in loaded note
    var latestContent = content;
    if (content != null && !ScrapnoteBlockEditor.hasBlock(content)) {
      latestContent = ScrapnoteBlockEditor.ensureBlock(content);
      await noteStorage.saveNoteImmediate(noteId: noteId, content: latestContent);
    }

    if (_loadNoteGeneration != generation) return null;

    // Refresh element store for the new note context
    ref.invalidate(elementStoreProvider);

    // Restore per-note scrap groups
    final groups = await WorkspacePersistence.loadGroups(noteId);
    final latestState = state.valueOrNull;
    if (latestState != null) {
      state = AsyncData(latestState.copyWith(scrapGroups: groups));
    }

    if (_loadNoteGeneration != generation) return null;

    // Resolve linked PDF: prefer frontmatter linkedPdfPath, fall back to
    // caller hint (e.g. last_pdf_path from session restore). Notes created
    // in older versions may have a frontmatter block without linkedPdfPath;
    // we still want to restore their PDF from the session record.
    String? pdfToLoad;
    if (content != null && content.startsWith('---')) {
      pdfToLoad = _extractLinkedPdfPath(content);
    }
    pdfToLoad ??= linkedPdfPath;
    if (pdfToLoad != null && pdfToLoad.isNotEmpty) {
      // Directly await PDF load (no more fragile microtask scheduling)
      await loadPdf(pdfToLoad);
    } else {
      ref.read(pdfStructureProvider.notifier).clear();
    }

    return latestContent;
  }

  /// Extract linkedPdfPath from note frontmatter content.
  static String? _extractLinkedPdfPath(String content) {
    final fmMatch = RegExp(r'^---\n([\s\S]*?)\n---').firstMatch(content);
    if (fmMatch == null) return null;
    final fm = fmMatch.group(1)!;
    final match = RegExp(r'^linkedPdfPath:\s*(.+)$', multiLine: true).firstMatch(fm);
    if (match == null) return null;
    final value = match.group(1)!.trim();
    return value.isNotEmpty ? value : null;
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

    // Use the note's own linkedPdfPath (from frontmatter), NOT state.currentPdfPath.
    // This prevents leaking elements from a previous session's PDF into a new note.
    final pdfPath = _extractLinkedPdfPath(content);
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
  /// Directly creates file and updates state instead of calling loadNote()
  /// to avoid recursive loop: _autoCreateNote → loadNote → loadPdf → _autoCreateNote.
  Future<String?> _autoCreateNote(String pdfPath) async {
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

      // Update state directly — do NOT call loadNote() to avoid recursion
      final s = state.valueOrNull;
      if (s != null) {
        state = AsyncData(s.copyWith(currentNoteId: noteUuid));
      }
      await WorkspacePersistence.saveLastSession(
        noteId: noteUuid,
        pdfPath: pdfPath,
      );
      ref.invalidate(fileManagerProvider);
      return noteUuid;
    } catch (e) {
      debugPrint('[WorkspaceProvider._autoCreateNote] error: $e');
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

  /// Toggle the AI agent panel
  void toggleAiPanel() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isAiPanelOpen: !s.isAiPanelOpen));
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

  /// Create a marker from PDF text selection.
  /// This is called when user selects text in PDF viewer.
  ///
  /// Heavy lifting delegated to [MarkerCreationService].
  Future<PdfMarker> createMarker({
    required int pageNumber,
    required MarkerColor color,
    String? selectedText,
    PdfRect? textRect,
    List<PdfRect>? lineRects,
    String? capturedImagePath,
    ElementType? elementTypeOverride,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      throw Exception('Workspace state not initialized');
    }
    if (pageNumber <= 0) {
      throw ArgumentError('Invalid page number: $pageNumber');
    }

    // 1. Create marker + update state
    const uuid = Uuid();
    final marker = PdfMarker(
      id: uuid.v4(),
      pageNumber: pageNumber,
      color: color,
      selectedText: selectedText,
      textRect: textRect,
      lineRects: lineRects,
      capturedImagePath: capturedImagePath,
    );
    state = AsyncData(
      currentState.copyWith(markers: [...currentState.markers, marker]),
    );

    // 2. Persist to Hive
    await MarkerCreationService.persistToHive(ref, marker: marker, color: color);

    // 3. Auto-create note if needed
    var currentNoteId = state.valueOrNull?.currentNoteId;
    if (currentNoteId == null && currentState.currentPdfPath != null) {
      currentNoteId = await _autoCreateNote(currentState.currentPdfPath!);
      if (currentNoteId != null) {
        await ref.read(noteStateProvider(currentNoteId).future);
        ref.read(noteEditorProvider(currentNoteId));
      }
    }

    // 4. Insert into note editor
    if (currentNoteId != null) {
      if (capturedImagePath != null) {
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
        await ref
            .read(noteEditorProvider(currentNoteId).notifier)
            .insertMarker(
              color: color,
              pageNumber: pageNumber,
              text: selectedText ?? '',
            );
      }
    }

    // 5. Create ScrapElement + append @el + add to store
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

        // Append @el to scrapnote block BEFORE elementStore.add()
        if (currentNoteId != null) {
          final controller = ref.read(noteEditorProvider(currentNoteId));
          final baseContent = controller?.text;
          if (baseContent != null && baseContent.isNotEmpty) {
            final updatedContent = ScrapnoteBlockEditor.appendElement(
              baseContent, element.id);
            controller!.text = updatedContent;
            await ref
                .read(noteEditorProvider(currentNoteId).notifier)
                .saveContent(currentNoteId);
          } else {
            final noteStorage = ref.read(noteStorageServiceProvider);
            final diskContent =
                await noteStorage.loadNote(noteId: currentNoteId);
            if (diskContent != null && diskContent.isNotEmpty) {
              final updatedContent = ScrapnoteBlockEditor.appendElement(
                diskContent, element.id);
              await noteStorage.saveNoteImmediate(
                noteId: currentNoteId, content: updatedContent);
              ref.invalidate(noteStateProvider(currentNoteId));
            }
          }
        }

        // Add to Hive — bumps revision, triggers noteScrapProvider
        ref.read(elementStoreProvider.notifier).add(element);

        // Force noteScrapProvider rebuild
        if (currentNoteId != null) {
          ref.invalidate(noteScrapProvider(currentNoteId));
        }

        // CanvasElement creation (fire-and-forget, non-blocking)
        MarkerCreationService.createCanvasElement(
          ref,
          marker: marker,
          pdfPath: currentState.currentPdfPath!,
          capturedImagePath: capturedImagePath,
          selectedText: selectedText,
          color: color,
        );
      } catch (e, st) {
        debugPrint('[createMarker] ScrapElement error: $e\n$st');
      }
    }

    return marker;
  }

  /// Extract text from a full PDF page using opendataloader-pdf submodule.
  ///
  /// The extracted text is inserted as a marker in the current note.
  Future<void> ocrCurrentPage({
    required int pageNumber,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final pdfPath = currentState.currentPdfPath;
    if (pdfPath == null) return;

    try {
      final text = await PdfTextExtractionService.extractPageText(pdfPath, pageNumber);
      if (text != null && text.trim().isNotEmpty) {
        await createMarker(
          pageNumber: pageNumber,
          color: MarkerColor.blue,
          selectedText: text,
        );
      }
    } catch (e) {
      debugPrint('[ocrCurrentPage] submodule extraction failed: $e');
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

    // Persist
    await WorkspacePersistence.savePanelSizes(sizes.toJson());
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

    // 2b. Delete PDF marker (same ID as element — removes highlight overlay from PDF)
    try {
      await ref.read(pdfMarkerStateProvider.notifier).deleteMarker(elementId);
    } catch (_) {}
    // Also remove from in-memory workspace markers list
    final ws = state.valueOrNull;
    if (ws != null) {
      final filtered = ws.markers.where((m) => m.id != elementId).toList();
      if (filtered.length != ws.markers.length) {
        state = AsyncData(ws.copyWith(markers: filtered));
      }
    }

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

  /// Reorder ALL scrap-card elements (capture/lasso/highlight) to match a
  /// given ID order. Used by the scrap panel to sync the 2D layout (visual
  /// order on the right panel) back to the markdown `@el` order so the
  /// left sidebar thumbnail order tracks where the user dropped each card.
  ///
  /// Non-card types (drawing, etc.) are kept in their original markdown
  /// positions. If [orderedCardIds] contains an id that isn't yet in the
  /// markdown (e.g., a card that was just appended in another flow), it is
  /// appended at the end so the entry isn't dropped.
  Future<void> reorderAllScraps(String noteId, List<String> orderedCardIds) async {
    final noteStorage = ref.read(noteStorageServiceProvider);
    final controller = ref.read(noteEditorProvider(noteId));

    final content = controller?.text ??
        await noteStorage.loadNote(noteId: noteId) ??
        '';
    if (content.isEmpty) return;

    final allIds = ScrapnoteBlockEditor.getElementIds(content);
    if (allIds.isEmpty) return;

    final elementStore = ref.read(elementStoreProvider.notifier);
    final orderedSet = orderedCardIds.toSet();

    bool isCardType(ElementType t) =>
        t == ElementType.capture ||
        t == ElementType.lasso ||
        t == ElementType.highlight;

    // Rebuild full ID list: replace each card slot in allIds with the next
    // entry from orderedCardIds in order. Highlights are reordered just
    // like capture/lasso so the visual layout stays consistent across
    // every scrap-card type. Non-card slots stay put.
    int cardIdx = 0;
    final reorderedIds = <String>[];
    final placedCardIds = <String>{};
    for (final id in allIds) {
      final el = elementStore.getById(id);
      final isCard = el != null && isCardType(el.type);
      if (isCard && orderedSet.contains(id)) {
        if (cardIdx < orderedCardIds.length) {
          final replacement = orderedCardIds[cardIdx++];
          reorderedIds.add(replacement);
          placedCardIds.add(replacement);
        } else {
          reorderedIds.add(id);
        }
      } else {
        reorderedIds.add(id);
      }
    }
    // Any orderedCardIds entries that didn't fit a card slot in allIds
    // (because allIds had fewer card slots than orderedCardIds.length —
    // e.g., a freshly-added card whose @el line landed somewhere the loop
    // didn't reach, or markdown duplication mismatch) are appended so they
    // aren't silently dropped.
    for (final id in orderedCardIds) {
      if (!placedCardIds.contains(id)) {
        reorderedIds.add(id);
      }
    }

    final updated =
        ScrapnoteBlockEditor.reorderElements(content, null, reorderedIds);
    if (controller != null) {
      controller.text = updated;
    }
    await noteStorage.saveNoteImmediate(noteId: noteId, content: updated);
    // noteScrapProvider watches noteEditorProvider (controller.text) and
    // noteStateProvider, so it rebuilds automatically when either changes.
    // Only invalidate noteStateProvider to sync disk state — do NOT also
    // invalidate noteScrapProvider, as that causes CircularDependencyError
    // when both providers try to rebuild simultaneously.
    ref.invalidate(noteStateProvider(noteId));
  }

  // ─── Layout control ─────────────────────────────────────

  /// Set which panel is focused (determines size ratio)
  void setFocusedPanel(FocusedPanel panel) {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(focusedPanel: panel));
  }

  /// Swap PDF and ScrapNote positions (left↔right)
  void swapLayout() {
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
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isQuickScrapMode: !s.isQuickScrapMode));
  }

  void toggleHighlightMode() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isHighlightMode: !s.isHighlightMode));
  }

  void setHighlightColor(String colorName) {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(highlightModeColorName: colorName));
  }

  // ─── Scrap selection control ─────────────────────────────

  /// Toggle selection of a scrap element
  void toggleScrapSelection(String elementId) {
    final s = state.valueOrNull;
    if (s == null) return;
    final ids = Set<String>.from(s.selectedScrapIds);
    if (ids.contains(elementId)) {
      ids.remove(elementId);
    } else {
      ids.add(elementId);
    }
    state = AsyncData(s.copyWith(selectedScrapIds: ids));
  }

  /// Clear all scrap selections
  void clearScrapSelection() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(selectedScrapIds: {}));
  }

  // ─── Structure overlay control ──────────────────────

  /// Toggle PDF view mode between continuous and facing pages.
  void togglePdfViewMode() {
    final s = state.valueOrNull;
    if (s == null) return;
    final next = s.pdfViewMode == PdfViewMode.continuous
        ? PdfViewMode.facing
        : PdfViewMode.continuous;
    state = AsyncData(s.copyWith(pdfViewMode: next));
  }

  /// Toggle the structure overlay visibility on the PDF viewer.
  void toggleStructureOverlay() {
    final s = state.valueOrNull;
    if (s == null) return;
    final willShow = !s.isStructureOverlayVisible;
    state = AsyncData(s.copyWith(
      isStructureOverlayVisible: willShow,
    ));
    // Lazy trigger: if turning on and no analysis yet, start it
    if (willShow && s.currentPdfPath != null) {
      final structState = ref.read(pdfStructureProvider);
      if (structState.result == null && !structState.isAnalyzing) {
        ref.read(pdfStructureProvider.notifier).analyze(s.currentPdfPath!);
      }
    }
  }

  // ─── Scrap group control ──────────────────────────

  void groupSelectedScraps() {
    final s = state.valueOrNull;
    if (s == null || s.selectedScrapIds.length < 2) return;
    final newGroup = s.selectedScrapIds.toList();
    final groups = s.scrapGroups
        .map((g) => g.where((id) => !s.selectedScrapIds.contains(id)).toList())
        .where((g) => g.length >= 2)
        .toList();
    groups.add(newGroup);
    state = AsyncData(s.copyWith(scrapGroups: groups));
    _persistGroups(groups);
  }

  void ungroupScraps(Set<String> ids) {
    final s = state.valueOrNull;
    if (s == null) return;
    final groups = s.scrapGroups
        .where((g) => !g.any((id) => ids.contains(id)))
        .toList();
    state = AsyncData(s.copyWith(scrapGroups: groups));
    _persistGroups(groups);
  }

  Future<void> _persistGroups(List<List<String>> groups) async {
    final noteId = state.valueOrNull?.currentNoteId;
    if (noteId == null) return;
    await WorkspacePersistence.saveGroups(noteId, groups);
  }

  /// Find the group containing [elementId], or null.
  List<String>? findGroupOf(String elementId) {
    final s = state.valueOrNull;
    if (s == null) return null;
    for (final g in s.scrapGroups) {
      if (g.contains(elementId)) return g;
    }
    return null;
  }

  /// Check if current selection is already a group.
  bool isSelectionGrouped() {
    final s = state.valueOrNull;
    if (s == null || s.selectedScrapIds.length < 2) return false;
    for (final g in s.scrapGroups) {
      if (s.selectedScrapIds.every((id) => g.contains(id))) return true;
    }
    return false;
  }

  /// Select specific scrap IDs
  void setScrapSelection(Set<String> ids) {
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
    List<PdfRect>? lineRects,
    ElementType? elementType,
  }) {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      isScrapBoardOpen: true,
      pendingScrapPageNumber: pageNumber,
      pendingScrapText: selectedText,
      pendingScrapImagePath: imagePath,
      pendingScrapTextRect: textRect,
      pendingScrapLineRects: lineRects,
      pendingScrapElementType: elementType,
    ));
  }

  /// Close the scrap board popup
  void closeScrapBoard() {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(
      isScrapBoardOpen: false,
      pendingScrapPageNumber: null,
      pendingScrapText: null,
      pendingScrapImagePath: null,
      pendingScrapTextRect: null,
      pendingScrapLineRects: null,
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
