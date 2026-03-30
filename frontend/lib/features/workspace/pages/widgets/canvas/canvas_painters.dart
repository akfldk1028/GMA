import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../pdf_viewer/drawing/models/drawing_model.dart';
import 'group_edit_dialog.dart';

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

/// Infinite vertical canvas with subtle grid.
/// Obsidian-style: endless scroll, PDF export auto-paginates at A4 height.
class NotebookBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Clean white background
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFFBFBFB));

    // Horizontal lines
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
      for (double y = 24; y < size.height; y += 24) {
        canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Paints group edit strokes on the main canvas with offset + scale.
///
/// Strokes are drawn relative to the edit-time origin, then scaled to match
/// the current group bounding box size and positioned at the current origin.
class GroupStrokePainter extends CustomPainter {
  GroupStrokePainter({
    required this.strokes,
    required this.editOriginX,
    required this.editOriginY,
    required this.canvasOriginX,
    required this.canvasOriginY,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.rotation = 0.0,
    this.centerX = 0.0,
    this.centerY = 0.0,
  });

  final List<StrokeData> strokes;
  final double editOriginX;
  final double editOriginY;
  final double canvasOriginX;
  final double canvasOriginY;
  final double scaleX;
  final double scaleY;
  /// Rotation angle in radians around (centerX, centerY).
  final double rotation;
  final double centerX;
  final double centerY;

  @override
  void paint(Canvas canvas, Size size) {
    // Apply rotation around group center if needed
    if (rotation != 0.0) {
      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(rotation);
      canvas.translate(-centerX, -centerY);
    }

    for (final s in strokes) {
      if (s.points.length < 2) continue;
      final paint = Paint()
        ..color = Color(s.color)
        ..strokeWidth = s.size * ((scaleX + scaleY) / 2)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      final p0 = _transform(s.points[0]);
      path.moveTo(p0.dx, p0.dy);
      for (var i = 1; i < s.points.length; i++) {
        final pt = _transform(s.points[i]);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, paint);
    }

    if (rotation != 0.0) {
      canvas.restore();
    }
  }

  Offset _transform(Offset pt) {
    return Offset(
      canvasOriginX + (pt.dx - editOriginX) * scaleX,
      canvasOriginY + (pt.dy - editOriginY) * scaleY,
    );
  }

  @override
  bool shouldRepaint(covariant GroupStrokePainter old) => true;
}
