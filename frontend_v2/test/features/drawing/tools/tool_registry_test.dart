import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/tools/eraser_tool.dart';
import 'package:gma_app/features/drawing/tools/highlighter_tool.dart';
import 'package:gma_app/features/drawing/tools/pen_tool.dart';
import 'package:gma_app/features/drawing/tools/tool_registry.dart';

void main() {
  group('drawingTools registry', () {
    test('contains 3 tools', () {
      expect(drawingTools, hasLength(3));
    });

    test('contains pen, highlighter, and eraser', () {
      final ids = drawingTools.map((t) => t.id).toList();
      expect(ids, containsAll(['pen', 'highlighter', 'eraser']));
    });

    test('tools have correct types', () {
      expect(drawingTools[0], isA<PenTool>());
      expect(drawingTools[1], isA<HighlighterTool>());
      expect(drawingTools[2], isA<EraserTool>());
    });
  });

  group('getToolById', () {
    test('returns pen tool by id', () {
      final tool = getToolById('pen');
      expect(tool, isA<PenTool>());
      expect(tool.id, 'pen');
    });

    test('returns highlighter tool by id', () {
      final tool = getToolById('highlighter');
      expect(tool, isA<HighlighterTool>());
      expect(tool.id, 'highlighter');
    });

    test('returns eraser tool by id', () {
      final tool = getToolById('eraser');
      expect(tool, isA<EraserTool>());
      expect(tool.id, 'eraser');
    });

    test('falls back to pen for unknown id', () {
      final tool = getToolById('unknown-tool-xyz');
      expect(tool, isA<PenTool>());
    });

    test('falls back to pen for empty string', () {
      final tool = getToolById('');
      expect(tool, isA<PenTool>());
    });
  });
}
