import 'dart:ui' show Offset, Size;

enum NodeShape { rectangle, oval, roundedRect, diamond }

enum EdgeType { sequential, emphasis, weak, directed, bidirectional, undirected }

class FlowNode {
  final String id;
  final String label;
  final NodeShape shape;
  Offset position;
  Size computedSize;

  FlowNode({
    required this.id,
    required this.label,
    this.shape = NodeShape.rectangle,
    this.position = Offset.zero,
    this.computedSize = Size.zero,
  });
}

class FlowEdge {
  final String fromId;
  final String toId;
  final EdgeType type;
  final String? label;

  const FlowEdge({
    required this.fromId,
    required this.toId,
    required this.type,
    this.label,
  });
}

class FlowGraph {
  final List<FlowNode> nodes;
  final List<FlowEdge> edges;

  const FlowGraph({required this.nodes, required this.edges});

  static const empty = FlowGraph(nodes: [], edges: []);
}
