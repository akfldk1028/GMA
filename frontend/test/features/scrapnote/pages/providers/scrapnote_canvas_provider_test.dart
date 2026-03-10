import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gma_frontend/features/pdf_viewer/drawing/models/drawing_model.dart';
import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/scrapnote/pages/providers/scrapnote_canvas_provider.dart';
import 'package:gma_frontend/features/scrapnote/utils/scrapnote_serializer.dart';
import 'package:gma_frontend/utils/file_system_provider.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('scrapnote_provider_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// Create a ProviderContainer that overrides notesRootDirectoryProvider
  /// with the temp directory so no real filesystem is used.
  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        notesRootDirectoryProvider.overrideWith((_) async => tempDir),
      ],
    );
  }

  Future<void> seedGmaFile(Directory dir, String id,
      {List<CanvasElement> elements = const []}) async {
    final data = ScrapnoteCanvasData(
      id: id,
      linkedPdfPath: '/tmp/test.pdf',
      strokes: const [],
      elements: elements,
      createdAt: DateTime(2024, 1, 1),
      modifiedAt: DateTime(2024, 1, 1),
    );
    final filePath = ScrapnoteSerializer.buildFilePath(dir.path, id);
    await ScrapnoteSerializer.save(filePath: filePath, data: data);
  }

  group('ScrapnoteCanvasState provider', () {
    test('loads canvas data from .gma file on build', () async {
      const id = 'canvas-load-test';
      await seedGmaFile(tempDir, id);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        scrapnoteCanvasStateProvider(id).future,
      );

      expect(result.id, equals(id));
      expect(result.strokes, isEmpty);
    });

    test('addStroke appends stroke to state', () async {
      const id = 'canvas-add-stroke-test';
      await seedGmaFile(tempDir, id);

      final container = makeContainer();
      addTearDown(container.dispose);

      // Keep the provider alive via a listener
      final subscription = container.listen(
        scrapnoteCanvasStateProvider(id),
        (prev, next) {},
      );
      addTearDown(subscription.close);

      // Wait for initial load
      await container.read(scrapnoteCanvasStateProvider(id).future);

      final notifier = container.read(
        scrapnoteCanvasStateProvider(id).notifier,
      );

      final stroke = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 0,
        toolId: 'pen',
        colorValue: 0xFF000000,
        size: 3.0,
        points: const [
          StrokePoint(x: 100, y: 100),
          StrokePoint(x: 200, y: 200),
        ],
      );

      notifier.addStroke(stroke);

      final updated = container.read(scrapnoteCanvasStateProvider(id)).valueOrNull;

      expect(updated, isNotNull);
      expect(updated!.strokes.length, equals(1));
      expect(updated.strokes.first.id, equals('stroke-1'));
    });

    test('undo removes last stroke', () async {
      const id = 'canvas-undo-test';
      await seedGmaFile(tempDir, id);

      final container = makeContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        scrapnoteCanvasStateProvider(id),
        (prev, next) {},
      );
      addTearDown(subscription.close);

      await container.read(scrapnoteCanvasStateProvider(id).future);

      final notifier = container.read(
        scrapnoteCanvasStateProvider(id).notifier,
      );

      final stroke = DrawingStroke(
        id: 'stroke-undo',
        pageNumber: 0,
        toolId: 'pen',
        colorValue: 0xFF000000,
        size: 3.0,
        points: const [
          StrokePoint(x: 10, y: 10),
          StrokePoint(x: 20, y: 20),
        ],
      );

      notifier.addStroke(stroke);
      final afterAdd = container
          .read(scrapnoteCanvasStateProvider(id))
          .valueOrNull;
      expect(afterAdd!.strokes.length, equals(1));

      notifier.undo();
      final afterUndo = container
          .read(scrapnoteCanvasStateProvider(id))
          .valueOrNull;
      expect(afterUndo!.strokes, isEmpty);
    });

    test('redo restores undone stroke', () async {
      const id = 'canvas-redo-test';
      await seedGmaFile(tempDir, id);

      final container = makeContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        scrapnoteCanvasStateProvider(id),
        (prev, next) {},
      );
      addTearDown(subscription.close);

      await container.read(scrapnoteCanvasStateProvider(id).future);

      final notifier = container.read(
        scrapnoteCanvasStateProvider(id).notifier,
      );

      final stroke = DrawingStroke(
        id: 'stroke-redo',
        pageNumber: 0,
        toolId: 'pen',
        colorValue: 0xFF000000,
        size: 3.0,
        points: const [
          StrokePoint(x: 5, y: 5),
          StrokePoint(x: 15, y: 15),
        ],
      );

      notifier.addStroke(stroke);
      notifier.undo();

      final afterUndo = container
          .read(scrapnoteCanvasStateProvider(id))
          .valueOrNull;
      expect(afterUndo!.strokes, isEmpty);

      notifier.redo();
      final afterRedo = container
          .read(scrapnoteCanvasStateProvider(id))
          .valueOrNull;
      expect(afterRedo!.strokes.length, equals(1));
      expect(afterRedo.strokes.first.id, equals('stroke-redo'));
    });

    test('addElement adds element to elements list', () async {
      const id = 'canvas-add-element-test';
      await seedGmaFile(tempDir, id);

      final container = makeContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        scrapnoteCanvasStateProvider(id),
        (prev, next) {},
      );
      addTearDown(subscription.close);

      await container.read(scrapnoteCanvasStateProvider(id).future);

      final notifier = container.read(
        scrapnoteCanvasStateProvider(id).notifier,
      );

      final element = CanvasElement(
        id: 'elem-1',
        type: CanvasElementType.capture,
        x: 50,
        y: 100,
        width: 200,
        height: 150,
        createdAt: DateTime(2024, 1, 1),
      );

      notifier.addElement(element);

      final updated = container
          .read(scrapnoteCanvasStateProvider(id))
          .valueOrNull;

      expect(updated, isNotNull);
      expect(updated!.elements.length, equals(1));
      expect(updated.elements.first.id, equals('elem-1'));
    });

    test('removeElement removes element from elements list', () async {
      const id = 'canvas-remove-element-test';

      await seedGmaFile(
        tempDir,
        id,
        elements: [
          CanvasElement(
            id: 'elem-to-remove',
            type: CanvasElementType.capture,
            x: 0,
            y: 0,
            width: 100,
            height: 100,
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        scrapnoteCanvasStateProvider(id),
        (prev, next) {},
      );
      addTearDown(subscription.close);

      await container.read(scrapnoteCanvasStateProvider(id).future);

      final notifier = container.read(
        scrapnoteCanvasStateProvider(id).notifier,
      );

      notifier.removeElement('elem-to-remove');

      final updated = container
          .read(scrapnoteCanvasStateProvider(id))
          .valueOrNull;

      expect(updated, isNotNull);
      expect(updated!.elements, isEmpty);
    });

    test('repositionElement updates element x and y', () async {
      const id = 'canvas-reposition-test';

      await seedGmaFile(
        tempDir,
        id,
        elements: [
          CanvasElement(
            id: 'elem-reposition',
            type: CanvasElementType.highlight,
            x: 0,
            y: 0,
            width: 100,
            height: 100,
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        scrapnoteCanvasStateProvider(id),
        (prev, next) {},
      );
      addTearDown(subscription.close);

      await container.read(scrapnoteCanvasStateProvider(id).future);

      final notifier = container.read(
        scrapnoteCanvasStateProvider(id).notifier,
      );

      notifier.repositionElement('elem-reposition', 300, 400);

      final updated = container
          .read(scrapnoteCanvasStateProvider(id))
          .valueOrNull;

      expect(updated, isNotNull);
      expect(updated!.elements.first.x, equals(300));
      expect(updated.elements.first.y, equals(400));
    });
  });
}
