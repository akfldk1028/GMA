import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/mindmap_model.dart';

/// Horizontal tree layout painter for mindmap.
class MindmapCanvasPainter extends CustomPainter {
  final MindmapNode root;
  final Color accentColor;

  MindmapCanvasPainter({required this.root, required this.accentColor});

  static const nodeH = 28.0;
  static const nodeMinW = 60.0;
  static const nodeMaxW = 160.0;
  static const nodePadH = 12.0;
  static const hGap = 32.0;
  static const vGap = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final positions = <MindmapNode, Rect>{};
    _layout(root, 24.0, 16.0, positions);
    _drawConnections(canvas, root, positions);
    _drawNodes(canvas, root, positions);
  }

  /// Recursive layout: returns the total height used by this subtree.
  double _layout(
    MindmapNode node,
    double x,
    double y,
    Map<MindmapNode, Rect> positions,
  ) {
    final w = _measureWidth(node.label);

    if (node.children.isEmpty) {
      positions[node] = Rect.fromLTWH(x, y, w, nodeH);
      return nodeH;
    }

    final childX = x + w + hGap;
    double childY = y;
    double totalChildHeight = 0;

    for (int i = 0; i < node.children.length; i++) {
      final ch = _layout(node.children[i], childX, childY, positions);
      childY += ch + vGap;
      totalChildHeight += ch;
      if (i < node.children.length - 1) totalChildHeight += vGap;
    }

    final thisHeight = max(nodeH, totalChildHeight);
    final centerY = y + thisHeight / 2 - nodeH / 2;
    positions[node] = Rect.fromLTWH(x, centerY, w, nodeH);

    return thisHeight;
  }

  double _measureWidth(String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 12)),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: nodeMaxW);
    return (tp.width + nodePadH * 2).clamp(nodeMinW, nodeMaxW);
  }

  void _drawConnections(
    Canvas canvas,
    MindmapNode node,
    Map<MindmapNode, Rect> positions,
  ) {
    final from = positions[node];
    if (from == null) return;

    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final child in node.children) {
      final to = positions[child];
      if (to == null) continue;

      final startX = from.right;
      final startY = from.center.dy;
      final endX = to.left;
      final endY = to.center.dy;

      final midX = (startX + endX) / 2;
      final path = Path()
        ..moveTo(startX, startY)
        ..cubicTo(midX, startY, midX, endY, endX, endY);
      canvas.drawPath(path, paint);

      _drawConnections(canvas, child, positions);
    }
  }

  void _drawNodes(
    Canvas canvas,
    MindmapNode node,
    Map<MindmapNode, Rect> positions,
  ) {
    final rect = positions[node];
    if (rect == null) return;

    final isRoot = node == root;
    final fillColor = isRoot
        ? accentColor.withValues(alpha: 0.15)
        : accentColor.withValues(alpha: 0.06);
    final borderColor = isRoot ? accentColor : accentColor.withValues(alpha: 0.4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = fillColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isRoot ? 2.0 : 1.0,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: node.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isRoot ? FontWeight.w600 : FontWeight.w400,
          color: const Color(0xFF1E293B),
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '\u2026',
    )..layout(maxWidth: rect.width - nodePadH);
    tp.paint(
      canvas,
      Offset(
        rect.center.dx - tp.width / 2,
        rect.center.dy - tp.height / 2,
      ),
    );

    for (final child in node.children) {
      _drawNodes(canvas, child, positions);
    }
  }

  /// Compute total size needed for the tree.
  static Size computeSize(MindmapNode root) {
    final positions = <MindmapNode, Rect>{};
    final painter = MindmapCanvasPainter(
      root: root,
      accentColor: const Color(0xFF14B8A6),
    );
    final h = painter._layout(root, 24.0, 16.0, positions);
    double maxRight = 0;
    for (final r in positions.values) {
      if (r.right > maxRight) maxRight = r.right;
    }
    return Size(maxRight + 24, h + 32);
  }

  @override
  bool shouldRepaint(covariant MindmapCanvasPainter oldDelegate) =>
      oldDelegate.root != root || oldDelegate.accentColor != accentColor;
}
