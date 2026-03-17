import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/services/scrapnote_service.dart';
import 'package:gma_app/features/scrapnote/utils/scrapnote_serializer.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('scrapnote_svc_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ScrapnoteService.getOrCreate', () {
    const pdfPath = '/docs/test.pdf';

    test('creates a new .gma file when none exists', () async {
      final canvas = await ScrapnoteService.getOrCreate(
        scrapnotesDir: tempDir.path,
        pdfPath: pdfPath,
      );

      final expectedPath = ScrapnoteSerializer.buildFilePath(
        tempDir.path,
        pdfPath,
      );
      expect(await File(expectedPath).exists(), isTrue);
      expect(canvas.linkedPdfPath, pdfPath);
      expect(canvas.id, isNotEmpty);
    });

    test('returns default empty canvas for new file', () async {
      final canvas = await ScrapnoteService.getOrCreate(
        scrapnotesDir: tempDir.path,
        pdfPath: pdfPath,
      );

      expect(canvas.canvasMode, 'infinite');
      expect(canvas.strokes, isEmpty);
      expect(canvas.elements, isEmpty);
    });

    test('returns existing data when file already exists', () async {
      // Create the file on first call
      final first = await ScrapnoteService.getOrCreate(
        scrapnotesDir: tempDir.path,
        pdfPath: pdfPath,
      );

      // Second call should return same canvas (same id)
      final second = await ScrapnoteService.getOrCreate(
        scrapnotesDir: tempDir.path,
        pdfPath: pdfPath,
      );

      expect(second.id, first.id);
      expect(second.linkedPdfPath, first.linkedPdfPath);
    });

    test('different PDF paths produce separate canvas files', () async {
      final canvas1 = await ScrapnoteService.getOrCreate(
        scrapnotesDir: tempDir.path,
        pdfPath: '/docs/doc1.pdf',
      );
      final canvas2 = await ScrapnoteService.getOrCreate(
        scrapnotesDir: tempDir.path,
        pdfPath: '/docs/doc2.pdf',
      );

      expect(canvas1.id, isNot(equals(canvas2.id)));
      expect(canvas1.linkedPdfPath, '/docs/doc1.pdf');
      expect(canvas2.linkedPdfPath, '/docs/doc2.pdf');

      final file1 = ScrapnoteSerializer.buildFilePath(
        tempDir.path,
        '/docs/doc1.pdf',
      );
      final file2 = ScrapnoteSerializer.buildFilePath(
        tempDir.path,
        '/docs/doc2.pdf',
      );
      expect(path.basename(file1), isNot(equals(path.basename(file2))));
    });
  });
}
