import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/models/scrapnote_canvas_model.dart';

void main() {
  final now = DateTime(2024, 1, 1);

  group('ScrapnoteCanvasData', () {
    test('constructs with required fields', () {
      final data = ScrapnoteCanvasData(
        id: 'canvas-1',
        linkedPdfPath: '/docs/test.pdf',
        createdAt: now,
        modifiedAt: now,
      );

      expect(data.id, 'canvas-1');
      expect(data.linkedPdfPath, '/docs/test.pdf');
      expect(data.createdAt, now);
      expect(data.modifiedAt, now);
    });

    test('default values are applied', () {
      final data = ScrapnoteCanvasData(
        id: 'canvas-1',
        linkedPdfPath: '/docs/test.pdf',
        createdAt: now,
        modifiedAt: now,
      );

      expect(data.canvasMode, 'infinite');
      expect(data.strokes, isEmpty);
      expect(data.elements, isEmpty);
      expect(data.layerOrder, isEmpty);
    });

    test('JSON roundtrip preserves all fields', () {
      const element = CanvasElement(
        id: 'elem-1',
        type: CanvasElementType.highlight,
        x: 20.0,
        y: 40.0,
        width: 300.0,
        height: 80.0,
        selectedText: 'Hello world',
        sourcePageNumber: 2,
        colorValue: 0xFFFFEB3B,
        elementId: 'scrap-1',
      );

      final data = ScrapnoteCanvasData(
        id: 'canvas-abc',
        linkedPdfPath: '/docs/my.pdf',
        canvasMode: 'a4',
        elements: [element],
        createdAt: now,
        modifiedAt: now,
      );

      final json = data.toJson();
      final restored = ScrapnoteCanvasData.fromJson(json);

      expect(restored.id, data.id);
      expect(restored.linkedPdfPath, data.linkedPdfPath);
      expect(restored.canvasMode, 'a4');
      expect(restored.elements, hasLength(1));
      expect(restored.elements.first.id, element.id);
      expect(restored.createdAt, data.createdAt);
      expect(restored.modifiedAt, data.modifiedAt);
    });

    test('copyWith updates fields correctly', () {
      final original = ScrapnoteCanvasData(
        id: 'canvas-1',
        linkedPdfPath: '/docs/test.pdf',
        createdAt: now,
        modifiedAt: now,
      );

      final updated = original.copyWith(canvasMode: 'a4');
      expect(updated.canvasMode, 'a4');
      expect(updated.id, original.id);
    });
  });

  group('CanvasElement', () {
    test('constructs with required fields', () {
      const element = CanvasElement(
        id: 'elem-1',
        type: CanvasElementType.capture,
        x: 10.0,
        y: 20.0,
        width: 300.0,
        height: 200.0,
        elementId: 'scrap-abc',
      );

      expect(element.id, 'elem-1');
      expect(element.type, CanvasElementType.capture);
      expect(element.x, 10.0);
      expect(element.y, 20.0);
      expect(element.width, 300.0);
      expect(element.height, 200.0);
      expect(element.elementId, 'scrap-abc');
    });

    test('default colorValue is yellow 0xFFFFEB3B', () {
      const element = CanvasElement(
        id: 'elem-1',
        type: CanvasElementType.highlight,
        x: 0,
        y: 0,
        width: 100,
        height: 50,
        elementId: 'scrap-1',
      );
      expect(element.colorValue, 0xFFFFEB3B);
    });

    test('JSON roundtrip preserves nullable fields', () {
      const element = CanvasElement(
        id: 'elem-2',
        type: CanvasElementType.capture,
        x: 15.5,
        y: 30.0,
        width: 300.0,
        height: 200.0,
        imagePath: '/images/cap.png',
        sourcePageNumber: 3,
        elementId: 'scrap-2',
      );

      final json = element.toJson();
      final restored = CanvasElement.fromJson(json);

      expect(restored.id, element.id);
      expect(restored.type, CanvasElementType.capture);
      expect(restored.x, element.x);
      expect(restored.imagePath, '/images/cap.png');
      expect(restored.sourcePageNumber, 3);
      expect(restored.selectedText, isNull);
    });

    test('JSON roundtrip for highlight element', () {
      const element = CanvasElement(
        id: 'elem-3',
        type: CanvasElementType.highlight,
        x: 20.0,
        y: 50.0,
        width: 300.0,
        height: 80.0,
        selectedText: 'Important text',
        colorValue: 0xFF4CAF50,
        elementId: 'scrap-3',
      );

      final json = element.toJson();
      final restored = CanvasElement.fromJson(json);

      expect(restored.selectedText, 'Important text');
      expect(restored.colorValue, 0xFF4CAF50);
      expect(restored.imagePath, isNull);
    });

    test('CanvasElementType enum serializes correctly', () {
      const capture = CanvasElement(
        id: 'c',
        type: CanvasElementType.capture,
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        elementId: 'e1',
      );
      const highlight = CanvasElement(
        id: 'h',
        type: CanvasElementType.highlight,
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        elementId: 'e2',
      );

      expect(capture.toJson()['type'], 'capture');
      expect(highlight.toJson()['type'], 'highlight');
    });
  });
}
