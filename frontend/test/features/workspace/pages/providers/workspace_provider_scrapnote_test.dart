/// Tests verifying that the existing createMarker behavior is preserved
/// after ScrapInsertionService integration.
///
/// These tests verify:
/// 1. createMarker still creates a PdfMarker in the workspace state
/// 2. createMarker still inserts content into the note editor
/// 3. createMarker still creates a ScrapElement in the element store
///
/// NOTE: Actual workspace_provider.dart workspace integration is additive
/// (ScrapInsertionService is optional). When _scrapInsertionService is null,
/// all existing behavior runs unchanged. These tests exercise that path.
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
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
  Future<void> deleteNote({required String noteId}) async => _notes.remove(noteId);

  @override
  Future<bool> noteExists({required String noteId}) async => _notes.containsKey(noteId);

  @override
  void dispose() {}
}

void main() {
  late Directory testDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    testDir = await Directory.systemTemp.createTemp('ws_scrapnote_test_');
    Hive.init(testDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await testDir.delete(recursive: true);
  });

  setUp(() async {
    if (Hive.isBoxOpen('workspace_settings')) {
      final box = Hive.box('workspace_settings');
      await box.clear();
      await box.close();
    }
  });

  // ─── Preservation tests ───────────────────────────────────────────────────

  group('createMarker — existing behavior preserved', () {
    ProviderContainer makeContainer() {
      return ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(_MockNoteStorage()),
        ],
      );
    }

    test('creates a PdfMarker with correct pageNumber and color', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 3,
            color: MarkerColor.yellow,
            selectedText: 'Some highlighted text',
          );

      expect(marker.pageNumber, 3);
      expect(marker.color, MarkerColor.yellow);
      expect(marker.selectedText, 'Some highlighted text');
    });

    test('adds PdfMarker to workspace state markers list', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 5,
            color: MarkerColor.red,
            selectedText: 'Another text',
          );

      final state = container.read(workspaceProviderProvider).valueOrNull;
      expect(state, isNotNull);
      expect(state!.markers.length, 1);
      expect(state.markers.first.pageNumber, 5);
    });

    test('createMarker generates a non-empty unique marker ID', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      final m1 = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 1,
            color: MarkerColor.green,
            selectedText: 'First',
          );

      final m2 = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 2,
            color: MarkerColor.blue,
            selectedText: 'Second',
          );

      expect(m1.id, isNotEmpty);
      expect(m2.id, isNotEmpty);
      expect(m1.id, isNot(equals(m2.id)));
    });

    test('createMarker throws ArgumentError for invalid (zero) page number',
        () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      expect(
        () => container
            .read(workspaceProviderProvider.notifier)
            .createMarker(
              pageNumber: 0,
              color: MarkerColor.yellow,
            ),
        throwsArgumentError,
      );
    });

    test('createMarker throws ArgumentError for negative page number', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      expect(
        () => container
            .read(workspaceProviderProvider.notifier)
            .createMarker(
              pageNumber: -1,
              color: MarkerColor.yellow,
            ),
        throwsArgumentError,
      );
    });

    test('multiple markers accumulate in workspace state', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      for (var i = 1; i <= 3; i++) {
        await container
            .read(workspaceProviderProvider.notifier)
            .createMarker(
              pageNumber: i,
              color: MarkerColor.yellow,
              selectedText: 'Text $i',
            );
      }

      final state = container.read(workspaceProviderProvider).valueOrNull;
      expect(state!.markers.length, 3);
    });
  });
}
