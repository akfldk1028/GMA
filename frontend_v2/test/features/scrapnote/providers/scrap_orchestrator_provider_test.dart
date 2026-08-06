import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/models/element_model.dart';
import 'package:gma_app/features/scrapnote/providers/element_store.dart';
import 'package:gma_app/features/scrapnote/providers/scrap_orchestrator_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late ProviderContainer container;

  const rect = ElementRect(left: 0.05, top: 0.1, right: 0.95, bottom: 0.3);

  setUpAll(() async {
    Hive.init('test_hive_orch');
  });

  setUp(() async {
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

  group('ScrapOrchestrator createHighlight', () {
    test('returns a ScrapElement of type highlight', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      final element = await orchestrator.createHighlight(
        pdfPath: '/docs/test.pdf',
        selectedText: 'Important passage',
        pageNumber: 3,
        sourceRect: rect,
      );

      expect(element.type, ScrapElementType.highlight);
      expect(element.pdfPath, '/docs/test.pdf');
      expect(element.selectedText, 'Important passage');
      expect(element.sourcePageNumber, 3);
      expect(element.sourceRect, rect);
    });

    test('uses default yellow color when colorValue not provided', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      final element = await orchestrator.createHighlight(
        pdfPath: '/docs/test.pdf',
        selectedText: 'text',
        pageNumber: 1,
        sourceRect: rect,
      );

      expect(element.colorValue, 0xFFFFEB3B);
    });

    test('respects provided colorValue', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      final element = await orchestrator.createHighlight(
        pdfPath: '/docs/test.pdf',
        selectedText: 'green highlight',
        pageNumber: 2,
        sourceRect: rect,
        colorValue: 0xFF4CAF50,
      );

      expect(element.colorValue, 0xFF4CAF50);
    });

    test('generates a non-empty UUID id', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      final element = await orchestrator.createHighlight(
        pdfPath: '/docs/test.pdf',
        selectedText: 'some text',
        pageNumber: 1,
        sourceRect: rect,
      );

      expect(element.id, isNotEmpty);
      expect(element.id.length, greaterThan(10));
    });

    test('generates unique ids for each element', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      final e1 = await orchestrator.createHighlight(
        pdfPath: '/docs/test.pdf',
        selectedText: 'first',
        pageNumber: 1,
        sourceRect: rect,
      );
      final e2 = await orchestrator.createHighlight(
        pdfPath: '/docs/test.pdf',
        selectedText: 'second',
        pageNumber: 1,
        sourceRect: rect,
      );

      expect(e1.id, isNot(equals(e2.id)));
    });

    test('persists element to ElementStore', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      await orchestrator.createHighlight(
        pdfPath: '/docs/stored.pdf',
        selectedText: 'persisted text',
        pageNumber: 1,
        sourceRect: rect,
      );

      final store = container.read(elementStoreNotifierProvider);
      expect(store, hasLength(1));
      expect(store.first.pdfPath, '/docs/stored.pdf');
    });

    test('sets createdAt to a recent time', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      final element = await orchestrator.createHighlight(
        pdfPath: '/docs/test.pdf',
        selectedText: 'time test',
        pageNumber: 1,
        sourceRect: rect,
      );

      final after = DateTime.now().add(const Duration(seconds: 1));
      expect(element.createdAt.isAfter(before), isTrue);
      expect(element.createdAt.isBefore(after), isTrue);
    });
  });

  group('ScrapOrchestrator createCapture', () {
    test('returns a ScrapElement of type capture', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      final element = await orchestrator.createCapture(
        pdfPath: '/docs/report.pdf',
        imagePath: '/captures/page3.png',
        pageNumber: 3,
        sourceRect: rect,
      );

      expect(element.type, ScrapElementType.capture);
      expect(element.pdfPath, '/docs/report.pdf');
      expect(element.imagePath, '/captures/page3.png');
      expect(element.selectedText, isNull);
      expect(element.sourcePageNumber, 3);
    });

    test('generates a non-empty UUID id', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      final element = await orchestrator.createCapture(
        pdfPath: '/docs/report.pdf',
        imagePath: '/captures/img.png',
        pageNumber: 1,
        sourceRect: rect,
      );

      expect(element.id, isNotEmpty);
    });

    test('persists capture element to ElementStore', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      await orchestrator.createCapture(
        pdfPath: '/docs/capture.pdf',
        imagePath: '/captures/snap.png',
        pageNumber: 2,
        sourceRect: rect,
      );

      final store = container.read(elementStoreNotifierProvider);
      expect(store, hasLength(1));
      expect(store.first.type, ScrapElementType.capture);
    });

    test('mixed creates store multiple elements', () async {
      final orchestrator = container.read(scrapOrchestratorProvider.notifier);

      await orchestrator.createHighlight(
        pdfPath: '/docs/test.pdf',
        selectedText: 'highlighted',
        pageNumber: 1,
        sourceRect: rect,
      );
      await orchestrator.createCapture(
        pdfPath: '/docs/test.pdf',
        imagePath: '/captures/snap.png',
        pageNumber: 2,
        sourceRect: rect,
      );

      final store = container.read(elementStoreNotifierProvider);
      expect(store, hasLength(2));
    });
  });
}
