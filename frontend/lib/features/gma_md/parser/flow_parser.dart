import '../models/flow_graph_model.dart';

class FlowParser {
  static final _labeledEdge = RegExp(
    r'^(.+?)\s+--\s+(.+?)\s+(-->|==>|-.->|<-->|---)\s+(.+)$',
  );
  static final _simpleEdge = RegExp(
    r'^(.+?)\s*(-->|==>|-.->|<-->|---)\s*(.+)$',
  );

  static FlowGraph parse(String content) {
    final nodeMap = <String, FlowNode>{};
    final edges = <FlowEdge>[];

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      String? sourceStr, targetStr, label;
      EdgeType edgeType;

      // Try labeled edge first: A -- label --> B
      final labeledMatch = _labeledEdge.firstMatch(line);
      if (labeledMatch != null) {
        sourceStr = labeledMatch.group(1)!.trim();
        label = labeledMatch.group(2)!.trim();
        edgeType = _parseEdgeType(labeledMatch.group(3)!);
        targetStr = labeledMatch.group(4)!.trim();
      } else {
        // Try simple edge: A --> B
        final simpleMatch = _simpleEdge.firstMatch(line);
        if (simpleMatch == null) continue;
        sourceStr = simpleMatch.group(1)!.trim();
        edgeType = _parseEdgeType(simpleMatch.group(2)!);
        targetStr = simpleMatch.group(3)!.trim();
      }

      // Handle comma-separated branching/merging
      final sources =
          sourceStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
      final targets =
          targetStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);

      for (final src in sources) {
        final srcNode = _getOrCreateNode(nodeMap, src);
        for (final tgt in targets) {
          final tgtNode = _getOrCreateNode(nodeMap, tgt);
          edges.add(FlowEdge(
            fromId: srcNode.id,
            toId: tgtNode.id,
            type: edgeType,
            label: label,
          ));
        }
      }
    }

    return FlowGraph(nodes: nodeMap.values.toList(), edges: edges);
  }

  static FlowNode _getOrCreateNode(Map<String, FlowNode> map, String raw) {
    final parsed = _parseNodeShape(raw);
    return map.putIfAbsent(
      parsed.label,
      () => FlowNode(
        id: parsed.label,
        label: parsed.label,
        shape: parsed.shape,
      ),
    );
  }

  static ({String label, NodeShape shape}) _parseNodeShape(String raw) {
    if (raw.startsWith('(') && raw.endsWith(')')) {
      return (label: raw.substring(1, raw.length - 1), shape: NodeShape.oval);
    }
    if (raw.startsWith('[') && raw.endsWith(']')) {
      return (
        label: raw.substring(1, raw.length - 1),
        shape: NodeShape.roundedRect
      );
    }
    if (raw.startsWith('{') && raw.endsWith('}')) {
      return (
        label: raw.substring(1, raw.length - 1),
        shape: NodeShape.diamond
      );
    }
    return (label: raw, shape: NodeShape.rectangle);
  }

  static EdgeType _parseEdgeType(String arrow) {
    switch (arrow) {
      case '-->':
        return EdgeType.sequential;
      case '==>':
        return EdgeType.emphasis;
      case '-.->':
        return EdgeType.weak;
      case '<-->':
        return EdgeType.bidirectional;
      case '---':
        return EdgeType.undirected;
      default:
        return EdgeType.sequential;
    }
  }
}
