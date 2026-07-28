import 'package:flutter/material.dart';

import '../../../../pdf_viewer/drawing/models/drawing_model.dart';

/// Paints panel-level strokes in canvas coords.
///
/// Lives inside the same `Transform.scale` + `SingleChildScrollView` as the
/// cards, so no manual translate or scale is needed here — the parent
/// transforms handle scrolling and zoom.
class NotebookStrokePainter extends CustomPainter {
  NotebookStrokePainter({
    required this.strokes,
    this.liveStroke,
    this.originX = 0,
    this.originY = 0,
  });

  final List<DrawingStroke> strokes;
  final DrawingStroke? liveStroke;
  // Canvas → Stack-local offset. Strokes are stored in canvas coords
  // (which can be negative if a card was dragged left); the Stack origin
  // shifts to include all cards, so we subtract the origin when painting.
  final double originX;
  final double originY;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      _drawStroke(canvas, s);
    }
    if (liveStroke != null) _drawStroke(canvas, liveStroke!);
  }

  void _drawStroke(Canvas canvas, DrawingStroke s) {
    if (s.points.length < 2) return;
    final paint = Paint()
      ..color = Color(s.colorValue)
      ..strokeWidth = s.size
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(s.points[0].x - originX, s.points[0].y - originY);
    for (var i = 1; i < s.points.length; i++) {
      path.lineTo(s.points[i].x - originX, s.points[i].y - originY);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NotebookStrokePainter old) =>
      old.strokes != strokes ||
      old.liveStroke != liveStroke ||
      old.originX != originX ||
      old.originY != originY;
}
