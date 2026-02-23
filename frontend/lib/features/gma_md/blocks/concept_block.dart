import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import '_block_base.dart';
import 'inner_markdown_content.dart';

class ConceptBlock extends BlockDefinition {
  @override
  String get typeName => 'concept';
  @override
  List<String> get aliases => const ['definition'];
  @override
  BlockCategory get category => BlockCategory.structural;
  @override
  Color get color => const Color(0xFF3B82F6);
  @override
  IconData get icon => Icons.lightbulb_outline;
  @override
  String get label => 'Concept';
  @override
  String get template =>
      '::: concept 개념 제목\n개념 설명을 여기에 작성하세요.\n:::\n';

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
    if (title.isNotEmpty) return '## $title\n\n$content';
    return content;
  }
}
