import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import '_block_base.dart';
import 'inner_markdown_content.dart';

/// Parameterized callout block definition.
/// Each callout type (note, tip, warning, etc.) is a separate instance
/// with its own color/icon/aliases.
class CalloutBlock extends BlockDefinition {
  CalloutBlock({
    required this.typeName,
    required this.color,
    required this.icon,
    required this.label,
    this.aliases = const [],
  });

  @override
  final String typeName;
  @override
  final List<String> aliases;
  @override
  BlockCategory get category => BlockCategory.callout;
  @override
  final Color color;
  @override
  final IconData icon;
  @override
  final String label;

  @override
  String get template =>
      '::: $typeName\n내용을 여기에 작성하세요.\n:::\n';

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
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final quoted = content.replaceAll('\n', '\n> ');
    if (title.isNotEmpty) return '> **[$label]** $title\n> $quoted';
    return '> **[$label]**\n> $quoted';
  }
}
