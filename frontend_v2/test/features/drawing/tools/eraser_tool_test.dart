import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/models/drawing_model.dart';
import 'package:gma_app/features/drawing/tools/eraser_tool.dart';

void main() {
  late EraserTool eraserTool;

  setUp(() {
    eraserTool = EraserTool();
  });

  group('EraserTool', () {
    test('has correct id', () {
      expect(eraserTool.id, 'eraser');
    });

    test('has correct label', () {
      expect(eraserTool.label, 'Eraser');
    });

    test('does not support color', () {
      expect(eraserTool.supportsColor, isFalse);
    });

    test('supports size change', () {
      expect(eraserTool.supportsSizeChange, isTrue);
    });

    group('getStrokeOptions', () {
      test('size is 2x the input size', () {
        final opts = eraserTool.getStrokeOptions(size: 5.0);
        expect(opts.size, 10.0); // 5.0 * 2
      });

      test('has zero thinning', () {
        final opts = eraserTool.getStrokeOptions(size: 3.0);
        expect(opts.thinning, 0.0);
      });

      test('has smoothing of 0.5', () {
        final opts = eraserTool.getStrokeOptions(size: 3.0);
        expect(opts.smoothing, 0.5);
      });

      test('has streamline of 0.5', () {
        final opts = eraserTool.getStrokeOptions(size: 3.0);
        expect(opts.streamline, 0.5);
      });
    });

    group('getPaint', () {
      test('returns fill paint', () {
        final paint = eraserTool.getPaint(color: Colors.transparent);
        expect(paint.style, PaintingStyle.fill);
      });
    });

    group('hit-test logic (AC-09)', () {
      // Creates a stroke with points forming a horizontal line
      DrawingStroke makeHorizontalStroke({
        required String id,
        required int pageNumber,
        required double y,
        double xStart = 0.1,
        double xEnd = 0.9,
      }) {
        return DrawingStroke(
          id: id,
          pageNumber: pageNumber,
          points: [
            StrokePoint(x: xStart, y: y),
            StrokePoint(x: 0.5, y: y),
            StrokePoint(x: xEnd, y: y),
          ],
          toolId: 'pen',
        );
      }

      test('isStrokeHit returns true when pointer is within proximity', () {
        final stroke = makeHorizontalStroke(id: 's1', pageNumber: 1, y: 0.5);
        // Pointer at (0.5, 0.5) is exactly on the stroke
        final hit = eraserTool.isStrokeHit(
          stroke: stroke,
          pointerX: 0.5,
          pointerY: 0.5,
          eraserSize: 0.05,
        );
        expect(hit, isTrue);
      });

      test('isStrokeHit returns false when pointer is far from stroke', () {
        final stroke = makeHorizontalStroke(id: 's1', pageNumber: 1, y: 0.5);
        // Pointer at (0.5, 0.9) is far from the stroke at y=0.5
        final hit = eraserTool.isStrokeHit(
          stroke: stroke,
          pointerX: 0.5,
          pointerY: 0.9,
          eraserSize: 0.05,
        );
        expect(hit, isFalse);
      });

      test('isStrokeHit uses eraserSize as proximity radius', () {
        final stroke = makeHorizontalStroke(id: 's1', pageNumber: 1, y: 0.5);
        // Pointer at (0.5, 0.52) is within 0.05 radius of stroke at y=0.5
        final hitWithLargeEraser = eraserTool.isStrokeHit(
          stroke: stroke,
          pointerX: 0.5,
          pointerY: 0.52,
          eraserSize: 0.05,
        );
        expect(hitWithLargeEraser, isTrue);

        // Same pointer with tiny eraser should miss
        final missWithSmallEraser = eraserTool.isStrokeHit(
          stroke: stroke,
          pointerX: 0.5,
          pointerY: 0.52,
          eraserSize: 0.01,
        );
        expect(missWithSmallEraser, isFalse);
      });

      test('isStrokeHit returns false for empty stroke', () {
        const emptyStroke = DrawingStroke(
          id: 'empty',
          pageNumber: 1,
          points: [],
          toolId: 'pen',
        );
        final hit = eraserTool.isStrokeHit(
          stroke: emptyStroke,
          pointerX: 0.5,
          pointerY: 0.5,
          eraserSize: 0.1,
        );
        expect(hit, isFalse);
      });

      test('filterHitStrokes removes strokes within proximity', () {
        final strokes = [
          makeHorizontalStroke(id: 's1', pageNumber: 1, y: 0.5),
          makeHorizontalStroke(id: 's2', pageNumber: 1, y: 0.8),
          makeHorizontalStroke(id: 's3', pageNumber: 1, y: 0.2),
        ];

        // Pointer at y=0.5 should only erase s1
        final remaining = eraserTool.filterHitStrokes(
          strokes: strokes,
          pointerX: 0.5,
          pointerY: 0.5,
          eraserSize: 0.05,
        );

        expect(remaining, hasLength(2));
        expect(remaining.any((s) => s.id == 's1'), isFalse);
        expect(remaining.any((s) => s.id == 's2'), isTrue);
        expect(remaining.any((s) => s.id == 's3'), isTrue);
      });
    });
  });
}
