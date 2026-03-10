import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/pdf_viewer/drawing/models/drawing_model.dart';

void main() {
  group('ScrapnoteCanvasData', () {
    final now = DateTime(2026, 3, 9, 10, 0, 0);

    group('model creation with defaults', () {
      test('creates with required fields and uses defaults for optional', () {
        final data = ScrapnoteCanvasData(
          id: 'test-id',
          linkedPdfPath: '/path/to/file.pdf',
          createdAt: now,
          modifiedAt: now,
        );

        expect(data.id, 'test-id');
        expect(data.linkedPdfPath, '/path/to/file.pdf');
        expect(data.canvasMode, CanvasMode.infinite);
        expect(data.canvasWidth, 1080.0);
        expect(data.canvasHeight, isNull); // null = infinite
        expect(data.strokes, isEmpty);
        expect(data.elements, isEmpty);
        expect(data.layerOrder, isEmpty);
        expect(data.createdAt, now);
        expect(data.modifiedAt, now);
      });

      test('creates with custom canvasWidth and finite canvasHeight', () {
        final data = ScrapnoteCanvasData(
          id: 'test-id',
          linkedPdfPath: '/path/to/file.pdf',
          canvasWidth: 1920.0,
          canvasHeight: 1080.0,
          createdAt: now,
          modifiedAt: now,
        );

        expect(data.canvasWidth, 1920.0);
        expect(data.canvasHeight, 1080.0);
      });

      test('canvasHeight is null for infinite mode', () {
        final data = ScrapnoteCanvasData(
          id: 'test-id',
          linkedPdfPath: '/path/to/file.pdf',
          canvasMode: CanvasMode.infinite,
          createdAt: now,
          modifiedAt: now,
        );

        expect(data.canvasHeight, isNull);
        expect(data.canvasMode, CanvasMode.infinite);
      });
    });

    group('JSON round-trip (toJson -> fromJson)', () {
      test('serializes and deserializes correctly with no elements or strokes', () {
        final original = ScrapnoteCanvasData(
          id: 'round-trip-id',
          linkedPdfPath: '/pdf/test.pdf',
          canvasMode: CanvasMode.infinite,
          canvasWidth: 1080.0,
          createdAt: now,
          modifiedAt: now,
        );

        final json = original.toJson();
        final restored = ScrapnoteCanvasData.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.linkedPdfPath, original.linkedPdfPath);
        expect(restored.canvasMode, original.canvasMode);
        expect(restored.canvasWidth, original.canvasWidth);
        expect(restored.canvasHeight, isNull);
        expect(restored.strokes, isEmpty);
        expect(restored.elements, isEmpty);
        expect(restored.layerOrder, isEmpty);
        expect(restored.createdAt, original.createdAt);
        expect(restored.modifiedAt, original.modifiedAt);
      });

      test('preserves all fields through JSON round-trip', () {
        final stroke = DrawingStroke(
          id: 'stroke-1',
          pageNumber: 0, // 0 for scrapnote infinite mode
          points: [StrokePoint(x: 10.0, y: 20.0)],
          toolId: 'pen',
          colorValue: 0xFF0000FF,
          size: 5.0,
        );

        final element = CanvasElement(
          id: 'elem-1',
          type: CanvasElementType.capture,
          x: 100.0,
          y: 200.0,
          width: 300.0,
          height: 150.0,
          imagePath: '/captures/img.png',
          selectedText: 'Hello World',
          colorValue: 0xFFFF0000,
          sourcePageNumber: 3,
          sourcePdfPath: '/pdf/source.pdf',
          createdAt: now,
        );

        final original = ScrapnoteCanvasData(
          id: 'full-id',
          linkedPdfPath: '/pdf/full.pdf',
          canvasWidth: 1080.0,
          canvasHeight: 2160.0,
          strokes: [stroke],
          elements: [element],
          layerOrder: ['layer-1', 'layer-2'],
          createdAt: now,
          modifiedAt: now,
        );

        final json = original.toJson();
        final restored = ScrapnoteCanvasData.fromJson(json);

        expect(restored.strokes.length, 1);
        expect(restored.strokes[0].id, 'stroke-1');
        expect(restored.strokes[0].pageNumber, 0);
        expect(restored.elements.length, 1);
        expect(restored.elements[0].id, 'elem-1');
        expect(restored.elements[0].type, CanvasElementType.capture);
        expect(restored.layerOrder, ['layer-1', 'layer-2']);
        expect(restored.canvasHeight, 2160.0);
      });
    });

    group('DrawingStroke JSON compatibility', () {
      test('DrawingStroke serializes with pageNumber=0 for scrapnote', () {
        final stroke = DrawingStroke(
          id: 'scrap-stroke',
          pageNumber: 0, // repurposed: 0 for infinite scrapnote canvas
          points: [
            StrokePoint(x: 50.0, y: 75.0, pressure: 0.8),
          ],
          toolId: 'pen',
        );

        final json = stroke.toJson();
        final restored = DrawingStroke.fromJson(json);

        expect(restored.pageNumber, 0);
        expect(restored.points.length, 1);
        expect(restored.points[0].x, 50.0);
        expect(restored.points[0].y, 75.0);
        expect(restored.points[0].pressure, 0.8);
      });

      test('DrawingStroke JSON format is reused exactly (no custom fields)', () {
        final stroke = DrawingStroke(
          id: 'compat-stroke',
          pageNumber: 0,
          points: [StrokePoint(x: 1.0, y: 2.0)],
          toolId: 'highlighter',
          colorValue: 0xFFFFFF00,
          size: 10.0,
        );

        final json = stroke.toJson();

        // Verify the JSON keys match DrawingStroke's standard serialization
        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('pageNumber'), isTrue);
        expect(json.containsKey('points'), isTrue);
        expect(json.containsKey('toolId'), isTrue);
        expect(json.containsKey('colorValue'), isTrue);
        expect(json.containsKey('size'), isTrue);

        // The pageNumber is 0 for scrapnote use (absolute pixels, not PDF page)
        expect(json['pageNumber'], 0);
      });
    });

    group('CanvasElement serialization', () {
      test('CanvasElement with all fields serializes correctly', () {
        final element = CanvasElement(
          id: 'elem-full',
          type: CanvasElementType.highlight,
          x: 50.0,
          y: 100.0,
          width: 200.0,
          height: 80.0,
          selectedText: 'Highlighted text',
          colorValue: 0xFFFFFF00,
          sourcePageNumber: 5,
          sourcePdfPath: '/pdf/source.pdf',
          createdAt: now,
        );

        final json = element.toJson();
        final restored = CanvasElement.fromJson(json);

        expect(restored.id, 'elem-full');
        expect(restored.type, CanvasElementType.highlight);
        expect(restored.x, 50.0);
        expect(restored.y, 100.0);
        expect(restored.width, 200.0);
        expect(restored.height, 80.0);
        expect(restored.imagePath, isNull);
        expect(restored.selectedText, 'Highlighted text');
        expect(restored.colorValue, 0xFFFFFF00);
        expect(restored.sourcePageNumber, 5);
        expect(restored.sourcePdfPath, '/pdf/source.pdf');
      });

      test('CanvasElement with minimal required fields (null optionals)', () {
        final element = CanvasElement(
          id: 'elem-min',
          type: CanvasElementType.capture,
          x: 0.0,
          y: 0.0,
          width: 100.0,
          height: 100.0,
          createdAt: now,
        );

        final json = element.toJson();
        final restored = CanvasElement.fromJson(json);

        expect(restored.imagePath, isNull);
        expect(restored.selectedText, isNull);
        expect(restored.colorValue, isNull);
        expect(restored.sourcePageNumber, isNull);
        expect(restored.sourcePdfPath, isNull);
      });

      test('CanvasElementType enum has expected values', () {
        expect(CanvasElementType.values.length, 2);
        expect(CanvasElementType.values, contains(CanvasElementType.capture));
        expect(CanvasElementType.values, contains(CanvasElementType.highlight));
      });
    });

    group('CanvasMode enum', () {
      test('CanvasMode enum has infinite value', () {
        expect(CanvasMode.values, contains(CanvasMode.infinite));
      });

      test('default canvasMode is infinite', () {
        final data = ScrapnoteCanvasData(
          id: 'id',
          linkedPdfPath: '/pdf.pdf',
          createdAt: now,
          modifiedAt: now,
        );
        expect(data.canvasMode, CanvasMode.infinite);
      });
    });

    group('Freezed equality and copyWith', () {
      test('two identical instances are equal', () {
        final data1 = ScrapnoteCanvasData(
          id: 'same-id',
          linkedPdfPath: '/pdf.pdf',
          createdAt: now,
          modifiedAt: now,
        );
        final data2 = ScrapnoteCanvasData(
          id: 'same-id',
          linkedPdfPath: '/pdf.pdf',
          createdAt: now,
          modifiedAt: now,
        );
        expect(data1, data2);
      });

      test('copyWith creates modified copy', () {
        final original = ScrapnoteCanvasData(
          id: 'original',
          linkedPdfPath: '/pdf.pdf',
          createdAt: now,
          modifiedAt: now,
        );
        final modified = original.copyWith(
          id: 'modified',
          canvasWidth: 1920.0,
        );

        expect(modified.id, 'modified');
        expect(modified.canvasWidth, 1920.0);
        expect(modified.linkedPdfPath, original.linkedPdfPath);
      });
    });
  });
}
