import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'drawing_tool_handler.dart';

/// Highlighter tool — wide, translucent strokes with no thinning.
class HighlighterTool extends DrawingToolHandler {
  @override
  String get id => 'highlighter';

  @override
  IconData get icon => Icons.brush;

  @override
  String get label => 'Highlighter';

  @override
  StrokeOptions getStrokeOptions({required double size}) => StrokeOptions(
        size: size * 3,
        thinning: 0,
        smoothing: 0.5,
        streamline: 0.5,
      );

  @override
  Paint getPaint({required Color color}) =>
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
}
