import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import '../models/flow_graph_model.dart';
import '../parser/flow_parser.dart';
import '../renderer/flow_canvas_painter.dart';

class FlowBlock extends BlockDefinition {
  @override
  String get typeName => 'flow';
  @override
  BlockCategory get category => BlockCategory.visual;
  @override
  Color get color => const Color(0xFF6366F1);
  @override
  IconData get icon => Icons.account_tree;
  @override
  String get label => 'Flow';
  @override
  String get template =>
      '::: flow\n(시작) --> 단계1\n단계1 --> {조건?}\n{조건?} --> 단계2\n{조건?} --> (끝)\n단계2 --> (끝)\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    final graph = FlowParser.parse(content);
    if (graph.nodes.isEmpty) return const SizedBox.shrink();

    FlowCanvasPainter.measureNodes(graph.nodes);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.03),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final layers = _assignLayers(graph);
          _positionNodes(layers, width);

          double totalHeight = FlowCanvasPainter.padding * 2;
          for (int i = 0; i < layers.length; i++) {
            final layerHeight = layers[i].fold<double>(
              0,
              (max, n) => n.computedSize.height > max ? n.computedSize.height : max,
            );
            totalHeight += layerHeight > 0 ? layerHeight : FlowCanvasPainter.nodeHeight;
            if (i < layers.length - 1) {
              totalHeight += FlowCanvasPainter.verticalSpacing;
            }
          }

          return SizedBox(
            height: totalHeight,
            child: CustomPaint(
              size: Size(width, totalHeight),
              painter: FlowCanvasPainter(graph: graph),
            ),
          );
        },
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final graph = FlowParser.parse(content);
    if (graph.nodes.isEmpty) return content;
    final sorted = _topologicalSort(graph);
    return sorted.map((n) => '- ${n.label}').join('\n');
  }

  void _positionNodes(List<List<FlowNode>> layers, double width) {
    double y = FlowCanvasPainter.padding;
    for (int layerIdx = 0; layerIdx < layers.length; layerIdx++) {
      final layer = layers[layerIdx];
      final layerHeight = layer.fold<double>(
        0,
        (max, n) => n.computedSize.height > max ? n.computedSize.height : max,
      );
      final h = layerHeight > 0 ? layerHeight : FlowCanvasPainter.nodeHeight;
      for (int i = 0; i < layer.length; i++) {
        final x = width / (layer.length + 1) * (i + 1);
        layer[i].position = Offset(x, y + h / 2);
      }
      y += h + FlowCanvasPainter.verticalSpacing;
    }
  }

  List<List<FlowNode>> _assignLayers(FlowGraph graph) {
    final inDegree = <String, int>{};
    final adj = <String, List<String>>{};
    for (final node in graph.nodes) {
      inDegree[node.id] = 0;
      adj[node.id] = [];
    }
    for (final edge in graph.edges) {
      adj[edge.fromId]?.add(edge.toId);
      inDegree[edge.toId] = (inDegree[edge.toId] ?? 0) + 1;
    }
    final layers = <List<FlowNode>>[];
    final nodeMap = {for (final n in graph.nodes) n.id: n};
    final remaining = Set<String>.from(graph.nodes.map((n) => n.id));
    while (remaining.isNotEmpty) {
      final layer = remaining
          .where((id) => (inDegree[id] ?? 0) == 0)
          .map((id) => nodeMap[id]!)
          .toList();
      if (layer.isEmpty) {
        layers.add(remaining.map((id) => nodeMap[id]!).toList());
        break;
      }
      layers.add(layer);
      for (final node in layer) {
        remaining.remove(node.id);
        for (final targetId in adj[node.id] ?? <String>[]) {
          inDegree[targetId] = (inDegree[targetId] ?? 1) - 1;
        }
      }
    }
    return layers;
  }

  static List<FlowNode> _topologicalSort(FlowGraph graph) {
    final inDegree = <String, int>{};
    final adj = <String, List<String>>{};
    for (final node in graph.nodes) {
      inDegree[node.id] = 0;
      adj[node.id] = [];
    }
    for (final edge in graph.edges) {
      adj[edge.fromId]?.add(edge.toId);
      inDegree[edge.toId] = (inDegree[edge.toId] ?? 0) + 1;
    }
    final result = <FlowNode>[];
    final nodeMap = {for (final n in graph.nodes) n.id: n};
    final queue = graph.nodes.where((n) => (inDegree[n.id] ?? 0) == 0).toList();
    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      result.add(node);
      for (final targetId in adj[node.id] ?? <String>[]) {
        inDegree[targetId] = (inDegree[targetId] ?? 1) - 1;
        if (inDegree[targetId] == 0) queue.add(nodeMap[targetId]!);
      }
    }
    for (final node in graph.nodes) {
      if (!result.contains(node)) result.add(node);
    }
    return result;
  }
}
