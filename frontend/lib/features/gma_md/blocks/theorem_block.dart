import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import 'inner_markdown_content.dart';

class TheoremBlock extends BlockDefinition {
  @override
  String get typeName => 'theorem';
  @override
  BlockCategory get category => BlockCategory.structural;
  @override
  Color get color => const Color(0xFF8B5CF6);
  @override
  IconData get icon => Icons.functions;
  @override
  String get label => 'Theorem';
  @override
  String get template =>
      '::: theorem 정리 이름\n정리 내용을 여기에 작성하세요.\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    final displayTitle = title.isNotEmpty ? '정리: $title' : '정리';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InnerMarkdownContent(
              content: content,
              extensions: innerExtensions,
            ),
          ),
        ],
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final heading = title.isNotEmpty ? '정리: $title' : '정리';
    return '## $heading\n\n$content';
  }
}
