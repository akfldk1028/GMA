import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_app/features/scrapnote/utils/scrapnote_serializer.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('scrapnote_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ScrapnoteSerializer.buildFilePath', () {
    test('produces a .gma file inside the scrapnotes directory', () {
      final filePath = ScrapnoteSerializer.buildFilePath(
        '/scrapnotes',
        '/home/user/docs/test.pdf',
      );
      expect(filePath, contains('/scrapnotes'));
      expect(filePath, endsWith('.gma'));
    });

    test('sanitizes path separators from PDF path', () {
      final filePath = ScrapnoteSerializer.buildFilePath(
        '/scrapnotes',
        '/home/user/docs/my file.pdf',
      );
      final filename = path.basename(filePath);
      expect(filename, isNot(contains('/')));
      expect(filename, isNot(contains('\\')));
    });

    test('two different PDF paths produce different file paths', () {
      final path1 =
          ScrapnoteSerializer.buildFilePath('/scrapnotes', 'doc1.pdf');
      final path2 =
          ScrapnoteSerializer.buildFilePath('/scrapnotes', 'doc2.pdf');
      expect(path1, isNot(equals(path2)));
    });

    test('sanitizes special characters in PDF path', () {
      final filePath = ScrapnoteSerializer.buildFilePath(
        '/scrapnotes',
        '/docs/my*doc?.pdf',
      );
      final filename = path.basename(filePath);
      expect(filename, isNot(contains('*')));
      expect(filename, isNot(contains('?')));
    });
  });

  group('ScrapnoteSerializer save and load', () {
    final now = DateTime(2024, 6, 1, 12, 0, 0);

    test('save creates a file at the given path', () async {
      final filePath = path.join(tempDir.path, 'test.gma');
      final data = ScrapnoteCanvasData(
        id: 'canvas-1',
        linkedPdfPath: '/docs/test.pdf',
        createdAt: now,
        modifiedAt: now,
      );

      await ScrapnoteSerializer.save(filePath: filePath, data: data);

      expect(await File(filePath).exists(), isTrue);
    });

    test('load returns null for a non-existent file', () async {
      final filePath = path.join(tempDir.path, 'nonexistent.gma');
      final result = await ScrapnoteSerializer.load(filePath: filePath);
      expect(result, isNull);
    });

    test('load returns null for invalid JSON', () async {
      final filePath = path.join(tempDir.path, 'corrupt.gma');
      await File(filePath).writeAsString('{invalid json!!!}');
      final result = await ScrapnoteSerializer.load(filePath: filePath);
      expect(result, isNull);
    });

    test('load returns null for valid JSON with wrong structure', () async {
      final filePath = path.join(tempDir.path, 'wrong_structure.gma');
      await File(filePath).writeAsString('{"other_key": 42}');
      final result = await ScrapnoteSerializer.load(filePath: filePath);
      expect(result, isNull);
    });

    test('save and load roundtrip preserves all data fields', () async {
      final filePath = path.join(tempDir.path, 'roundtrip.gma');
      const element = CanvasElement(
        id: 'elem-1',
        type: CanvasElementType.highlight,
        x: 20.0,
        y: 60.0,
        width: 300.0,
        height: 80.0,
        selectedText: 'Test text',
        sourcePageNumber: 1,
        colorValue: 0xFFFFEB3B,
        elementId: 'scrap-1',
      );

      final original = ScrapnoteCanvasData(
        id: 'canvas-xyz',
        linkedPdfPath: '/docs/my.pdf',
        canvasMode: 'a4',
        elements: [element],
        layerOrder: ['elem-1'],
        createdAt: now,
        modifiedAt: now,
      );

      await ScrapnoteSerializer.save(filePath: filePath, data: original);
      final loaded = await ScrapnoteSerializer.load(filePath: filePath);

      expect(loaded, isNotNull);
      expect(loaded!.id, original.id);
      expect(loaded.linkedPdfPath, original.linkedPdfPath);
      expect(loaded.canvasMode, 'a4');
      expect(loaded.elements, hasLength(1));
      expect(loaded.elements.first.selectedText, 'Test text');
      expect(loaded.layerOrder, ['elem-1']);
      expect(loaded.createdAt, original.createdAt);
    });

    test('save and load empty canvas data', () async {
      final filePath = path.join(tempDir.path, 'empty.gma');
      final original = ScrapnoteCanvasData(
        id: 'canvas-empty',
        linkedPdfPath: '/docs/empty.pdf',
        createdAt: now,
        modifiedAt: now,
      );

      await ScrapnoteSerializer.save(filePath: filePath, data: original);
      final loaded = await ScrapnoteSerializer.load(filePath: filePath);

      expect(loaded, isNotNull);
      expect(loaded!.strokes, isEmpty);
      expect(loaded.elements, isEmpty);
    });
  });
}
