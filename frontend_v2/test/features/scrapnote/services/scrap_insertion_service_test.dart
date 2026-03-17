import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/models/element_model.dart';
import 'package:gma_app/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_app/features/scrapnote/services/scrap_insertion_service.dart';

void main() {
  group('ScrapInsertionService.calculateNextY', () {
    test('returns padding when element list is empty', () {
      final y = ScrapInsertionService.calculateNextY([]);
      expect(y, 20.0);
    });

    test('places element below the last (tallest-reaching) element', () {
      const elements = [
        CanvasElement(
          id: 'e1',
          type: CanvasElementType.highlight,
          x: 20,
          y: 20,
          width: 300,
          height: 80,
          elementId: 's1',
        ),
        CanvasElement(
          id: 'e2',
          type: CanvasElementType.capture,
          x: 20,
          y: 120,
          width: 300,
          height: 200,
          elementId: 's2',
        ),
      ];

      final y = ScrapInsertionService.calculateNextY(elements);
      // Last element bottom = 120 + 200 = 320; plus padding 20 = 340
      expect(y, closeTo(340.0, 0.001));
    });

    test('uses the element that extends furthest down, not the last by index',
        () {
      const elements = [
        CanvasElement(
          id: 'e1',
          type: CanvasElementType.capture,
          x: 20,
          y: 50,
          width: 300,
          height: 200, // bottom = 250
          elementId: 's1',
        ),
        CanvasElement(
          id: 'e2',
          type: CanvasElementType.highlight,
          x: 20,
          y: 20,
          width: 300,
          height: 80, // bottom = 100 (above e1)
          elementId: 's2',
        ),
      ];

      final y = ScrapInsertionService.calculateNextY(elements);
      // e1 has the lowest bottom (250), so next Y = 250 + 20 = 270
      expect(y, closeTo(270.0, 0.001));
    });

    test('single element produces correct next Y', () {
      const elements = [
        CanvasElement(
          id: 'e1',
          type: CanvasElementType.highlight,
          x: 20,
          y: 20,
          width: 300,
          height: 80,
          elementId: 's1',
        ),
      ];

      final y = ScrapInsertionService.calculateNextY(elements);
      expect(y, closeTo(120.0, 0.001)); // 20 + 80 + 20 padding
    });
  });

  group('ScrapInsertionService.createCanvasElement', () {
    final now = DateTime(2024, 1, 1);
    final baseRect = const ElementRect(
      left: 0,
      top: 0,
      right: 0.5,
      bottom: 0.1,
    );

    test('creates capture element from capture ScrapElement', () {
      final scrap = ScrapElement(
        id: 'scrap-1',
        type: ScrapElementType.capture,
        pdfPath: '/docs/test.pdf',
        imagePath: '/captures/img.png',
        sourcePageNumber: 1,
        sourceRect: baseRect,
        createdAt: now,
      );

      final element = ScrapInsertionService.createCanvasElement(
        scrapElement: scrap,
        yPosition: 40.0,
      );

      expect(element.type, CanvasElementType.capture);
      expect(element.imagePath, '/captures/img.png');
      expect(element.selectedText, isNull);
      expect(element.y, 40.0);
      expect(element.x, 20.0);
      expect(element.width, 300.0);
      expect(element.height, 200.0); // default capture height
      expect(element.elementId, 'scrap-1');
      expect(element.sourcePageNumber, 1);
    });

    test('creates highlight element from highlight ScrapElement', () {
      final scrap = ScrapElement(
        id: 'scrap-2',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        selectedText: 'Some highlighted text',
        sourcePageNumber: 3,
        sourceRect: baseRect,
        colorValue: 0xFF4CAF50,
        createdAt: now,
      );

      final element = ScrapInsertionService.createCanvasElement(
        scrapElement: scrap,
        yPosition: 120.0,
      );

      expect(element.type, CanvasElementType.highlight);
      expect(element.selectedText, 'Some highlighted text');
      expect(element.imagePath, isNull);
      expect(element.y, 120.0);
      expect(element.height, 80.0); // default highlight height
      expect(element.colorValue, 0xFF4CAF50);
      expect(element.elementId, 'scrap-2');
    });

    test('generated element has a non-empty UUID id', () {
      final scrap = ScrapElement(
        id: 'scrap-3',
        type: ScrapElementType.highlight,
        pdfPath: '/docs/test.pdf',
        selectedText: 'Text',
        sourcePageNumber: 1,
        sourceRect: baseRect,
        createdAt: now,
      );

      final element = ScrapInsertionService.createCanvasElement(
        scrapElement: scrap,
        yPosition: 0,
      );

      expect(element.id, isNotEmpty);
      expect(element.id, isNot(equals('scrap-3')));
    });
  });
}
