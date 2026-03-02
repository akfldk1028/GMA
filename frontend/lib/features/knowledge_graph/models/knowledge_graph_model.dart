import 'dart:ui' show Offset;

enum KnowledgeNodeType { pdf, note }

class KnowledgeNode {
  final String id;
  final String label;
  final KnowledgeNodeType type;

  /// The original note ID or PDF UUID for navigation.
  final String referenceId;

  /// For note nodes that link to a PDF, the PDF path.
  final String? linkedPdfPath;

  /// Number of edges connected to this node (used for sizing).
  final int connectionCount;

  /// Mutable position set by layout algorithm / drag.
  Offset position;

  KnowledgeNode({
    required this.id,
    required this.label,
    required this.type,
    required this.referenceId,
    this.linkedPdfPath,
    this.connectionCount = 0,
    this.position = Offset.zero,
  });
}

class KnowledgeEdge {
  final String fromId;
  final String toId;

  /// Number of ScrapElements on this link (controls line thickness).
  final int weight;

  final String? label;

  const KnowledgeEdge({
    required this.fromId,
    required this.toId,
    this.weight = 1,
    this.label,
  });
}

class KnowledgeGraph {
  final List<KnowledgeNode> nodes;
  final List<KnowledgeEdge> edges;

  const KnowledgeGraph({required this.nodes, required this.edges});

  static const empty = KnowledgeGraph(nodes: [], edges: []);

  bool get isEmpty => nodes.isEmpty;
}
