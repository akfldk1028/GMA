import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/models/element_model.dart';
import 'package:gma_app/features/scrapnote/providers/element_store.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late ProviderContainer container;

  const rect = ElementRect(left: 0.1, top: 0.2, right: 0.8, bottom: 0.4);
  final baseTime = DateTime(2024, 3, 1);

  ScrapElement makeHighlight({
    String id = 'elem-1',
    String pdfPath = '/docs/test.pdf',
    String selectedText = 'Sample text',
    int page = 1,
    int color = 0xFFFFEB3B,
  }) {
    return ScrapElement(
      id: id,
      type: ScrapElementType.highlight,
      pdfPath: pdfPath,
      selectedText: selectedText,
      sourcePageNumber: page,
      sourceRect: rect,
      colorValue: color,
      createdAt: baseTime,
    );
  }

  ScrapElement makeCapture({
    String id = 'cap-1',
    String pdfPath = '/docs/report.pdf',
    String imagePath = '/captures/img.png',
    int page = 2,
  }) {
    return ScrapElement(
      id: id,
      type: ScrapElementType.capture,
      pdfPath: pdfPath,
      imagePath: imagePath,
      sourcePageNumber: page,
      sourceRect: rect,
      createdAt: baseTime,
    );
  }

  setUpAll(() async {
    // Use an in-memory Hive for tests
    Hive.init('test_hive');
  });

  setUp(() async {
    // Clean up any open boxes before each test
    if (Hive.isBoxOpen('element_store')) {
      await Hive.box('element_store').clear();
    }
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    if (Hive.isBoxOpen('element_store')) {
      await Hive.box('element_store').clear();
    }
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('ElementStoreNotifier initial state', () {
    test('starts with empty list', () {
      final store = container.read(elementStoreNotifierProvider);
      expect(store, isEmpty);
    });
  });

  group('ElementStoreNotifier addElement', () {
    test('adds element to state', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );
      final element = makeHighlight();

      await notifier.addElement(element);

      final state = container.read(elementStoreNotifierProvider);
      expect(state, hasLength(1));
      expect(state.first.id, 'elem-1');
    });

    test('adds multiple elements', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );

      await notifier.addElement(makeHighlight(id: 'h1'));
      await notifier.addElement(makeHighlight(id: 'h2'));
      await notifier.addElement(makeCapture(id: 'c1'));

      final state = container.read(elementStoreNotifierProvider);
      expect(state, hasLength(3));
    });

    test('persists element to Hive', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );
      final element = makeHighlight(id: 'persist-test');

      await notifier.addElement(element);

      final box = await Hive.openBox('element_store');
      expect(box.containsKey('persist-test'), isTrue);
    });
  });

  group('ElementStoreNotifier removeElement', () {
    test('removes element by id', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );

      await notifier.addElement(makeHighlight(id: 'to-remove'));
      await notifier.addElement(makeHighlight(id: 'to-keep'));
      await notifier.removeElement('to-remove');

      final state = container.read(elementStoreNotifierProvider);
      expect(state, hasLength(1));
      expect(state.first.id, 'to-keep');
    });

    test('no-op when id does not exist', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );

      await notifier.addElement(makeHighlight(id: 'keep'));
      await notifier.removeElement('nonexistent');

      final state = container.read(elementStoreNotifierProvider);
      expect(state, hasLength(1));
    });

    test('deletes element from Hive', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );
      const id = 'hive-del';
      await notifier.addElement(makeHighlight(id: id));
      await notifier.removeElement(id);

      final box = await Hive.openBox('element_store');
      expect(box.containsKey(id), isFalse);
    });
  });

  group('ElementStoreNotifier getElementsByPdf', () {
    test('returns elements for the given pdf path', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );

      await notifier.addElement(
        makeHighlight(id: 'h1', pdfPath: '/a.pdf'),
      );
      await notifier.addElement(
        makeHighlight(id: 'h2', pdfPath: '/b.pdf'),
      );
      await notifier.addElement(
        makeHighlight(id: 'h3', pdfPath: '/a.pdf'),
      );

      final result = container
          .read(elementStoreNotifierProvider.notifier)
          .getElementsByPdf('/a.pdf');
      expect(result, hasLength(2));
      expect(result.map((e) => e.id), containsAll(['h1', 'h3']));
    });

    test('returns empty list when no elements match', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );
      await notifier.addElement(makeHighlight(pdfPath: '/x.pdf'));

      final result = container
          .read(elementStoreNotifierProvider.notifier)
          .getElementsByPdf('/y.pdf');
      expect(result, isEmpty);
    });
  });

  group('ElementStoreNotifier getElementsByType', () {
    test('returns only highlights when filtering by highlight type', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );

      await notifier.addElement(makeHighlight(id: 'h1'));
      await notifier.addElement(makeHighlight(id: 'h2'));
      await notifier.addElement(makeCapture(id: 'c1'));

      final highlights = container
          .read(elementStoreNotifierProvider.notifier)
          .getElementsByType(ScrapElementType.highlight);
      expect(highlights, hasLength(2));
      expect(highlights.every((e) => e.type == ScrapElementType.highlight),
          isTrue);
    });

    test('returns only captures when filtering by capture type', () async {
      final notifier = container.read(
        elementStoreNotifierProvider.notifier,
      );

      await notifier.addElement(makeHighlight(id: 'h1'));
      await notifier.addElement(makeCapture(id: 'c1'));
      await notifier.addElement(makeCapture(id: 'c2'));

      final captures = container
          .read(elementStoreNotifierProvider.notifier)
          .getElementsByType(ScrapElementType.capture);
      expect(captures, hasLength(2));
      expect(
          captures.every((e) => e.type == ScrapElementType.capture), isTrue);
    });
  });

  group('ElementStoreNotifier loadElements', () {
    test('loads previously persisted elements from Hive', () async {
      // First container: add element
      final container1 = ProviderContainer();
      await container1.read(elementStoreNotifierProvider.notifier).addElement(
            makeHighlight(id: 'load-test'),
          );
      container1.dispose();

      // Second container: load from Hive
      final container2 = ProviderContainer();
      await container2.read(elementStoreNotifierProvider.notifier).loadElements();
      final state = container2.read(elementStoreNotifierProvider);
      expect(state.any((e) => e.id == 'load-test'), isTrue);
      container2.dispose();
    });
  });
}
