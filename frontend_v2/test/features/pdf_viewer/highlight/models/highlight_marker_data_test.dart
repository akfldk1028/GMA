import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/pdf_viewer/highlight/models/highlight_marker_data.dart';
import 'package:gma_app/features/scrapnote/models/element_model.dart';

void main() {
  const rect1 = ElementRect(left: 0.1, top: 0.2, right: 0.8, bottom: 0.3);
  const rect2 = ElementRect(left: 0.1, top: 0.35, right: 0.6, bottom: 0.45);

  group('HighlightMarkerData', () {
    test('constructs with all required fields', () {
      const marker = HighlightMarkerData(
        pageNumber: 3,
        normalizedRects: [rect1],
        colorValue: 0xFFFFEB3B,
        elementId: 'elem-abc',
      );

      expect(marker.pageNumber, 3);
      expect(marker.normalizedRects, [rect1]);
      expect(marker.colorValue, 0xFFFFEB3B);
      expect(marker.elementId, 'elem-abc');
    });

    test('supports multiple rects for multi-line selections', () {
      const marker = HighlightMarkerData(
        pageNumber: 1,
        normalizedRects: [rect1, rect2],
        colorValue: 0xFF4CAF50,
        elementId: 'elem-multi',
      );

      expect(marker.normalizedRects.length, 2);
      expect(marker.normalizedRects[0], rect1);
      expect(marker.normalizedRects[1], rect2);
    });

    test('supports empty rects list', () {
      const marker = HighlightMarkerData(
        pageNumber: 2,
        normalizedRects: [],
        colorValue: 0xFF2196F3,
        elementId: 'elem-empty',
      );

      expect(marker.normalizedRects, isEmpty);
    });

    test('equality holds for identical instances', () {
      const a = HighlightMarkerData(
        pageNumber: 1,
        normalizedRects: [rect1],
        colorValue: 0xFFFFEB3B,
        elementId: 'elem-1',
      );
      const b = HighlightMarkerData(
        pageNumber: 1,
        normalizedRects: [rect1],
        colorValue: 0xFFFFEB3B,
        elementId: 'elem-1',
      );

      expect(a, equals(b));
    });

    test('equality fails when elementId differs', () {
      const a = HighlightMarkerData(
        pageNumber: 1,
        normalizedRects: [rect1],
        colorValue: 0xFFFFEB3B,
        elementId: 'elem-1',
      );
      const b = HighlightMarkerData(
        pageNumber: 1,
        normalizedRects: [rect1],
        colorValue: 0xFFFFEB3B,
        elementId: 'elem-2',
      );

      expect(a, isNot(equals(b)));
    });

    test('copyWith produces modified copy', () {
      const marker = HighlightMarkerData(
        pageNumber: 1,
        normalizedRects: [rect1],
        colorValue: 0xFFFFEB3B,
        elementId: 'elem-orig',
      );
      final updated = marker.copyWith(colorValue: 0xFFE91E63);

      expect(updated.colorValue, 0xFFE91E63);
      expect(updated.pageNumber, marker.pageNumber);
      expect(updated.elementId, marker.elementId);
    });

    test('JSON round-trip preserves all fields (single rect)', () {
      const marker = HighlightMarkerData(
        pageNumber: 5,
        normalizedRects: [rect1],
        colorValue: 0xFFFF9800,
        elementId: 'elem-json',
      );

      final json = jsonEncode(marker.toJson());
      final restored = HighlightMarkerData.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );

      expect(restored.pageNumber, marker.pageNumber);
      expect(restored.colorValue, marker.colorValue);
      expect(restored.elementId, marker.elementId);
      expect(restored.normalizedRects.length, 1);
      expect(restored.normalizedRects[0], rect1);
    });

    test('JSON round-trip preserves multiple rects', () {
      const marker = HighlightMarkerData(
        pageNumber: 2,
        normalizedRects: [rect1, rect2],
        colorValue: 0xFF4CAF50,
        elementId: 'elem-multi-json',
      );

      final json = jsonEncode(marker.toJson());
      final restored = HighlightMarkerData.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );

      expect(restored.normalizedRects.length, 2);
      expect(restored.normalizedRects[0], rect1);
      expect(restored.normalizedRects[1], rect2);
    });
  });
}
