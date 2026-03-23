import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../pdf_viewer/drawing/models/drawing_model.dart';

/// Paints strokes using absolute canvas coordinates (not normalized).
class AbsoluteStrokePainter extends CustomPainter {
  AbsoluteStrokePainter({required this.strokes, this.liveStroke});
  final List<DrawingStroke> strokes;
  final DrawingStroke? liveStroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawAbsStroke(canvas, stroke);
    }
    if (liveStroke != null) {
      _drawAbsStroke(canvas, liveStroke!);
    }
  }

  void _drawAbsStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) return;
    final paint = Paint()
      ..color = Color(stroke.colorValue)
      ..strokeWidth = stroke.size
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(stroke.points[0].x, stroke.points[0].y);
    for (var i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].x, stroke.points[i].y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AbsoluteStrokePainter old) => true;
}

/// Notebook-style background with horizontal lines and dot grid.
class NotebookBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFFBFBFB));

    final linePaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.5;
    for (double y = 24; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Subtle dot grid
    final dotPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (double x = 24; x < size.width; x += 24) {
      for (double y = 24; y < min(size.height, 600); y += 24) {
        canvas.drawPoints(
            ui.PointMode.points, [Offset(x, y)], dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
