import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

/// Drawing tool plugin interface (n8n pattern).
///
/// New tool = implement this interface + register in tool_registry.dart.
/// Each tool declares its own rendering, stroke options, and capabilities.
abstract class DrawingToolHandler {
  /// Tool identifier (stored in stroke data).
  String get id;

  /// Icon shown in the toolbar.
  IconData get icon;

  /// Label shown in the toolbar tooltip.
  String get label;

  /// Generate perfect_freehand StrokeOptions for this tool.
  StrokeOptions getStrokeOptions({required double size});

  /// Generate Paint for rendering this tool's strokes.
  Paint getPaint({required Color color});

  /// Whether this tool supports color selection.
  bool get supportsColor => true;

  /// Whether this tool supports size adjustment.
  bool get supportsSizeChange => true;
}
