import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../../utils/file_system_provider.dart';
import '../../../../scrapnote/models/element_model.dart';
import '../../../../scrapnote/providers/element_store.dart';
import '../../../../scrapnote/providers/note_scrap_provider.dart';
import '../../../../scrapnote/providers/pdf_registry_provider.dart';
import '../../providers/workspace_provider.dart';

class ScrapImportDialog {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required String currentNoteId,
  }) async {
    final allElements = ref.read(elementStoreProvider.notifier).all();
    final importable = allElements.where(_isImportable).toList();
    final currentElements = ref.read(noteScrapProvider(currentNoteId));
    final currentIds = currentElements.map((e) => e.id).toSet();
    final available = importable
        .where((e) => !currentIds.contains(e.id))
        .toList();

    if (available.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other scraps available to import')),
        );
      }
      return;
    }

    final grouped = <String, List<ScrapElement>>{};
    for (final el in available) {
      grouped.putIfAbsent(el.pdfId, () => []).add(el);
    }

    final capturesDir = ref.read(capturesDirectoryProvider).valueOrNull?.path;
    final pdfRegistry = ref.read(pdfRegistryProvProvider.notifier);
    await pdfRegistry.ensureReady();
    if (!context.mounted) return;

    final selected = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => ImportDialogContent(
        grouped: grouped,
        capturesDir: capturesDir,
        pdfLabelForId: (pdfId) {
          final path = pdfRegistry.getPathById(pdfId);
          if (path == null || path.isEmpty) return pdfId;
          return p.basenameWithoutExtension(path);
        },
      ),
    );

    if (selected == null || selected.isEmpty) return;
    final wsNotifier = ref.read(workspaceProviderProvider.notifier);
    for (final id in selected) {
      await wsNotifier.appendElementToBlock(currentNoteId, id);
    }
  }

  static bool _isImportable(ScrapElement element) {
    return element.type == ElementType.capture ||
        element.type == ElementType.lasso ||
        element.type == ElementType.highlight;
  }
}

class ImportDialogContent extends StatefulWidget {
  const ImportDialogContent({
    super.key,
    required this.grouped,
    required this.pdfLabelForId,
    this.capturesDir,
  });
  final Map<String, List<ScrapElement>> grouped;
  final String Function(String pdfId) pdfLabelForId;
  final String? capturesDir;

  @override
  State<ImportDialogContent> createState() => _ImportDialogContentState();
}

class _ImportDialogContentState extends State<ImportDialogContent> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Scraps', style: TextStyle(fontSize: 16)),
      content: SizedBox(
        width: 320,
        height: 400,
        child: ListView(
          children: widget.grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    widget.pdfLabelForId(entry.key),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                ...entry.value.map((el) {
                  final sel = _selected.contains(el.id);
                  return GestureDetector(
                    onTap: () => setState(() {
                      sel ? _selected.remove(el.id) : _selected.add(el.id);
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: sel ? Colors.blue.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: sel
                              ? Colors.blue.shade300
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            sel
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 16,
                            color: sel
                                ? Colors.blue.shade700
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'P${el.pageNumber} · ${el.type.name}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.pop(context, _selected.toList()),
          child: Text('Import (${_selected.length})'),
        ),
      ],
    );
  }
}
