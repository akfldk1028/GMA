import 'drawing_tool_handler.dart';
import 'eraser_tool.dart';
import 'pen_tool.dart';

/// Drawing tool registry — add 1 line here to register a new tool.
///
/// Same pattern as MarkdownExtension registry in markdown_config.dart.
/// Toolbar and painter only depend on DrawingToolHandler interface.
final List<DrawingToolHandler> drawingTools = [
  PenTool(),
  EraserTool(),
  // Future: LaserPointerTool(), ShapeTool(), TextAnnotationTool(), ...
];

/// Look up a tool by its ID. Falls back to PenTool if not found.
DrawingToolHandler getToolById(String id) =>
    drawingTools.firstWhere((t) => t.id == id, orElse: () => PenTool());
