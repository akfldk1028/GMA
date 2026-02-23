import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import '../parser/mindmap_parser.dart';
import '../renderer/mindmap_canvas_painter.dart';

class MindmapBlock extends BlockDefinition {
  @override
  String get typeName => 'mindmap';
  @override
  BlockCategory get category => BlockCategory.visual;
  @override
  Color get color => const Color(0xFF14B8A6);
  @override
  IconData get icon => Icons.schema_outlined;
  @override
  String get label => 'Mindmap';
  @override
  String get template =>
      '::: mindmap 주제\n주제\n  가지1\n    세부1\n    세부2\n  가지2\n    세부3\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    final root = MindmapParser.parse(content);
    if (root == null) return const SizedBox.shrink();

    final size = MindmapCanvasPainter.computeSize(root);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: CustomPaint(
                size: size,
                painter: MindmapCanvasPainter(root: root, accentColor: color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final sb = StringBuffer();
    if (title.isNotEmpty) sb.writeln('## $title\n');
    for (final line in content.split('\n')) {
      if (line.trimRight().isEmpty) continue;
      int spaces = 0;
      for (final ch in line.codeUnits) {
        if (ch == 0x20) {
          spaces++;
        } else if (ch == 0x09) {
          spaces += 2;
        } else {
          break;
        }
      }
      final indent = '  ' * (spaces ~/ 2);
      sb.writeln('$indent- ${line.trim()}');
    }
    return sb.toString().trimRight();
  }
}
