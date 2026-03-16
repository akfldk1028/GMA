import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/tools/highlighter_tool.dart';

void main() {
  late HighlighterTool highlighterTool;

  setUp(() {
    highlighterTool = HighlighterTool();
  });

  group('HighlighterTool', () {
    test('has correct id', () {
      expect(highlighterTool.id, 'highlighter');
    });

    test('has correct label', () {
      expect(highlighterTool.label, 'Highlighter');
    });

    test('supports color', () {
      expect(highlighterTool.supportsColor, isTrue);
    });

    test('supports size change', () {
      expect(highlighterTool.supportsSizeChange, isTrue);
    });

    group('getStrokeOptions', () {
      test('size is 3x the input size', () {
        final opts = highlighterTool.getStrokeOptions(size: 4.0);
        expect(opts.size, 12.0); // 4.0 * 3
      });

      test('has zero thinning', () {
        final opts = highlighterTool.getStrokeOptions(size: 3.0);
        expect(opts.thinning, 0.0);
      });

      test('has smoothing of 0.5', () {
        final opts = highlighterTool.getStrokeOptions(size: 3.0);
        expect(opts.smoothing, 0.5);
      });

      test('has streamline of 0.5', () {
        final opts = highlighterTool.getStrokeOptions(size: 3.0);
        expect(opts.streamline, 0.5);
      });
    });

    group('getPaint', () {
      test('returns fill paint', () {
        final paint = highlighterTool.getPaint(color: Colors.yellow);
        expect(paint.style, PaintingStyle.fill);
      });

      test('has opacity of approximately 0.3', () {
        final paint = highlighterTool.getPaint(color: Colors.yellow);
        // Alpha should be approximately 0.3 (77/255 ≈ 0.302)
        expect(paint.color.a, closeTo(0.3, 0.05));
      });

      test('preserves hue of provided color', () {
        final paint = highlighterTool.getPaint(color: Colors.yellow);
        // Color should still be yellowish (red and green channels high, blue low)
        expect(paint.color.r, greaterThan(0.5));
      });
    });
  });
}
