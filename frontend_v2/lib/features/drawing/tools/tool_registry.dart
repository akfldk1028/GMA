import 'drawing_tool_handler.dart';
import 'eraser_tool.dart';
import 'highlighter_tool.dart';
import 'pen_tool.dart';

/// Drawing tool registry — add 1 line here to register a new tool.
final List<DrawingToolHandler> drawingTools = [
  PenTool(),
  HighlighterTool(),
  EraserTool(),
];

/// Look up a tool by its ID. Falls back to PenTool if not found.
DrawingToolHandler getToolById(String id) =>
    drawingTools.firstWhere((t) => t.id == id, orElse: () => PenTool());
