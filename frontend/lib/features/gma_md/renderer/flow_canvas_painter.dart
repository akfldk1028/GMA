import 'dart:math';

import 'package:flutter/material.dart';

import '../models/flow_graph_model.dart';

class FlowCanvasPainter extends CustomPainter {
  final FlowGraph graph;

  FlowCanvasPainter({required this.graph});

  static const minNodeWidth = 80.0;
  static const maxNodeWidth = 200.0;
  static const nodeHeight = 36.0;
  static const verticalSpacing = 50.0;
  static const padding = 24.0;
  static const nodePaddingH = 16.0;

  /// Measure all node sizes using TextPainter, store in computedSize.
  static void measureNodes(List<FlowNode> nodes) {
    for (final node in nodes) {
      final tp = TextPainter(
        text: TextSpan(
          text: node.label,
          style: const TextStyle(fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        textAlign: TextAlign.center,
      )..layout(maxWidth: maxNodeWidth - nodePaddingH);

      final w = (tp.width + nodePaddingH * 2).clamp(minNodeWidth, maxNodeWidth);
      final h = max(nodeHeight, tp.height + 16);
      node.computedSize = Size(w, h);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawEdges(canvas);
    _drawNodes(canvas);
  }

  void _drawNodes(Canvas canvas) {
    for (final node in graph.nodes) {
      final w = node.computedSize.width > 0 ? node.computedSize.width : minNodeWidth;
      final h = node.computedSize.height > 0 ? node.computedSize.height : nodeHeight;
      final rect = Rect.fromCenter(center: node.position, width: w, height: h);
      _drawNodeShape(canvas, node, rect);
      _drawNodeText(canvas, node, rect);
    }
  }

  void _drawNodeShape(Canvas canvas, FlowNode node, Rect rect) {
    final fillPaint = Paint()..color = const Color(0xFFF0F4FF);
    final strokePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (node.shape) {
      case NodeShape.rectangle:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          fillPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          strokePaint,
        );
      case NodeShape.oval:
        canvas.drawOval(rect, fillPaint);
        canvas.drawOval(rect, strokePaint);
      case NodeShape.roundedRect:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(14)),
          fillPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(14)),
          strokePaint,
        );
      case NodeShape.diamond:
        final path = Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.center.dy)
          ..lineTo(rect.center.dx, rect.bottom)
          ..lineTo(rect.left, rect.center.dy)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
    }
  }

  void _drawNodeText(Canvas canvas, FlowNode node, Rect rect) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: rect.width - 12);
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawEdges(Canvas canvas) {
    final nodeMap = {for (final n in graph.nodes) n.id: n};

    for (final edge in graph.edges) {
      final from = nodeMap[edge.fromId];
      final to = nodeMap[edge.toId];
      if (from == null || to == null) continue;

      final fromH = from.computedSize.height > 0 ? from.computedSize.height : nodeHeight;
      final toH = to.computedSize.height > 0 ? to.computedSize.height : nodeHeight;

      final startY = from.position.dy + fromH / 2;
      final endY = to.position.dy - toH / 2;
      final startX = from.position.dx;
      final endX = to.position.dx;
      final start = Offset(startX, startY);
      final end = Offset(endX, endY);

      final paint = Paint()
        ..color = const Color(0xFF6366F1)
        ..strokeWidth = _strokeWidth(edge.type)
        ..style = PaintingStyle.stroke;

      if (edge.type == EdgeType.weak) {
        _drawDashedLine(canvas, start, end, paint);
      } else {
        // Bezier curve when nodes aren't vertically aligned
        final dx = (endX - startX).abs();
        if (dx > 10) {
          _drawBezierEdge(canvas, start, end, paint);
        } else {
          canvas.drawLine(start, end, paint);
        }
      }

      // Arrowhead (forward)
      if (edge.type != EdgeType.undirected) {
        _drawArrowhead(canvas, start, end, paint);
      }
      // Arrowhead (backward for bidirectional)
      if (edge.type == EdgeType.bidirectional) {
        _drawArrowhead(canvas, end, start, paint);
      }

      // Edge label
      if (edge.label != null && edge.label!.isNotEmpty) {
        final mid = Offset((startX + endX) / 2, (startY + endY) / 2);
        _drawEdgeLabel(canvas, edge.label!, mid);
      }
    }
  }

  void _drawBezierEdge(Canvas canvas, Offset start, Offset end, Paint paint) {
    final midY = (start.dy + end.dy) / 2;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(start.dx, midY, end.dx, midY, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  double _strokeWidth(EdgeType type) {
    switch (type) {
      case EdgeType.emphasis:
        return 3.0;
      case EdgeType.weak:
        return 1.0;
      default:
        return 1.5;
    }
  }

  void _drawArrowhead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowSize = 8.0;
    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        to.dx - arrowSize * cos(angle - pi / 6),
        to.dy - arrowSize * sin(angle - pi / 6),
      )
      ..lineTo(
        to.dx - arrowSize * cos(angle + pi / 6),
        to.dy - arrowSize * sin(angle + pi / 6),
      )
      ..close();
    canvas.drawPath(path, arrowPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final distance = sqrt(dx * dx + dy * dy);
    if (distance == 0) return;
    final unitX = dx / distance;
    final unitY = dy / distance;

    var current = 0.0;
    while (current < distance) {
      final s = Offset(from.dx + unitX * current, from.dy + unitY * current);
      current += dashWidth;
      if (current > distance) current = distance;
      final e = Offset(from.dx + unitX * current, from.dy + unitY * current);
      canvas.drawLine(s, e, paint);
      current += dashSpace;
    }
  }

  void _drawEdgeLabel(Canvas canvas, String label, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bg = Rect.fromCenter(
      center: position,
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(3)),
      Paint()..color = const Color(0xFFFAFAFA),
    );
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant FlowCanvasPainter oldDelegate) =>
      oldDelegate.graph != graph;
}
