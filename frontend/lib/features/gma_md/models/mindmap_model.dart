/// A node in a mindmap tree.
class MindmapNode {
  final String label;
  final List<MindmapNode> children;

  MindmapNode({required this.label, List<MindmapNode>? children})
      : children = children ?? [];
}
