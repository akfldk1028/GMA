import 'dart:math';

import 'package:flutter/material.dart';

import '../models/flow_graph_model.dart';

/// Circular layout graph painter — same data model as flow, different layout.
class GraphCanvasPainter extends CustomPainter {
  final FlowGraph graph;

  GraphCanvasPainter({required this.graph});

  static const nodeRadius = 28.0;
  static const nodePadH = 12.0;
  static const nodeMinW = 70.0;
  static const nodeMaxW = 140.0;
  static const nodeH = 32.0;

  /// Position nodes in a circle. Call before painting.
  static void layoutCircular(FlowGraph graph, Size canvasSize) {
    final nodes = graph.nodes;
    if (nodes.isEmpty) return;

    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;

    if (nodes.length == 1) {
      nodes[0].position = Offset(cx, cy);
      return;
    }

    final radius = min(cx, cy) - 60;
    for (int i = 0; i < nodes.length; i++) {
      final angle = 2 * pi * i / nodes.length - pi / 2;
      nodes[i].position = Offset(
        cx + radius * cos(angle),
        cy + radius * sin(angle),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawEdges(canvas);
    _drawNodes(canvas);
  }

  void _drawNodes(Canvas canvas) {
    for (final node in graph.nodes) {
      final w = _measureWidth(node.label);
      final rect = Rect.fromCenter(center: node.position, width: w, height: nodeH);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)),
        Paint()..color = const Color(0xFFF3EEFF),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)),
        Paint()
          ..color = const Color(0xFF8B5CF6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: node.label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B)),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '\u2026',
      )..layout(maxWidth: w - nodePadH);
      tp.paint(
        canvas,
        Offset(
          rect.center.dx - tp.width / 2,
          rect.center.dy - tp.height / 2,
        ),
      );
    }
  }

  void _drawEdges(Canvas canvas) {
    final nodeMap = {for (final n in graph.nodes) n.id: n};

    for (final edge in graph.edges) {
      final from = nodeMap[edge.fromId];
      final to = nodeMap[edge.toId];
      if (from == null || to == null) continue;

      final fromW = _measureWidth(from.label) / 2;
      final toW = _measureWidth(to.label) / 2;

      // Start/end at node edge
      final dx = to.position.dx - from.position.dx;
      final dy = to.position.dy - from.position.dy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist == 0) continue;

      final ux = dx / dist;
      final uy = dy / dist;
      final start = Offset(from.position.dx + ux * fromW, from.position.dy + uy * nodeH / 2);
      final end = Offset(to.position.dx - ux * toW, to.position.dy - uy * nodeH / 2);

      final paint = Paint()
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, paint);

      // Arrow
      if (edge.type != EdgeType.undirected) {
        _drawArrow(canvas, start, end, paint.color);
      }
      if (edge.type == EdgeType.bidirectional) {
        _drawArrow(canvas, end, start, paint.color);
      }

      // Label
      if (edge.label != null && edge.label!.isNotEmpty) {
        final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        _drawLabel(canvas, edge.label!, mid);
      }
    }
  }

  double _measureWidth(String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: nodeMaxW);
    return (tp.width + nodePadH * 2).clamp(nodeMinW, nodeMaxW);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    const size = 7.0;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - size * cos(angle - pi / 6), to.dy - size * sin(angle - pi / 6))
      ..lineTo(to.dx - size * cos(angle + pi / 6), to.dy - size * sin(angle + pi / 6))
      ..close();
    canvas.drawPath(path, Paint()..color = color);
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
      width: tp.width + 8,
      height: tp.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(3)),
      Paint()..color = const Color(0xFFFAFAFA),
    );
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant GraphCanvasPainter oldDelegate) =>
      oldDelegate.graph != graph;
}
