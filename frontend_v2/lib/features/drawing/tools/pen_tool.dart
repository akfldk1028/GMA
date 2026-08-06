import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'drawing_tool_handler.dart';

/// Standard pen tool — opaque strokes with pressure-sensitive thinning.
class PenTool extends DrawingToolHandler {
  @override
  String get id => 'pen';

  @override
  IconData get icon => Icons.edit;

  @override
  String get label => 'Pen';

  @override
  StrokeOptions getStrokeOptions({required double size}) => StrokeOptions(
        size: size,
        thinning: 0.5,
        smoothing: 0.5,
        streamline: 0.5,
      );

  @override
  Paint getPaint({required Color color}) =>
      Paint()
        ..color = color
        ..style = PaintingStyle.fill;
}
