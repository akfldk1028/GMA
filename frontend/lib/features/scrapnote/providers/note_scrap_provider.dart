import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/element_model.dart';
import '../utils/scrapnote_block_editor.dart';
import '../../note_editor/pages/providers/note_editor_provider.dart';
import '../../workspace/pages/providers/workspace_provider.dart';
import 'element_store.dart';
import 'pdf_registry_provider.dart';

part 'note_scrap_provider.g.dart';

/// Bridge between note markdown content and ScrapCardPanel.
///
/// Strategy:
/// - If note has `::: scrapnote` block → read `@el` IDs from block (source of truth)
/// - If no block → fallback to all elements for the current PDF from ElementStore
@riverpod
List<ScrapElement> noteScrap(NoteScrapRef ref, String noteId) {
  // Watch element store for element data changes
  ref.watch(elementStoreProvider);
  final elementStore = ref.read(elementStoreProvider.notifier);

  // Watch note editor for content changes
  final controller = ref.watch(noteEditorProvider(noteId));
  final content = controller?.text;

  // If note has ::: scrapnote block, use IDs from block
  if (content != null && content.isNotEmpty && ScrapnoteBlockEditor.hasBlock(content)) {
    final ids = ScrapnoteBlockEditor.getElementIds(content);
    debugPrint('[noteScrapProvider] block found, ${ids.length} element IDs');
    if (ids.isEmpty) return [];
    return elementStore.getByIds(ids);
  }

  // Fallback: show all elements for the current PDF
  final ws = ref.watch(workspaceProviderProvider).valueOrNull;
  final pdfPath = ws?.currentPdfPath;
  if (pdfPath == null) return [];

  final pdfId = ref.read(pdfRegistryProvProvider.notifier).getIdByPath(pdfPath);
  if (pdfId == null) return [];

  final elements = elementStore.getByPdfId(pdfId);
  debugPrint('[noteScrapProvider] fallback: ${elements.length} elements for pdfId $pdfId');
  elements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return elements;
}
