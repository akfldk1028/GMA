import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/element_model.dart';
import '../utils/scrapnote_block_editor.dart';
import '../../note_editor/pages/providers/note_editor_provider.dart';
import '../../note_editor/pages/providers/note_provider.dart';
import '../../workspace/pages/providers/workspace_provider.dart';
import 'element_store.dart';
import 'pdf_registry_provider.dart';

part 'note_scrap_provider.g.dart';

/// Bridge between note markdown content and the ScrapNote canvas panel.
///
/// Strategy:
/// - If note has `::: scrapnote` block → read `@el` IDs from block (source of truth)
/// - If no block → fallback to all elements for the current PDF from ElementStore
///
/// Sorting: by page number ascending, then by PDF Y-coordinate descending
/// (PDF origin is bottom-left, Y increases upward — higher top = higher on page).
@riverpod
List<ScrapElement> noteScrap(NoteScrapRef ref, String noteId) {
  // Watch element store revision — rebuilds when elements are added/removed
  ref.watch(elementStoreProvider);
  final elementStore = ref.read(elementStoreProvider.notifier);

  // Watch note state (file-based) to catch disk saves from createMarker
  ref.watch(noteStateProvider(noteId));

  // Read live controller text (may have unsaved @el references),
  // or fall back to file-based note state for when editor is not open.
  final controller = ref.watch(noteEditorProvider(noteId));
  final noteState = ref.watch(noteStateProvider(noteId)).valueOrNull;
  final content = controller?.text ?? noteState?.content;

  // If note has ::: scrapnote block with @el references, use those as source of truth
  if (content != null && content.isNotEmpty && ScrapnoteBlockEditor.hasBlock(content)) {
    final ids = ScrapnoteBlockEditor.getElementIds(content);
    debugPrint('[noteScrapProvider] block found, ${ids.length} element IDs');
    if (ids.isNotEmpty) {
      final elements = elementStore.getByIds(ids)
          .where((e) => e.type == ElementType.capture || e.type == ElementType.lasso)
          .toList();
      // Preserve @el order from block (user-defined via drag reorder).
      // Only sort by PDF position in fallback path below.
      return elements;
    }
    // Block exists but empty → fall through to ElementStore fallback
  }

  // Fallback: show all elements for the current PDF
  final ws = ref.watch(workspaceProviderProvider).valueOrNull;
  final pdfPath = ws?.currentPdfPath;
  if (pdfPath == null) return [];

  final pdfId = ref.read(pdfRegistryProvProvider.notifier).getIdByPath(pdfPath);
  if (pdfId == null) return [];

  final elements = elementStore.getByPdfId(pdfId)
      .where((e) => e.type == ElementType.capture || e.type == ElementType.lasso)
      .toList();
  debugPrint('[noteScrapProvider] fallback: ${elements.length} capture/lasso elements for pdfId $pdfId');

  // Trigger async backfill so next rebuild uses block path instead of fallback.
  // syncElementsToBlock invalidates noteStateProvider when it writes,
  // which triggers noteEditorProvider → this provider rebuild automatically.
  // Do NOT call invalidateSelf() here — it causes infinite loop when sync is no-op.
  if (elements.isNotEmpty && noteId.isNotEmpty) {
    Future.microtask(() async {
      try {
        await ref
            .read(workspaceProviderProvider.notifier)
            .syncElementsToBlock(noteId);
      } catch (e) {
        debugPrint('[noteScrapProvider] backfill failed: $e');
      }
    });
  }

  _sortByPdfPosition(elements);
  return elements;
}

/// Sort elements in PDF reading order:
/// 1. Page number ascending
/// 2. Y position descending (PDF coords: higher top = higher on page = read first)
/// 3. X position ascending (left to right)
/// 4. Elements without rect: sorted by createdAt
void _sortByPdfPosition(List<ScrapElement> elements) {
  elements.sort((a, b) {
    // Primary: page number
    final pageCmp = a.pageNumber.compareTo(b.pageNumber);
    if (pageCmp != 0) return pageCmp;

    // Secondary: PDF Y coordinate (top value, descending = reading order)
    final aTop = a.rect?.top;
    final bTop = b.rect?.top;

    if (aTop != null && bTop != null) {
      // Higher top = higher on page = comes first → sort descending
      final yCmp = bTop.compareTo(aTop);
      if (yCmp != 0) return yCmp;

      // Tertiary: X coordinate (left to right)
      final aLeft = a.rect?.left ?? 0;
      final bLeft = b.rect?.left ?? 0;
      return aLeft.compareTo(bLeft);
    }

    // Elements with rect come before those without
    if (aTop != null) return -1;
    if (bTop != null) return 1;

    // Fallback: creation time
    return a.createdAt.compareTo(b.createdAt);
  });
}
