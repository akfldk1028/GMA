import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/models/drawing_model.dart';
import 'package:gma_app/features/drawing/utils/drawing_serializer.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('drawing_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DrawingSerializer.buildFilePath', () {
    test('builds path with document name', () {
      final filePath = DrawingSerializer.buildFilePath('/captures', 'doc.pdf');
      expect(filePath, contains('_drawings.json'));
      expect(filePath, contains('/captures'));
    });

    test('sanitizes path separators in document path', () {
      // A document path with slashes should produce a safe filename
      final filePath = DrawingSerializer.buildFilePath(
        '/captures',
        '/home/user/documents/doc.pdf',
      );
      // Extract just the filename part (after the last separator)
      final filename = path.basename(filePath);
      expect(filename, isNot(contains('/')));
      expect(filename, isNot(contains('\\')));
      expect(filename, endsWith('_drawings.json'));
    });

    test('two different documents produce different file paths', () {
      final path1 =
          DrawingSerializer.buildFilePath('/captures', 'doc1.pdf');
      final path2 =
          DrawingSerializer.buildFilePath('/captures', 'doc2.pdf');
      expect(path1, isNot(equals(path2)));
    });
  });

  group('DrawingSerializer save and load', () {
    test('save creates file with strokes', () async {
      final filePath =
          path.join(tempDir.path, 'test_drawings.json');
      const stroke = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [StrokePoint(x: 0.1, y: 0.2)],
        toolId: 'pen',
        colorValue: 0xFF000000,
        size: 3.0,
      );

      await DrawingSerializer.save(
        filePath: filePath,
        pageStrokes: {
          1: [stroke],
        },
      );

      expect(await File(filePath).exists(), isTrue);
    });

    test('load returns empty map for non-existent file', () async {
      final filePath = path.join(tempDir.path, 'nonexistent.json');
      final result = await DrawingSerializer.load(filePath: filePath);
      expect(result, isEmpty);
    });

    test('save and load round-trip preserves stroke data', () async {
      final filePath = path.join(tempDir.path, 'round_trip.json');
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

      await DrawingSerializer.save(
        filePath: filePath,
        pageStrokes: {
          2: [stroke],
        },
      );

      final loaded = await DrawingSerializer.load(filePath: filePath);

      expect(loaded[2], hasLength(1));
      final loadedStroke = loaded[2]!.first;
      expect(loadedStroke.id, stroke.id);
      expect(loadedStroke.pageNumber, stroke.pageNumber);
      expect(loadedStroke.toolId, stroke.toolId);
      expect(loadedStroke.colorValue, stroke.colorValue);
      expect(loadedStroke.size, stroke.size);
      expect(loadedStroke.points, hasLength(2));
      expect(loadedStroke.points[0].x, closeTo(0.1, 0.001));
      expect(loadedStroke.points[0].y, closeTo(0.2, 0.001));
      expect(loadedStroke.points[1].pressure, closeTo(0.6, 0.001));
    });

    test('save and load multiple pages', () async {
      final filePath = path.join(tempDir.path, 'multi_page.json');
      const stroke1 = DrawingStroke(
        id: 's1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );
      const stroke2 = DrawingStroke(
        id: 's2',
        pageNumber: 3,
        points: [],
        toolId: 'highlighter',
      );
      const stroke3 = DrawingStroke(
        id: 's3',
        pageNumber: 3,
        points: [],
        toolId: 'pen',
      );

      await DrawingSerializer.save(
        filePath: filePath,
        pageStrokes: {
          1: [stroke1],
          3: [stroke2, stroke3],
        },
      );

      final loaded = await DrawingSerializer.load(filePath: filePath);

      expect(loaded[1], hasLength(1));
      expect(loaded[3], hasLength(2));
      expect(loaded[1]!.first.id, 's1');
    });

    test('load handles empty strokes gracefully', () async {
      final filePath = path.join(tempDir.path, 'empty.json');

      await DrawingSerializer.save(
        filePath: filePath,
        pageStrokes: {},
      );

      final loaded = await DrawingSerializer.load(filePath: filePath);
      expect(loaded, isEmpty);
    });

    test('load handles corrupt JSON gracefully', () async {
      final filePath = path.join(tempDir.path, 'corrupt.json');
      await File(filePath).writeAsString('{invalid json!!!}');

      final loaded = await DrawingSerializer.load(filePath: filePath);
      expect(loaded, isEmpty);
    });

    test('load handles missing strokes key gracefully', () async {
      final filePath = path.join(tempDir.path, 'missing_key.json');
      await File(filePath).writeAsString('{"other_key": []}');

      final loaded = await DrawingSerializer.load(filePath: filePath);
      expect(loaded, isEmpty);
    });
  });
}
