import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import '_block_base.dart';
import 'inner_markdown_content.dart';

class SummaryBlock extends BlockDefinition {
  @override
  String get typeName => 'summary';
  @override
  List<String> get aliases => const ['abstract', 'tldr'];
  @override
  BlockCategory get category => BlockCategory.structural;
  @override
  Color get color => const Color(0xFFF59E0B);
  @override
  IconData get icon => Icons.summarize;
  @override
  String get label => 'Summary';
  @override
  String get template =>
      '::: summary 요약 제목\n1. 핵심 내용 1\n2. 핵심 내용 2\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    return BlockBase(
      color: color,
      icon: icon,
      title: title.isNotEmpty ? title : label,
      child: InnerMarkdownContent(
        content: content,
        extensions: innerExtensions,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final quoted = content.replaceAll('\n', '\n> ');
    if (title.isNotEmpty) return '> **$title**\n> $quoted';
    return '> $quoted';
  }
}
