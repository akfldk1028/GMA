import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/scrapnote/services/scrapnote_service.dart';
import 'package:gma_frontend/features/scrapnote/utils/scrapnote_serializer.dart';

void main() {
  late Directory tempDir;
  late ScrapnoteService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('scrapnote_service_test_');
    service = ScrapnoteService(notesDir: tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ScrapnoteService', () {
    test('findScrapnoteForPdf returns null when no scrapnote exists', () async {
      final result = await service.findScrapnoteForPdf('/path/to/some.pdf');
      expect(result, isNull);
    });

    test('getOrCreateScrapnote creates a new .gma file', () async {
      const pdfPath = '/path/to/document.pdf';

      final scrapnoteId = await service.getOrCreateScrapnote(pdfPath);

      expect(scrapnoteId, isNotEmpty);

      // Verify the file was created
      final filePath = ScrapnoteSerializer.buildFilePath(tempDir.path, scrapnoteId);
      final file = File(filePath);
      expect(await file.exists(), isTrue);
    });

    test('findScrapnoteForPdf finds existing scrapnote after creation',
        () async {
      const pdfPath = '/path/to/another.pdf';

      final createdId = await service.getOrCreateScrapnote(pdfPath);

      // Now find it
      final foundId = await service.findScrapnoteForPdf(pdfPath);

      expect(foundId, equals(createdId));
    });

    test('getOrCreateScrapnote returns existing id on second call', () async {
      const pdfPath = '/path/to/same.pdf';

      final firstId = await service.getOrCreateScrapnote(pdfPath);
      final secondId = await service.getOrCreateScrapnote(pdfPath);

      expect(firstId, equals(secondId));
    });

    test('loadScrapnote loads existing data', () async {
      const id = 'load-test-id';
      final data = ScrapnoteCanvasData(
        id: id,
        linkedPdfPath: '/path/load.pdf',
        strokes: const [],
        elements: const [],
        createdAt: DateTime(2024, 1, 1),
        modifiedAt: DateTime(2024, 1, 1),
      );
      final filePath = ScrapnoteSerializer.buildFilePath(tempDir.path, id);
      await ScrapnoteSerializer.save(filePath: filePath, data: data);

      final loaded = await service.loadScrapnote(id);

      expect(loaded, isNotNull);
      expect(loaded!.id, equals(id));
      expect(loaded.linkedPdfPath, equals('/path/load.pdf'));
    });

    test('loadScrapnote returns null for nonexistent id', () async {
      final loaded = await service.loadScrapnote('nonexistent-id');
      expect(loaded, isNull);
    });

    test('saveScrapnote writes data to .gma file', () async {
      final data = ScrapnoteCanvasData(
        id: 'save-test-id',
        linkedPdfPath: '/path/save.pdf',
        strokes: const [],
        elements: const [],
        createdAt: DateTime(2024, 1, 1),
        modifiedAt: DateTime(2024, 1, 1),
      );

      await service.saveScrapnote(data);

      final filePath = ScrapnoteSerializer.buildFilePath(tempDir.path, data.id);
      final file = File(filePath);
      expect(await file.exists(), isTrue);

      // Reload and verify
      final loaded = await service.loadScrapnote(data.id);
      expect(loaded, isNotNull);
      expect(loaded!.linkedPdfPath, equals('/path/save.pdf'));
    });
  });
}
