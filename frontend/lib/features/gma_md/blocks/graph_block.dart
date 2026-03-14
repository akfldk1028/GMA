import 'dart:math';

import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import '../parser/flow_parser.dart';
import '../renderer/graph_canvas_painter.dart';

class GraphBlock extends BlockDefinition {
  @override
  String get typeName => 'graph';
  @override
  BlockCategory get category => BlockCategory.visual;
  @override
  Color get color => const Color(0xFF8B5CF6);
  @override
  IconData get icon => Icons.hub;
  @override
  String get label => 'Graph';
  @override
  String get template =>
      '::: graph 관계도\n개념A -- 포함 --> 개념B\n개념A -- 관련 --> 개념C\n개념B <--> 개념D\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    final graph = FlowParser.parse(content);
    if (graph.nodes.isEmpty) return const SizedBox.shrink();

    final dim = max(200.0, 120.0 + graph.nodes.length * 40.0);

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
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = min(dim, w * 0.8);
              final canvasSize = Size(w, h);
              GraphCanvasPainter.layoutCircular(graph, canvasSize);
              return SizedBox(
                height: h,
                child: CustomPaint(
                  size: canvasSize,
                  painter: GraphCanvasPainter(graph: graph),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty);
    return lines.map((l) => '- ${l.trim()}').join('\n');
  }
}
