import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/models/drawing_model.dart';

void main() {
  group('StrokePoint', () {
    test('creates with required fields', () {
      const point = StrokePoint(x: 0.5, y: 0.3);
      expect(point.x, 0.5);
      expect(point.y, 0.3);
      expect(point.pressure, isNull);
    });

    test('creates with optional pressure', () {
      const point = StrokePoint(x: 0.1, y: 0.9, pressure: 0.8);
      expect(point.pressure, 0.8);
    });

    test('equality works', () {
      const a = StrokePoint(x: 0.5, y: 0.3);
      const b = StrokePoint(x: 0.5, y: 0.3);
      expect(a, equals(b));
    });

    test('copyWith creates modified copy', () {
      const point = StrokePoint(x: 0.5, y: 0.3);
      final updated = point.copyWith(pressure: 0.7);
      expect(updated.x, 0.5);
      expect(updated.y, 0.3);
      expect(updated.pressure, 0.7);
    });

    test('JSON round-trip', () {
      const point = StrokePoint(x: 0.25, y: 0.75, pressure: 0.5);
      // Use jsonEncode/jsonDecode for proper serialization
      final jsonStr = jsonEncode(point.toJson());
      final restored = StrokePoint.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(restored, equals(point));
    });
  });

  group('DrawingStroke', () {
    test('creates with required fields and defaults', () {
      const stroke = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );
      expect(stroke.id, 'stroke-1');
      expect(stroke.pageNumber, 1);
      expect(stroke.points, isEmpty);
      expect(stroke.toolId, 'pen');
      expect(stroke.colorValue, 0xFF000000); // default black
      expect(stroke.size, 3.0); // default size
    });

    test('creates with custom color and size', () {
      const stroke = DrawingStroke(
        id: 'stroke-2',
        pageNumber: 2,
        points: [],
        toolId: 'highlighter',
        colorValue: 0xFFFF0000,
        size: 8.0,
      );
      expect(stroke.colorValue, 0xFFFF0000);
      expect(stroke.size, 8.0);
    });

    test('equality works', () {
      const a = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );
      const b = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );
      expect(a, equals(b));
    });

    test('copyWith creates modified copy', () {
      const stroke = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );
      final updated = stroke.copyWith(pageNumber: 3, size: 5.0);
      expect(updated.id, 'stroke-1');
      expect(updated.pageNumber, 3);
      expect(updated.size, 5.0);
    });

    test('JSON round-trip preserves all fields', () {
      const stroke = DrawingStroke(
        id: 'stroke-abc',
        pageNumber: 2,
        points: [
          StrokePoint(x: 0.1, y: 0.2),
          StrokePoint(x: 0.3, y: 0.4, pressure: 0.6),
        ],
        toolId: 'pen',
        colorValue: 0xFF0000FF,
        size: 4.0,
      );
      // Use jsonEncode/jsonDecode to ensure proper nested serialization
      final jsonStr = jsonEncode({
        ...stroke.toJson(),
        'points': stroke.points.map((p) => p.toJson()).toList(),
      });
      final restored = DrawingStroke.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(restored, equals(stroke));
    });
  });

  group('DrawingToolState', () {
    test('creates with defaults', () {
      const state = DrawingToolState();
      expect(state.isActive, isFalse);
      expect(state.currentToolId, 'pen');
      expect(state.colorValue, 0xFF000000);
      expect(state.strokeSize, 3.0);
    });

    test('copyWith updates fields', () {
      const state = DrawingToolState();
      final updated = state.copyWith(
        isActive: true,
        currentToolId: 'highlighter',
        colorValue: 0xFFFF0000,
        strokeSize: 8.0,
      );
      expect(updated.isActive, isTrue);
      expect(updated.currentToolId, 'highlighter');
      expect(updated.colorValue, 0xFFFF0000);
      expect(updated.strokeSize, 8.0);
    });

    test('equality works', () {
      const a = DrawingToolState();
      const b = DrawingToolState();
      expect(a, equals(b));
    });
  });

  group('DrawingData', () {
    test('creates with defaults', () {
      const data = DrawingData();
      expect(data.pageStrokes, isEmpty);
      expect(data.undoStack, isEmpty);
    });

    test('copyWith adds page strokes', () {
      const data = DrawingData();
      const stroke = DrawingStroke(
        id: 's1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );
      final updated = data.copyWith(
        pageStrokes: {
          1: [stroke],
        },
      );
      expect(updated.pageStrokes[1], hasLength(1));
      expect(updated.pageStrokes[1]!.first.id, 's1');
    });

    test('equality works', () {
      const a = DrawingData();
      const b = DrawingData();
      expect(a, equals(b));
    });
  });
}
