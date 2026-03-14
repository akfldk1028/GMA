import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

/// Drawing tool plugin interface (n8n pattern).
///
/// New tool = implement this interface + register in tool_registry.dart.
/// Each tool declares its own rendering, stroke options, and capabilities.
///
/// Example:
/// ```dart
/// class MyTool implements DrawingToolHandler {
///   @override String get id => 'my-tool';
///   @override IconData get icon => Icons.star;
///   @override String get label => 'My Tool';
///   @override StrokeOptions getStrokeOptions({required double size}) => ...;
///   @override Paint getPaint({required Color color}) => ...;
/// }
/// ```
abstract class DrawingToolHandler {
  /// Tool identifier (stored in stroke data).
  String get id;

  /// Icon shown in the toolbar.
  IconData get icon;

  /// Label shown in the toolbar tooltip.
  String get label;

  /// Generate perfect_freehand StrokeOptions for this tool.
  /// Each tool can customize thinning, smoothing, simulatePressure, etc.
  StrokeOptions getStrokeOptions({required double size});

  /// Generate Paint for rendering this tool's strokes.
  /// pen=opaque, highlighter=translucent, eraser=BlendMode.clear
  Paint getPaint({required Color color});

  /// Whether this tool supports color selection.
  bool get supportsColor => true;

  /// Whether this tool supports size adjustment.
  bool get supportsSizeChange => true;
}
