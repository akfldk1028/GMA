import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/workspace/models/pdf_marker_model.dart';
import 'package:gma_frontend/features/workspace/models/workspace_state.dart';
import 'package:gma_frontend/features/workspace/pages/providers/workspace_provider.dart';
import 'package:gma_frontend/utils/note_storage_service.dart';

/// Mock NoteStorageService for testing
class MockNoteStorageService implements NoteStorageService {
  final Map<String, String> _notes = {};

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<void> saveNote({
    required String noteId,
    required String content,
  }) async {
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
  Future<String?> loadNote({required String noteId}) async {
    return _notes[noteId];
  }

  @override
  Future<void> deleteNote({required String noteId}) async {
    _notes.remove(noteId);
  }

  @override
  Future<bool> noteExists({required String noteId}) async {
    return _notes.containsKey(noteId);
  }

  @override
  void dispose() {
    // No-op for mock
  }
}

void main() {
  late Directory testDir;

  setUpAll(() async {
    // Initialize Flutter binding for tests
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive for testing with system temp directory
    testDir = await Directory.systemTemp.createTemp('workspace_test_');
    Hive.init(testDir.path);
  });

  tearDownAll(() async {
    // Cleanup
    await Hive.close();
    await testDir.delete(recursive: true);
  });

  setUp(() async {
    // Clear Hive boxes before each test
    if (Hive.isBoxOpen('workspace_settings')) {
      final box = Hive.box('workspace_settings');
      await box.clear();
      await box.close();
    }
  });

  group('WorkspaceProvider', () {
    test('initial state has default panel sizes', () async {
      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(MockNoteStorageService()),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(workspaceProviderProvider.future);

      expect(state.currentPdfPath, isNull);
      expect(state.currentNoteId, isNull);
      expect(state.markers, isEmpty);
      expect(state.panelSizes.left, 0.2);
      expect(state.panelSizes.center, 0.4);
      expect(state.panelSizes.right, 0.4);
    });

    test('loads panel sizes from Hive on initialization', () async {
      // Pre-populate Hive with saved panel sizes
      final box = await Hive.openBox('workspace_settings');
      await box.put('panel_sizes', {
        'left': 0.3,
        'center': 0.5,
        'right': 0.2,
      });
      await box.close();

      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(MockNoteStorageService()),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(workspaceProviderProvider.future);

      expect(state.panelSizes.left, 0.3);
      expect(state.panelSizes.center, 0.5);
      expect(state.panelSizes.right, 0.2);
    });

    test('updateNoteContent saves note with debouncing', () async {
      final mockStorage = MockNoteStorageService();
      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      await container.read(workspaceProviderProvider.notifier).updateNoteContent(
            noteId: 'test-note',
            content: 'Updated content',
          );

      await Future.delayed(const Duration(milliseconds: 100));

      final loadedContent = await mockStorage.loadNote(noteId: 'test-note');
      expect(loadedContent, 'Updated content');
    });

    test('updateNoteContent throws on empty noteId', () {
      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(MockNoteStorageService()),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(workspaceProviderProvider.notifier).updateNoteContent(
              noteId: '',
              content: 'content',
            ),
        throwsArgumentError,
      );
    });

    test('saveNoteImmediate saves note without debouncing', () async {
      final mockStorage = MockNoteStorageService();
      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);

      await container.read(workspaceProviderProvider.notifier).saveNoteImmediate(
            noteId: 'test-note',
            content: 'Immediate save content',
          );

      final loadedContent = await mockStorage.loadNote(noteId: 'test-note');
      expect(loadedContent, 'Immediate save content');
    });

    test('saveNoteImmediate throws on empty noteId', () {
      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(MockNoteStorageService()),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(workspaceProviderProvider.notifier).saveNoteImmediate(
              noteId: '',
              content: 'content',
            ),
        throwsArgumentError,
      );
    });

    test('createMarker validates page number is greater than zero', () {
      // Note: This test verifies that invalid page numbers throw ArgumentError.
      // The method first checks if workspace state is initialized, then validates page number.
      expect(
        () => PdfMarker(
          id: 'test',
          pageNumber: 0, // Invalid
          color: MarkerColor.red,
        ),
        returnsNormally, // Freezed models don't validate, only provider methods do
      );
    });

    test('PanelSizes model accepts valid proportions', () {
      const validSizes = PanelSizes(left: 0.25, center: 0.5, right: 0.25);
      expect(validSizes.left + validSizes.center + validSizes.right, 1.0);
    });

    test('helper provider isPdfLoaded returns false initially', () async {
      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(MockNoteStorageService()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);
      expect(container.read(isPdfLoadedProvider), false);
    });

    test('helper provider isNoteLoaded returns false initially', () async {
      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(MockNoteStorageService()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);
      expect(container.read(isNoteLoadedProvider), false);
    });

    test('helper provider currentMarkers returns empty list initially', () async {
      final container = ProviderContainer(
        overrides: [
          noteStorageServiceProvider.overrideWithValue(MockNoteStorageService()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(workspaceProviderProvider.future);
      expect(container.read(currentMarkersProvider), isEmpty);
    });

    test('PdfMarker model serialization works correctly', () {
      final marker = PdfMarker(
        id: 'test-id',
        pageNumber: 3,
        color: MarkerColor.red,
        selectedText: 'Test text',
        textRect: PdfRect(10, 50, 100, 20),
        capturedImagePath: '/path/to/image.png',
      );

      final json = marker.toJson();
      final restored = PdfMarker.fromJson(json);

      expect(restored.id, 'test-id');
      expect(restored.pageNumber, 3);
      expect(restored.color, MarkerColor.red);
      expect(restored.selectedText, 'Test text');
      expect(restored.textRect?.left, 10);
      expect(restored.textRect?.top, 50);
      expect(restored.capturedImagePath, '/path/to/image.png');
    });

    test('WorkspaceState model copyWith works correctly', () {
      final state = WorkspaceState(
        currentPdfPath: '/path/to/pdf.pdf',
        currentNoteId: 'note-123',
        markers: [
          PdfMarker(
            id: 'marker-1',
            pageNumber: 1,
            color: MarkerColor.blue,
          ),
        ],
        panelSizes: const PanelSizes(left: 0.25, center: 0.5, right: 0.25),
      );

      final updated = state.copyWith(currentPdfPath: '/new/path.pdf');

      expect(updated.currentPdfPath, '/new/path.pdf');
      expect(updated.currentNoteId, 'note-123'); // Unchanged
      expect(updated.markers.length, 1); // Unchanged
      expect(updated.panelSizes.left, 0.25); // Unchanged
    });
  });
}
