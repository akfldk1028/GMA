import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import '_block_base.dart';
import 'inner_markdown_content.dart';

class CompareBlock extends BlockDefinition {
  @override
  String get typeName => 'compare';
  @override
  BlockCategory get category => BlockCategory.visual;
  @override
  Color get color => const Color(0xFF06B6D4);
  @override
  IconData get icon => Icons.compare_arrows;
  @override
  String get label => 'Compare';
  @override
  String get template =>
      '::: compare A vs B\nA의 특징을 설명합니다.\n---\nB의 특징을 설명합니다.\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    final parts = content.split(RegExp(r'\n\s*---\s*\n'));
    final left = parts.isNotEmpty ? parts[0].trim() : '';
    final right = parts.length > 1 ? parts[1].trim() : '';

    return BlockBase(
      color: color,
      icon: icon,
      title: title.isNotEmpty ? title : label,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InnerMarkdownContent(
                  content: left,
                  extensions: innerExtensions,
                ),
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: color.withValues(alpha: 0.3),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InnerMarkdownContent(
                  content: right,
                  extensions: innerExtensions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final parts = content.split(RegExp(r'\n\s*---\s*\n'));
    if (parts.length < 2) return content;
    final sb = StringBuffer();
    if (title.isNotEmpty) sb.writeln('## $title\n');
    sb.writeln('| Left | Right |');
    sb.writeln('|------|-------|');
    sb.writeln(
      '| ${parts[0].trim().replaceAll('\n', ' ')} '
      '| ${parts[1].trim().replaceAll('\n', ' ')} |',
    );
    return sb.toString();
  }
}
