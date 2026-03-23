import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../scrapnote/models/element_model.dart';

class GroupEditDialog extends StatefulWidget {
  const GroupEditDialog({
    super.key,
    required this.elements,
    required this.onConfirm,
    this.capturesDir,
  });

  final List<ScrapElement> elements;
  final String? capturesDir;
  final VoidCallback onConfirm;

  @override
  State<GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends State<GroupEditDialog> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String? _resolveImage(ScrapElement el) {
    final img = el.imagePath;
    if (img == null || img.isEmpty) return null;
    if (p.isAbsolute(img) && File(img).existsSync()) return img;
    if (widget.capturesDir != null) {
      final resolved = p.join(widget.capturesDir!, img);
      if (File(resolved).existsSync()) return resolved;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.layers, size: 16, color: Colors.blue.shade500),
                  const SizedBox(width: 8),
                  Text('Group (${widget.elements.length})',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onConfirm,
                    child: const Text('\uD655\uC778'),
                  ),
                ],
              ),
            ),

            // Scrap content list
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: widget.elements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final el = widget.elements[index];
                  final imgPath = _resolveImage(el);
                  final isHighlight = el.type == ElementType.highlight;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Element header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isHighlight
                                    ? Icons.highlight_rounded
                                    : Icons.crop,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text('P${el.pageNumber}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        // Image (capture)
                        if (imgPath != null)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(imgPath),
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        // Text content
                        if (el.selectedText != null &&
                            el.selectedText!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                            child: Text(
                              el.selectedText!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Note input
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '\uC2A4\uD06C\uB7A9 \uB178\uD2B8\uC5D0 \uCD94\uAC00\uB85C \uC4F4 \uB0B4\uC6A9...',
                  hintStyle: TextStyle(
                      fontSize: 12, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
