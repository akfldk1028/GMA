import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/element_model.dart';
import '../utils/scrapnote_block_editor.dart';
import '../../note_editor/pages/providers/note_editor_provider.dart';
import '../../note_editor/pages/providers/note_provider.dart';
import 'element_store.dart';

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

  // Use @el references from ::: scrapnote block as sole source of truth.
  // Each note owns its own scraps — no cross-note PDF-wide fallback.
  if (content != null && content.isNotEmpty && ScrapnoteBlockEditor.hasBlock(content)) {
    final ids = ScrapnoteBlockEditor.getElementIds(content);
    final fetched = elementStore.getByIds(ids);
    final elements = fetched
        .where((e) => e.type != ElementType.drawing)
        .toList();
    // ignore: avoid_print
    print(
        '[noteScrap] noteId=$noteId markdownIds=${ids.length} fetched=${fetched.length} '
        'returned=${elements.length} missing=${ids.length - fetched.length}');
    return elements;
  }
  // ignore: avoid_print
  print('[noteScrap] noteId=$noteId no scrapnote block found in content');
  return [];
}

