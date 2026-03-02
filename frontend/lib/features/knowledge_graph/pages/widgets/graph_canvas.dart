import 'package:flutter/material.dart';

import '../../models/knowledge_graph_model.dart';
import '../providers/knowledge_graph_provider.dart';
import 'graph_edge_painter.dart';
import 'graph_node_widget.dart';

/// The main canvas that renders the knowledge graph.
///
/// Uses an [InteractiveViewer] for pan & zoom, with:
/// - A [CustomPaint] layer for edges (behind)
/// - [Positioned] + [GraphNodeWidget] for nodes (in front)
///
/// Node drag temporarily disables InteractiveViewer panning
/// to avoid gesture conflicts.
class GraphCanvas extends StatefulWidget {
  const GraphCanvas({
    super.key,
    required this.graph,
    required this.filter,
    required this.onNodeTap,
    required this.onNodeDrag,
    required this.onRelayout,
  });

  final KnowledgeGraph graph;
  final GraphFilter filter;
  final ValueChanged<KnowledgeNode> onNodeTap;
  final void Function(String nodeId, Offset newPosition) onNodeDrag;
  final VoidCallback onRelayout;

  @override
  State<GraphCanvas> createState() => GraphCanvasState();
}

class GraphCanvasState extends State<GraphCanvas> {
  final TransformationController _transformCtrl = TransformationController();
  bool _isDraggingNode = false;

  /// Current zoom scale factor — used to adjust drag deltas.
  double get _currentScale {
    final m = _transformCtrl.value;
    // Scale is stored in m[0] (scaleX) for uniform scaling.
    return m.storage[0];
  }

  static const _canvasWidth = 2000.0;
  static const _canvasHeight = 2000.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerView();
    });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void resetZoom() {
    _transformCtrl.value = Matrix4.identity();
    _centerView();
  }

  void _centerView() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final viewSize = renderBox.size;

    // Center the canvas so the middle of the 2000x2000 area is visible
    final dx = (viewSize.width - _canvasWidth) / 2;
    final dy = (viewSize.height - _canvasHeight) / 2;
    _transformCtrl.value = Matrix4.identity()..storage[12] = dx..storage[13] = dy;
  }

  Set<String>? get _visibleNodeIds {
    switch (widget.filter) {
      case GraphFilter.all:
        return null;
      case GraphFilter.pdfs:
        return widget.graph.nodes
            .where((n) => n.type == KnowledgeNodeType.pdf)
            .map((n) => n.id)
            .toSet();
      case GraphFilter.notes:
        return widget.graph.nodes
            .where((n) => n.type == KnowledgeNodeType.note)
            .map((n) => n.id)
            .toSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleIds = _visibleNodeIds;

    return InteractiveViewer(
      transformationController: _transformCtrl,
      minScale: 0.1,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      panEnabled: !_isDraggingNode,
      child: SizedBox(
        width: _canvasWidth,
        height: _canvasHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Edge layer (behind)
            Positioned.fill(
              child: CustomPaint(
                painter: GraphEdgePainter(
                  graph: widget.graph,
                  visibleNodeIds: visibleIds,
                ),
              ),
            ),

            // Node layer (in front)
            for (final node in widget.graph.nodes)
              if (visibleIds == null || visibleIds.contains(node.id))
                Positioned(
                  left: node.position.dx - _nodeRadius(node),
                  top: node.position.dy - _nodeRadius(node),
                  child: GraphNodeWidget(
                    key: ValueKey(node.id),
                    node: node,
                    onTap: () => widget.onNodeTap(node),
                    onDragStart: () {
                      setState(() => _isDraggingNode = true);
                    },
                    onDragUpdate: (delta) {
                      // Scale delta by inverse of current zoom so drag
                      // matches cursor position at any zoom level.
                      final scale = _currentScale;
                      final scaledDelta = scale > 0
                          ? delta / scale
                          : delta;
                      final newPos = node.position + scaledDelta;
                      widget.onNodeDrag(node.id, newPos);
                    },
                    onDragEnd: () {
                      setState(() => _isDraggingNode = false);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  double _nodeRadius(KnowledgeNode node) {
    return 24.0 + (node.connectionCount.clamp(0, 10) * 1.5);
  }
}
