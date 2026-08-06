import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/models/drawing_model.dart';
import 'package:gma_app/features/drawing/pages/widgets/stroke_painter.dart';

void main() {
  group('StrokePainter shouldRepaint', () {
    const stroke1 = DrawingStroke(
      id: 's1',
      pageNumber: 1,
      points: [StrokePoint(x: 0.1, y: 0.2)],
      toolId: 'pen',
    );

    const stroke2 = DrawingStroke(
      id: 's2',
      pageNumber: 1,
      points: [StrokePoint(x: 0.3, y: 0.4)],
      toolId: 'pen',
    );

    test('returns false when strokes and currentStroke are identical', () {
      final painter1 = StrokePainter(
        strokes: const [stroke1],
        currentStroke: stroke2,
      );
      final painter2 = StrokePainter(
        strokes: const [stroke1],
        currentStroke: stroke2,
      );
      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('returns true when strokes list changes', () {
      final painter1 = StrokePainter(
        strokes: const [stroke1],
      );
      final painter2 = StrokePainter(
        strokes: const [stroke1, stroke2],
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('returns true when currentStroke changes', () {
      final painter1 = StrokePainter(
        strokes: const [],
        currentStroke: stroke1,
      );
      final painter2 = StrokePainter(
        strokes: const [],
        currentStroke: stroke2,
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('returns true when currentStroke goes from null to non-null', () {
      final painter1 = StrokePainter(
        strokes: const [],
        currentStroke: null,
      );
      final painter2 = StrokePainter(
        strokes: const [],
        currentStroke: stroke1,
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('returns false when both painters have same null currentStroke', () {
      final painter1 = StrokePainter(strokes: const []);
      final painter2 = StrokePainter(strokes: const []);
      expect(painter1.shouldRepaint(painter2), isFalse);
    });
  });

  group('StrokePainter initialization', () {
    test('creates with empty strokes and null currentStroke', () {
      final painter = StrokePainter(strokes: const []);
      expect(painter.strokes, isEmpty);
      expect(painter.currentStroke, isNull);
    });

    test('creates with strokes and currentStroke', () {
      const stroke = DrawingStroke(
        id: 's1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );
      final painter = StrokePainter(
        strokes: const [stroke],
        currentStroke: stroke,
      );
      expect(painter.strokes, hasLength(1));
      expect(painter.currentStroke, stroke);
    });
  });
}
