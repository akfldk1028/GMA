import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'drawing_tool_handler.dart';

/// Eraser tool — clears drawn content using BlendMode.clear.
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
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill;
}
