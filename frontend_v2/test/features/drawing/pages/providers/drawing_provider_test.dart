import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/models/drawing_model.dart';
import 'package:gma_app/features/drawing/pages/providers/drawing_provider.dart';

/// Fake DrawingStrokes that returns empty data without file I/O.
class _FakeDrawingStrokes extends DrawingStrokes {
  @override
  Future<DrawingData> build(String documentPath) async {
    return const DrawingData();
  }
}

void main() {
  group('DrawingMode provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has defaults', () {
      final state = container.read(drawingModeProvider);
      expect(state.isActive, isFalse);
      expect(state.currentToolId, 'pen');
      expect(state.colorValue, 0xFF000000);
      expect(state.strokeSize, 3.0);
    });

    test('selectTool changes current tool', () {
      container.read(drawingModeProvider.notifier).selectTool('highlighter');
      expect(container.read(drawingModeProvider).currentToolId, 'highlighter');
    });

    test('setColor changes color value', () {
      container.read(drawingModeProvider.notifier).setColor(0xFFFF0000);
      expect(container.read(drawingModeProvider).colorValue, 0xFFFF0000);
    });

    test('setSize changes stroke size', () {
      container.read(drawingModeProvider.notifier).setSize(8.0);
      expect(container.read(drawingModeProvider).strokeSize, 8.0);
    });

    test('toggleActive flips active state', () {
      expect(container.read(drawingModeProvider).isActive, isFalse);
      container.read(drawingModeProvider.notifier).toggleActive();
      expect(container.read(drawingModeProvider).isActive, isTrue);
      container.read(drawingModeProvider.notifier).toggleActive();
      expect(container.read(drawingModeProvider).isActive, isFalse);
    });

    test('setActive sets exact active state', () {
      container.read(drawingModeProvider.notifier).setActive(true);
      expect(container.read(drawingModeProvider).isActive, isTrue);
      container.read(drawingModeProvider.notifier).setActive(false);
      expect(container.read(drawingModeProvider).isActive, isFalse);
    });
  });

  group('DrawingStrokes provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Override file system access to avoid actual file I/O in tests
          drawingStrokesProvider('test-document.pdf').overrideWith(
            () => _FakeDrawingStrokes(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty DrawingData', () async {
      final state = await container.read(
        drawingStrokesProvider('test-document.pdf').future,
      );
      expect(state.pageStrokes, isEmpty);
      expect(state.undoStack, isEmpty);
    });

    test('addStroke adds stroke to correct page', () async {
      // Wait for initial load
      await container.read(drawingStrokesProvider('test-document.pdf').future);

      const stroke = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [StrokePoint(x: 0.1, y: 0.2)],
        toolId: 'pen',
      );
      container
          .read(drawingStrokesProvider('test-document.pdf').notifier)
          .addStroke(stroke);

      final state = container
          .read(drawingStrokesProvider('test-document.pdf'))
          .valueOrNull;
      expect(state?.pageStrokes[1], hasLength(1));
      expect(state?.pageStrokes[1]?.first.id, 'stroke-1');
    });

    test('addStroke clears undo stack', () async {
      await container.read(drawingStrokesProvider('test-document.pdf').future);

      const stroke = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );

      container
          .read(drawingStrokesProvider('test-document.pdf').notifier)
          .addStroke(stroke);

      final state = container
          .read(drawingStrokesProvider('test-document.pdf'))
          .valueOrNull;
      expect(state?.undoStack, isEmpty);
    });

    test('undo removes last stroke and adds to undo stack', () async {
      await container.read(drawingStrokesProvider('test-document.pdf').future);

      const stroke = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );

      final notifier = container
          .read(drawingStrokesProvider('test-document.pdf').notifier);
      notifier.addStroke(stroke);
      notifier.undo(1);

      final state = container
          .read(drawingStrokesProvider('test-document.pdf'))
          .valueOrNull;
      expect(state?.pageStrokes[1], isEmpty);
      expect(state?.undoStack, hasLength(1));
      expect(state?.undoStack.first.id, 'stroke-1');
    });

    test('redo restores stroke from undo stack', () async {
      await container.read(drawingStrokesProvider('test-document.pdf').future);

      const stroke = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 1,
        points: [],
        toolId: 'pen',
      );

      final notifier = container
          .read(drawingStrokesProvider('test-document.pdf').notifier);
      notifier.addStroke(stroke);
      notifier.undo(1);
      notifier.redo(1);

      final state = container
          .read(drawingStrokesProvider('test-document.pdf'))
          .valueOrNull;
      expect(state?.pageStrokes[1], hasLength(1));
      expect(state?.undoStack, isEmpty);
    });

    test('removeStroke removes stroke by id from page', () async {
      await container.read(drawingStrokesProvider('test-document.pdf').future);

      const stroke1 = DrawingStroke(
        id: 'stroke-1',
        pageNumber: 2,
        points: [],
        toolId: 'pen',
      );
      const stroke2 = DrawingStroke(
        id: 'stroke-2',
        pageNumber: 2,
        points: [],
        toolId: 'pen',
      );

      final notifier = container
          .read(drawingStrokesProvider('test-document.pdf').notifier);
      notifier.addStroke(stroke1);
      notifier.addStroke(stroke2);
      notifier.removeStroke(2, 'stroke-1');

      final state = container
          .read(drawingStrokesProvider('test-document.pdf'))
          .valueOrNull;
      expect(state?.pageStrokes[2], hasLength(1));
      expect(state?.pageStrokes[2]?.first.id, 'stroke-2');
    });
  });
}
