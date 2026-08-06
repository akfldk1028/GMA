import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/models/element_model.dart';

void main() {
  group('ElementRect', () {
    test('creates with required fields', () {
      const rect = ElementRect(left: 0.1, top: 0.2, right: 0.8, bottom: 0.4);
      expect(rect.left, 0.1);
      expect(rect.top, 0.2);
      expect(rect.right, 0.8);
      expect(rect.bottom, 0.4);
    });

    test('equality works for identical rects', () {
      const a = ElementRect(left: 0.0, top: 0.0, right: 1.0, bottom: 1.0);
      const b = ElementRect(left: 0.0, top: 0.0, right: 1.0, bottom: 1.0);
      expect(a, equals(b));
    });

    test('copyWith creates modified copy', () {
      const rect = ElementRect(left: 0.1, top: 0.2, right: 0.8, bottom: 0.4);
      final updated = rect.copyWith(right: 0.9, bottom: 0.5);
      expect(updated.left, 0.1);
      expect(updated.top, 0.2);
      expect(updated.right, 0.9);
      expect(updated.bottom, 0.5);
    });

    test('JSON round-trip preserves values', () {
      const rect = ElementRect(left: 0.1, top: 0.2, right: 0.9, bottom: 0.8);
      final jsonStr = jsonEncode(rect.toJson());
      final restored = ElementRect.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(restored, equals(rect));
    });

    test('normalized coordinates stay in 0-1 range', () {
      const rect = ElementRect(left: 0.0, top: 0.0, right: 1.0, bottom: 1.0);
      expect(rect.left, greaterThanOrEqualTo(0.0));
      expect(rect.top, greaterThanOrEqualTo(0.0));
      expect(rect.right, lessThanOrEqualTo(1.0));
      expect(rect.bottom, lessThanOrEqualTo(1.0));
    });
  });

  group('ScrapElementType', () {
    test('has highlight and capture values', () {
      expect(ScrapElementType.values, contains(ScrapElementType.highlight));
      expect(ScrapElementType.values, contains(ScrapElementType.capture));
    });

    test('highlight and capture are distinct', () {
      expect(ScrapElementType.highlight, isNot(ScrapElementType.capture));
    });
  });

  group('ScrapElement', () {
    final createdAt = DateTime(2024, 1, 15, 10, 30);
    const rect = ElementRect(left: 0.1, top: 0.2, right: 0.8, bottom: 0.4);

    test('creates highlight element with required fields', () {
      final element = ScrapElement(
        id: 'elem-1',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        selectedText: 'Some selected text',
        sourcePageNumber: 3,
        sourceRect: rect,
        createdAt: createdAt,
      );

      expect(element.id, 'elem-1');
      expect(element.type, ScrapElementType.highlight);
      expect(element.pdfPath, '/docs/test.pdf');
      expect(element.selectedText, 'Some selected text');
      expect(element.imagePath, isNull);
      expect(element.sourcePageNumber, 3);
      expect(element.sourceRect, rect);
      expect(element.colorValue, 0xFFFFEB3B); // default yellow
      expect(element.createdAt, createdAt);
    });

    test('creates capture element with image path', () {
      final element = ScrapElement(
        id: 'elem-2',
        type: ScrapElementType.capture,
        pdfPath: '/docs/report.pdf',
        imagePath: '/captures/page1.png',
        sourcePageNumber: 1,
        sourceRect: rect,
        createdAt: createdAt,
      );

      expect(element.type, ScrapElementType.capture);
      expect(element.imagePath, '/captures/page1.png');
      expect(element.selectedText, isNull);
    });

    test('default colorValue is yellow 0xFFFFEB3B', () {
      final element = ScrapElement(
        id: 'elem-3',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        sourcePageNumber: 1,
        sourceRect: rect,
        createdAt: createdAt,
      );
      expect(element.colorValue, 0xFFFFEB3B);
    });

    test('supports custom color value', () {
      final element = ScrapElement(
        id: 'elem-4',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        sourcePageNumber: 1,
        sourceRect: rect,
        colorValue: 0xFF4CAF50,
        createdAt: createdAt,
      );
      expect(element.colorValue, 0xFF4CAF50);
    });

    test('equality works for identical elements', () {
      final a = ScrapElement(
        id: 'elem-5',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        selectedText: 'text',
        sourcePageNumber: 2,
        sourceRect: rect,
        createdAt: createdAt,
      );
      final b = ScrapElement(
        id: 'elem-5',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        selectedText: 'text',
        sourcePageNumber: 2,
        sourceRect: rect,
        createdAt: createdAt,
      );
      expect(a, equals(b));
    });

    test('copyWith creates modified copy', () {
      final element = ScrapElement(
        id: 'elem-6',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        selectedText: 'original text',
        sourcePageNumber: 1,
        sourceRect: rect,
        createdAt: createdAt,
      );
      final updated = element.copyWith(
        selectedText: 'updated text',
        colorValue: 0xFF2196F3,
      );
      expect(updated.id, 'elem-6');
      expect(updated.selectedText, 'updated text');
      expect(updated.colorValue, 0xFF2196F3);
      expect(updated.sourcePageNumber, 1);
    });

    test('JSON round-trip preserves all fields', () {
      final element = ScrapElement(
        id: 'elem-json',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        selectedText: 'Hello world',
        sourcePageNumber: 5,
        sourceRect: rect,
        colorValue: 0xFFFFEB3B,
        createdAt: createdAt,
      );
      final jsonStr = jsonEncode(element.toJson());
      final restored = ScrapElement.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(restored.id, element.id);
      expect(restored.type, element.type);
      expect(restored.pdfPath, element.pdfPath);
      expect(restored.selectedText, element.selectedText);
      expect(restored.sourcePageNumber, element.sourcePageNumber);
      expect(restored.colorValue, element.colorValue);
    });

    test('JSON round-trip for capture element', () {
      final element = ScrapElement(
        id: 'elem-cap',
        type: ScrapElementType.capture,
        pdfPath: '/docs/report.pdf',
        imagePath: '/captures/img.png',
        sourcePageNumber: 2,
        sourceRect: const ElementRect(
          left: 0.2,
          top: 0.3,
          right: 0.7,
          bottom: 0.6,
        ),
        createdAt: DateTime(2024, 6, 1),
      );
      final jsonStr = jsonEncode(element.toJson());
      final restored = ScrapElement.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      expect(restored.type, ScrapElementType.capture);
      expect(restored.imagePath, '/captures/img.png');
      expect(restored.selectedText, isNull);
    });
  });
}
