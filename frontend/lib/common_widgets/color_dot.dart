import 'package:flutter/material.dart';
import 'package:gma_frontend/constants/marker_colors.dart';

/// A circular colored indicator for PDF markers.
///
/// Displays a colored circle using the [MarkerColor] enum values.
/// Used to visually represent marker colors in the UI.
///
/// Example:
/// ```dart
/// ColorDot(
///   color: MarkerColor.red,
///   size: 16.0,
/// )
/// ```
class ColorDot extends StatelessWidget {
  const ColorDot({
    super.key,
    required this.color,
    this.size = 12.0,
  });

  /// The marker color to display
  final MarkerColor color;

  /// The diameter of the circular dot (default: 12.0)
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.color,
        shape: BoxShape.circle,
      ),
    );
  }
}
