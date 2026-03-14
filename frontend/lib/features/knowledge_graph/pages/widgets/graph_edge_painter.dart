import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/knowledge_graph_model.dart';

/// CustomPainter that draws bezier-curved edges between knowledge graph nodes.
class GraphEdgePainter extends CustomPainter {
  final KnowledgeGraph graph;
  final Set<String>? visibleNodeIds;

  GraphEdgePainter({required this.graph, this.visibleNodeIds});

  static const _nodeRadius = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = <String, KnowledgeNode>{};
    for (final n in graph.nodes) {
      nodeMap[n.id] = n;
    }

    for (final edge in graph.edges) {
      final from = nodeMap[edge.fromId];
      final to = nodeMap[edge.toId];
      if (from == null || to == null) continue;

      // Skip edges whose nodes are filtered out
      if (visibleNodeIds != null) {
        if (!visibleNodeIds!.contains(from.id) ||
            !visibleNodeIds!.contains(to.id)) {
          continue;
        }
      }

      final dx = to.position.dx - from.position.dx;
      final dy = to.position.dy - from.position.dy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist < 1) continue;

      final ux = dx / dist;
      final uy = dy / dist;

      // Offset start/end from node center by node radius
      final fromR = _radiusFor(from.connectionCount);
      final toR = _radiusFor(to.connectionCount);
      final start = Offset(
        from.position.dx + ux * fromR,
        from.position.dy + uy * fromR,
      );
      final end = Offset(
        to.position.dx - ux * toR,
        to.position.dy - uy * toR,
      );

      // Stroke width varies with weight (0.8 ~ 4.0)
      final strokeWidth = (edge.weight * 0.8).clamp(0.8, 4.0).toDouble();

      final paint = Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.5)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      // Quadratic bezier with slight perpendicular offset for curvature
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      final perpOffset = Offset(-uy, ux) * (dist * 0.08);
      final ctrl = mid + perpOffset;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);

      // Edge label
      if (edge.label != null && edge.label!.isNotEmpty) {
        _drawLabel(canvas, edge.label!, ctrl);
      }
    }
  }

  double _radiusFor(int connectionCount) {
    return _nodeRadius + (connectionCount.clamp(0, 10) * 1.5);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bg = Rect.fromCenter(
      center: pos,
      width: tp.width + 10,
      height: tp.height + 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(4)),
      Paint()..color = const Color(0xFFF8FAFC),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant GraphEdgePainter oldDelegate) =>
      oldDelegate.graph != graph || oldDelegate.visibleNodeIds != visibleNodeIds;
}
