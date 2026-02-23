import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import 'inner_markdown_content.dart';

class ProofBlock extends BlockDefinition {
  @override
  String get typeName => 'proof';
  @override
  BlockCategory get category => BlockCategory.structural;
  @override
  Color get color => const Color(0xFF6366F1);
  @override
  IconData get icon => Icons.check_circle_outline;
  @override
  String get label => 'Proof';
  @override
  String get template => '::: proof\n증명 과정을 여기에 작성하세요.\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    final displayTitle = title.isNotEmpty ? '증명: $title' : '증명';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
        color: color.withValues(alpha: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 12, 4),
            child: InnerMarkdownContent(
              content: content,
              extensions: innerExtensions,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
              child: Text(
                '\u25A0',
                style: TextStyle(fontSize: 12, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final heading = title.isNotEmpty ? '증명: $title' : '증명';
    return '## $heading\n\n$content\n\n\u25A1';
  }
}
