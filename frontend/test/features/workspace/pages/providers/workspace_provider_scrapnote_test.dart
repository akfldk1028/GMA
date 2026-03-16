/// Integration tests verifying the scrapnote end-to-end flow:
///
/// 1. loadPdf sets currentPdfPath on the workspace state
/// 2. After loadPdf, currentNoteId is set (virtualNoteId for assets)
/// 3. PDF registry registers the asset path and returns a UUID
/// 4. ScrapElement can be added to elementStore with the pdfId
/// 5. elementStore.getByPdfId(pdfId) returns the added element
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gma_frontend/features/scrapnote/models/element_model.dart';
import 'package:gma_frontend/features/scrapnote/models/pdf_registry.dart';
import 'package:gma_frontend/features/scrapnote/providers/element_store.dart';
import 'package:gma_frontend/features/scrapnote/providers/pdf_registry_provider.dart';
import 'package:gma_frontend/features/workspace/pages/providers/workspace_provider.dart';
import 'package:gma_frontend/utils/note_storage_service.dart';

/// Minimal mock NoteStorageService — records saves without touching the filesystem.
class _MockNoteStorage implements NoteStorageService {
  final Map<String, String> _notes = {};

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<void> saveNote({required String noteId, required String content}) async {
    _notes[noteId] = content;
  }

  @override
  Future<void> saveNoteImmediate({
    required String noteId,
    required String content,
  }) async {
    _notes[noteId] = content;
  }

  @override
  Future<String?> loadNote({required String noteId}) async => _notes[noteId];

  @override
  Future<void> deleteNote({required String noteId}) async =>
      _notes.remove(noteId);

  @override
  Future<bool> noteExists({required String noteId}) async =>
      _notes.containsKey(noteId);

  @override
  void dispose() {}
}

void main() {
  late Directory testDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    testDir = await Directory.systemTemp.createTemp('ws_scrapnote_int_test_');
    Hive.init(testDir.path);
    // Open boxes needed by the providers under test.
    await Hive.openBox<String>('pdf_registry');
    await Hive.openBox<String>('element_store');
  });

  tearDownAll(() async {
    await Hive.close();
    await testDir.delete(recursive: true);
  });

  setUp(() async {
    // Clear typed String boxes before every test to guarantee isolation.
    for (final name in ['pdf_registry', 'element_store']) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<String>(name).clear();
      }
    }
    // workspace_settings is an untyped box (opened lazily by the provider).
    if (Hive.isBoxOpen('workspace_settings')) {
      await Hive.box('workspace_settings').clear();
    }
  });

  // ─── Helper ───────────────────────────────────────────────────────────────

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        noteStorageServiceProvider.overrideWithValue(_MockNoteStorage()),
      ],
    );
  }

  // ─── Tests ────────────────────────────────────────────────────────────────

  group('ScrapNote integration — loadPdf + registry + elementStore', () {
    const assetPath = 'assets/sample/sample_math.pdf';

    test('(a) loadPdf sets currentPdfPath correctly', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);
      await container
          .read(workspaceProviderProvider.notifier)
          .loadPdf(assetPath);

      final state = container.read(workspaceProviderProvider).valueOrNull;
      expect(state, isNotNull);
      expect(state!.currentPdfPath, assetPath);
    });

    test('(b) loadPdf sets currentNoteId (virtualNoteId for assets)', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);
      await container
          .read(workspaceProviderProvider.notifier)
          .loadPdf(assetPath);

      final state = container.read(workspaceProviderProvider).valueOrNull;
      expect(state, isNotNull);
      expect(state!.currentNoteId, isNotNull);
      expect(state.currentNoteId, isNotEmpty);
    });

    test('(c) PDF registry registers the asset path and returns a UUID',
        () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      // Register via the provider directly (same Hive box as workspace uses).
      final pdfId = await container
          .read(pdfRegistryProvProvider.notifier)
          .register(assetPath);

      expect(pdfId, isNotEmpty);
      // UUID v4 format: 8-4-4-4-12 hex chars.
      expect(pdfId,
          matches(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'));

      // Idempotent — second registration returns the same ID.
      final pdfId2 = await container
          .read(pdfRegistryProvProvider.notifier)
          .register(assetPath);
      expect(pdfId2, pdfId);
    });

    test('(d) ScrapElement can be added to elementStore with pdfId', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      // Get a stable pdfId first.
      final pdfId = await container
          .read(pdfRegistryProvProvider.notifier)
          .register(assetPath);

      final element = ScrapElement(
        id: 'test-element-001',
        pdfId: pdfId,
        pageNumber: 2,
        type: ElementType.highlight,
        selectedText: 'Sample highlighted text',
        createdAt: DateTime(2024, 1, 1),
      );

      // Add should not throw.
      expect(
        () => container.read(elementStoreProvider.notifier).add(element),
        returnsNormally,
      );
    });

    test('(e) elementStore.getByPdfId returns the added element', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      final pdfId = await container
          .read(pdfRegistryProvProvider.notifier)
          .register(assetPath);

      final element = ScrapElement(
        id: 'test-element-002',
        pdfId: pdfId,
        pageNumber: 3,
        type: ElementType.highlight,
        selectedText: 'Another text',
        createdAt: DateTime(2024, 1, 2),
      );

      container.read(elementStoreProvider.notifier).add(element);

      final results =
          container.read(elementStoreProvider.notifier).getByPdfId(pdfId);

      expect(results, isNotEmpty);
      expect(results.any((e) => e.id == 'test-element-002'), isTrue);
      expect(results.first.pdfId, pdfId);
    });

    test('complete flow: loadPdf → registry → elementStore round-trip',
        () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      // Step 1: Initialize workspace.
      await container.read(workspaceProviderProvider.future);

      // Step 2: Load the asset PDF.
      await container
          .read(workspaceProviderProvider.notifier)
          .loadPdf(assetPath);

      // Step 3: Verify workspace state.
      final wsState = container.read(workspaceProviderProvider).valueOrNull;
      expect(wsState?.currentPdfPath, assetPath);
      expect(wsState?.currentNoteId, isNotNull);

      // Step 4: Get the pdfId that loadPdf registered.
      await container.read(pdfRegistryProvProvider.notifier).ensureReady();
      final pdfId = container
          .read(pdfRegistryProvProvider.notifier)
          .getIdByPath(assetPath);
      expect(pdfId, isNotNull);
      expect(pdfId, isNotEmpty);

      // Step 5: Create and store a ScrapElement for this PDF.
      final element = ScrapElement(
        id: 'flow-element-001',
        pdfId: pdfId!,
        pageNumber: 1,
        type: ElementType.capture,
        imagePath: '/path/to/capture.png',
        createdAt: DateTime.now(),
      );
      container.read(elementStoreProvider.notifier).add(element);

      // Step 6: Retrieve elements by pdfId.
      final retrieved =
          container.read(elementStoreProvider.notifier).getByPdfId(pdfId);
      expect(retrieved.length, greaterThanOrEqualTo(1));
      final found = retrieved.firstWhere((e) => e.id == 'flow-element-001');
      expect(found.pageNumber, 1);
      expect(found.type, ElementType.capture);
      expect(found.imagePath, '/path/to/capture.png');
    });
  });

  // ─── Standalone PDF Registry tests ────────────────────────────────────────

  group('PdfRegistry — direct unit tests', () {
    test('register and retrieve path by id', () async {
      final registry = PdfRegistry();
      await registry.init();

      const path = 'assets/sample/sample_math.pdf';
      final id = await registry.register(path);

      expect(id, isNotEmpty);
      expect(registry.getPathById(id), path);
      expect(registry.getIdByPath(path), id);
    });

    test('register is idempotent', () async {
      final registry = PdfRegistry();
      await registry.init();

      const path = 'assets/test/document.pdf';
      final id1 = await registry.register(path);
      final id2 = await registry.register(path);

      expect(id1, id2);
    });

    test('returns null for unknown path', () async {
      final registry = PdfRegistry();
      await registry.init();

      expect(registry.getIdByPath('unknown/path.pdf'), isNull);
    });
  });

  // ─── Standalone ElementStore tests ────────────────────────────────────────

  group('ElementStore — direct unit tests', () {
    test('add and getById round-trip', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      const pdfId = 'direct-pdf-id-001';
      final element = ScrapElement(
        id: 'direct-el-001',
        pdfId: pdfId,
        pageNumber: 5,
        type: ElementType.drawing,
        createdAt: DateTime(2024, 6, 15),
      );

      container.read(elementStoreProvider.notifier).add(element);

      final fetched =
          container.read(elementStoreProvider.notifier).getById('direct-el-001');
      expect(fetched, isNotNull);
      expect(fetched!.pageNumber, 5);
      expect(fetched.type, ElementType.drawing);
    });

    test('getByPdfId filters correctly', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final store = container.read(elementStoreProvider.notifier);

      store.add(ScrapElement(
        id: 'e1',
        pdfId: 'pdf-A',
        pageNumber: 1,
        type: ElementType.highlight,
        createdAt: DateTime(2024),
      ));
      store.add(ScrapElement(
        id: 'e2',
        pdfId: 'pdf-B',
        pageNumber: 2,
        type: ElementType.highlight,
        createdAt: DateTime(2024),
      ));
      store.add(ScrapElement(
        id: 'e3',
        pdfId: 'pdf-A',
        pageNumber: 3,
        type: ElementType.capture,
        createdAt: DateTime(2024),
      ));

      final forPdfA = store.getByPdfId('pdf-A');
      expect(forPdfA.length, 2);
      expect(forPdfA.map((e) => e.id).toSet(), {'e1', 'e3'});

      final forPdfB = store.getByPdfId('pdf-B');
      expect(forPdfB.length, 1);
      expect(forPdfB.first.id, 'e2');
    });

    test('delete removes element', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final store = container.read(elementStoreProvider.notifier);

      store.add(ScrapElement(
        id: 'to-delete',
        pdfId: 'pdf-X',
        pageNumber: 1,
        type: ElementType.highlight,
        createdAt: DateTime(2024),
      ));

      expect(store.getById('to-delete'), isNotNull);
      store.delete('to-delete');
      expect(store.getById('to-delete'), isNull);
    });
  });
}
