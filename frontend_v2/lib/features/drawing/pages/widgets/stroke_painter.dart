import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../../models/drawing_model.dart';
import '../../tools/tool_registry.dart';

/// CustomPainter that renders drawing strokes using perfect_freehand.
///
/// Uses DrawingToolHandler interface — no knowledge of specific tool types.
/// Normalized coordinates (0-1) are scaled to canvas size.
class StrokePainter extends CustomPainter {
  StrokePainter({
    required this.strokes,
    this.currentStroke,
  });

  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, size, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, size, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, Size size, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final tool = getToolById(stroke.toolId);
    final options = tool.getStrokeOptions(size: stroke.size);
    final paint = tool.getPaint(color: Color(stroke.colorValue));

    // Convert normalized points to canvas-scaled PointVectors
    final points = stroke.points
        .map(
          (p) => PointVector(
            p.x * size.width,
            p.y * size.height,
            p.pressure ?? 0.5,
          ),
        )
        .toList();

    // Generate smooth outline via perfect_freehand
    final outlinePoints = getStroke(points, options: options);
    if (outlinePoints.isEmpty) return;

    // Build path from outline
    final path = Path();
    if (outlinePoints.length == 1) {
      path.addOval(Rect.fromCircle(
        center: outlinePoints.first,
        radius: options.size / 2,
      ));
    } else {
      path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
      for (int i = 1; i < outlinePoints.length - 1; i++) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.currentStroke != currentStroke;
}
