import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/tools/pen_tool.dart';

void main() {
  late PenTool penTool;

  setUp(() {
    penTool = PenTool();
  });

  group('PenTool', () {
    test('has correct id', () {
      expect(penTool.id, 'pen');
    });

    test('has correct label', () {
      expect(penTool.label, 'Pen');
    });

    test('supports color', () {
      expect(penTool.supportsColor, isTrue);
    });

    test('supports size change', () {
      expect(penTool.supportsSizeChange, isTrue);
    });

    group('getStrokeOptions', () {
      test('returns options with correct size', () {
        final opts = penTool.getStrokeOptions(size: 5.0);
        expect(opts.size, 5.0);
      });

      test('has thinning of 0.5', () {
        final opts = penTool.getStrokeOptions(size: 3.0);
        expect(opts.thinning, 0.5);
      });

      test('has smoothing of 0.5', () {
        final opts = penTool.getStrokeOptions(size: 3.0);
        expect(opts.smoothing, 0.5);
      });

      test('has streamline of 0.5', () {
        final opts = penTool.getStrokeOptions(size: 3.0);
        expect(opts.streamline, 0.5);
      });
    });

    group('getPaint', () {
      test('returns fill paint', () {
        final paint = penTool.getPaint(color: Colors.black);
        expect(paint.style, PaintingStyle.fill);
      });

      test('uses provided color', () {
        const color = Color(0xFFFF0000);
        final paint = penTool.getPaint(color: color);
        expect(paint.color, color);
      });

      test('is fully opaque', () {
        final paint = penTool.getPaint(color: Colors.black);
        expect(paint.color.a, 1.0);
      });
    });
  });
}
