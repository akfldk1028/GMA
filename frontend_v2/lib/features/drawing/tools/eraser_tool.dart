import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../models/drawing_model.dart';
import 'drawing_tool_handler.dart';

/// Eraser tool — removes strokes by hit-test rather than BlendMode.clear.
/// Implements AC-09: eraser detects and removes strokes by proximity.
class EraserTool extends DrawingToolHandler {
  @override
  String get id => 'eraser';

  @override
  IconData get icon => Icons.auto_fix_high;

  @override
  String get label => 'Eraser';

  @override
  bool get supportsColor => false;

  @override
  StrokeOptions getStrokeOptions({required double size}) => StrokeOptions(
        size: size * 2,
        thinning: 0,
        smoothing: 0.5,
        streamline: 0.5,
      );

  @override
  Paint getPaint({required Color color}) =>
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.fill;

  /// Returns true if the pointer position is within [eraserSize] radius
  /// of any point in [stroke]. Coordinates are normalized (0.0-1.0).
  bool isStrokeHit({
    required DrawingStroke stroke,
    required double pointerX,
    required double pointerY,
    required double eraserSize,
  }) {
    if (stroke.points.isEmpty) return false;

    for (final point in stroke.points) {
      final dx = point.x - pointerX;
      final dy = point.y - pointerY;
      final distance = math.sqrt(dx * dx + dy * dy);
      if (distance <= eraserSize) {
        return true;
      }
    }
    return false;
  }

  /// Returns [strokes] with any stroke within [eraserSize] of the pointer removed.
  List<DrawingStroke> filterHitStrokes({
    required List<DrawingStroke> strokes,
    required double pointerX,
    required double pointerY,
    required double eraserSize,
  }) {
    return strokes
        .where(
          (stroke) => !isStrokeHit(
            stroke: stroke,
            pointerX: pointerX,
            pointerY: pointerY,
            eraserSize: eraserSize,
          ),
        )
        .toList();
  }
}
