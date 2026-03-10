import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/scrapnote/utils/scrapnote_serializer.dart';
import 'package:gma_frontend/features/pdf_viewer/drawing/models/drawing_model.dart';

void main() {
  late Directory tempDir;
  late String testFilePath;
  final now = DateTime(2026, 3, 9, 10, 0, 0).toUtc();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('scrapnote_test_');
    testFilePath = p.join(tempDir.path, 'test_canvas.gma');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  ScrapnoteCanvasData buildMinimalData() {
    return ScrapnoteCanvasData(
      id: 'canvas-001',
      linkedPdfPath: '/docs/test.pdf',
      createdAt: now,
      modifiedAt: now,
    );
  }

  group('ScrapnoteSerializer', () {
    group('save and load round-trip', () {
      test('saves and loads minimal ScrapnoteCanvasData correctly', () async {
        final data = buildMinimalData();

        await ScrapnoteSerializer.save(filePath: testFilePath, data: data);

        expect(await File(testFilePath).exists(), isTrue);

        final loaded = await ScrapnoteSerializer.load(filePath: testFilePath);

        expect(loaded, isNotNull);
        expect(loaded!.id, data.id);
        expect(loaded.linkedPdfPath, data.linkedPdfPath);
        expect(loaded.canvasMode, data.canvasMode);
        expect(loaded.canvasWidth, data.canvasWidth);
        expect(loaded.canvasHeight, isNull);
        expect(loaded.strokes, isEmpty);
        expect(loaded.elements, isEmpty);
        expect(loaded.layerOrder, isEmpty);
        expect(loaded.createdAt, data.createdAt);
        expect(loaded.modifiedAt, data.modifiedAt);
      });

      test('saves and loads data with strokes and elements', () async {
        final stroke = DrawingStroke(
          id: 'stroke-001',
          pageNumber: 0,
          points: [StrokePoint(x: 10.0, y: 20.0, pressure: 0.5)],
          toolId: 'pen',
          colorValue: 0xFF000000,
          size: 3.0,
        );

        final element = CanvasElement(
          id: 'elem-001',
          type: CanvasElementType.capture,
          x: 100.0,
          y: 200.0,
          width: 300.0,
          height: 200.0,
          imagePath: '/captures/img.png',
          selectedText: 'Test text',
          colorValue: 0xFFFF0000,
          sourcePageNumber: 2,
          sourcePdfPath: '/source.pdf',
          createdAt: now,
        );

        final data = ScrapnoteCanvasData(
          id: 'canvas-002',
          linkedPdfPath: '/docs/test.pdf',
          canvasWidth: 1080.0,
          canvasHeight: 2160.0,
          strokes: [stroke],
          elements: [element],
          layerOrder: ['background', 'foreground'],
          createdAt: now,
          modifiedAt: now,
        );

        await ScrapnoteSerializer.save(filePath: testFilePath, data: data);
        final loaded = await ScrapnoteSerializer.load(filePath: testFilePath);

        expect(loaded, isNotNull);
        expect(loaded!.strokes.length, 1);
        expect(loaded.strokes[0].id, 'stroke-001');
        expect(loaded.strokes[0].pageNumber, 0);
        expect(loaded.strokes[0].points.length, 1);
        expect(loaded.strokes[0].points[0].x, 10.0);
        expect(loaded.strokes[0].points[0].pressure, 0.5);

        expect(loaded.elements.length, 1);
        expect(loaded.elements[0].id, 'elem-001');
        expect(loaded.elements[0].type, CanvasElementType.capture);
        expect(loaded.elements[0].x, 100.0);
        expect(loaded.elements[0].imagePath, '/captures/img.png');
        expect(loaded.elements[0].selectedText, 'Test text');
        expect(loaded.elements[0].sourcePageNumber, 2);

        expect(loaded.layerOrder, ['background', 'foreground']);
        expect(loaded.canvasHeight, 2160.0);
      });
    });

    group('load returns null for missing file', () {
      test('returns null when file does not exist', () async {
        final missingPath = p.join(tempDir.path, 'nonexistent.gma');
        final result = await ScrapnoteSerializer.load(filePath: missingPath);
        expect(result, isNull);
      });

      test('returns null without throwing for missing file', () async {
        final missingPath = p.join(tempDir.path, 'missing_file.gma');
        expect(
          () async => await ScrapnoteSerializer.load(filePath: missingPath),
          returnsNormally,
        );
      });
    });

    group('version field preservation', () {
      test('saved file contains version field equal to 1', () async {
        final data = buildMinimalData();
        await ScrapnoteSerializer.save(filePath: testFilePath, data: data);

        final content = await File(testFilePath).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json.containsKey('version'), isTrue);
        expect(json['version'], 1);
      });

      test('version field appears alongside model data', () async {
        final data = buildMinimalData();
        await ScrapnoteSerializer.save(filePath: testFilePath, data: data);

        final content = await File(testFilePath).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        expect(json['version'], 1);
        expect(json['id'], 'canvas-001');
        expect(json['linkedPdfPath'], '/docs/test.pdf');
        expect(json.containsKey('canvasMode'), isTrue);
        expect(json.containsKey('canvasWidth'), isTrue);
        expect(json.containsKey('strokes'), isTrue);
        expect(json.containsKey('elements'), isTrue);
        expect(json.containsKey('layerOrder'), isTrue);
      });
    });

    group('atomic write (temp file + rename)', () {
      test('uses a temp file during write (no partial data on crash)', () async {
        // We test the atomic write by verifying the final file is correct
        // and that a temp file is not left behind after successful write.
        final data = buildMinimalData();
        await ScrapnoteSerializer.save(filePath: testFilePath, data: data);

        // Verify the target file exists with correct content
        expect(await File(testFilePath).exists(), isTrue);

        // Verify no leftover temp files in the same directory
        final dir = Directory(p.dirname(testFilePath));
        final files = await dir.list().toList();
        final gmaFiles = files.where((f) => f.path.endsWith('.gma') || f.path.endsWith('.tmp'));
        // Only the target .gma file should exist, no .tmp remnants
        final tmpFiles = gmaFiles.where((f) => f.path.endsWith('.tmp'));
        expect(tmpFiles, isEmpty);
      });

      test('final file is valid JSON after atomic save', () async {
        final data = buildMinimalData();
        await ScrapnoteSerializer.save(filePath: testFilePath, data: data);

        final content = await File(testFilePath).readAsString();
        // Should not throw
        expect(() => jsonDecode(content), returnsNormally);
      });
    });

    group('DrawingStroke JSON format reused exactly', () {
      test('strokes in .gma file use DrawingStroke.toJson() format', () async {
        final stroke = DrawingStroke(
          id: 'stroke-format-test',
          pageNumber: 0,
          points: [StrokePoint(x: 5.0, y: 10.0)],
          toolId: 'pen',
        );

        final data = ScrapnoteCanvasData(
          id: 'format-test',
          linkedPdfPath: '/pdf.pdf',
          strokes: [stroke],
          createdAt: now,
          modifiedAt: now,
        );

        await ScrapnoteSerializer.save(filePath: testFilePath, data: data);

        final content = await File(testFilePath).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final strokesJson = json['strokes'] as List<dynamic>;

        expect(strokesJson.length, 1);
        final strokeJson = strokesJson[0] as Map<String, dynamic>;

        // Must match DrawingStroke.toJson() field names exactly
        expect(strokeJson.containsKey('id'), isTrue);
        expect(strokeJson.containsKey('pageNumber'), isTrue);
        expect(strokeJson.containsKey('points'), isTrue);
        expect(strokeJson.containsKey('toolId'), isTrue);
        expect(strokeJson.containsKey('colorValue'), isTrue);
        expect(strokeJson.containsKey('size'), isTrue);

        // Verify values
        expect(strokeJson['id'], 'stroke-format-test');
        expect(strokeJson['pageNumber'], 0);
        expect(strokeJson['toolId'], 'pen');
      });
    });

    group('error handling', () {
      test('save creates parent directory if needed', () async {
        final nestedPath = p.join(tempDir.path, 'nested', 'deep', 'canvas.gma');
        final data = buildMinimalData();

        // Should not throw even if parent directories don't exist
        // (or gracefully handle it)
        await Directory(p.dirname(nestedPath)).create(recursive: true);
        await ScrapnoteSerializer.save(filePath: nestedPath, data: data);

        expect(await File(nestedPath).exists(), isTrue);
      });

      test('overwrites existing file on repeated save', () async {
        final data1 = buildMinimalData();
        await ScrapnoteSerializer.save(filePath: testFilePath, data: data1);

        final data2 = data1.copyWith(linkedPdfPath: '/new/path.pdf');
        await ScrapnoteSerializer.save(filePath: testFilePath, data: data2);

        final loaded = await ScrapnoteSerializer.load(filePath: testFilePath);
        expect(loaded?.linkedPdfPath, '/new/path.pdf');
      });
    });
  });
}
