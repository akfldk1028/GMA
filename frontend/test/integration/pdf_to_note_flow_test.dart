import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/workspace/pages/providers/workspace_provider.dart';
import 'package:gma_frontend/utils/note_storage_service.dart';

/// Mock NoteStorageService for testing
class MockNoteStorageService implements NoteStorageService {
  final Map<String, String> _notes = {};

  @override
  NoteStorageServiceRef get ref => throw UnimplementedError();

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

/// Helper function to set up a container and wait for workspace provider to be ready
Future<ProviderContainer> setupWorkspaceContainer() async {
  final container = ProviderContainer(
    overrides: [
      noteStorageServiceProvider.overrideWithValue(MockNoteStorageService()),
    ],
  );

  // Trigger the provider and wait for it to complete
  // This is done by listening to the provider until it emits AsyncData
  final completer = Completer<void>();

  final subscription = container.listen(
    workspaceProviderProvider,
    (previous, next) {
      if (next.hasValue && !completer.isCompleted) {
        completer.complete();
      } else if (next.hasError && !completer.isCompleted) {
        completer.completeError(next.error!, next.stackTrace ?? StackTrace.current);
      }
    },
    fireImmediately: true,
  );

  // Wait for the state to be loaded or timeout after 5 seconds
  await completer.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () {
      subscription.close();
      throw TimeoutException('Workspace provider did not initialize within 5 seconds');
    },
  );

  subscription.close();

  // Verify state is now available
  final state = container.read(workspaceProviderProvider);
  if (!state.hasValue) {
    throw Exception('Workspace provider state still not loaded after waiting');
  }

  return container;
}

void main() {
  late Directory testDir;

  setUpAll(() async {
    // Initialize Flutter binding for tests
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive for testing with system temp directory
    testDir = await Directory.systemTemp.createTemp('pdf_to_note_test_');
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

  group('PDF→Note Integration Flow', () {
    test('PDF text selection creates marker in workspace state', () async {
      // Arrange: Set up provider container
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Act: Simulate PDF text selection by creating a marker
      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 3,
            color: MarkerColor.red,
            selectedText: 'This is selected text from PDF',
            textRect: PdfRect(10.0, 50.0, 100.0, 20.0),
          );

      // Assert: Verify marker was created with correct properties
      expect(marker.id, isNotEmpty);
      expect(marker.pageNumber, 3);
      expect(marker.color, MarkerColor.red);
      expect(marker.selectedText, 'This is selected text from PDF');
      expect(marker.textRect?.left, 10.0);
      expect(marker.textRect?.top, 50.0);
      expect(marker.textRect?.right, 100.0);
      expect(marker.textRect?.bottom, 20.0);

      // Assert: Verify marker is in workspace state
      final state = await container.read(workspaceProviderProvider.future);
      expect(state.markers.length, 1);
      expect(state.markers.first.id, marker.id);
      expect(state.markers.first.pageNumber, 3);
      expect(state.markers.first.color, MarkerColor.red);
      expect(state.markers.first.selectedText, 'This is selected text from PDF');
    });

    test('PDF text selection creates multiple markers correctly', () async {
      // Arrange: Set up provider container
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Act: Create multiple markers simulating multiple text selections
      await container.read(workspaceProviderProvider.notifier).createMarker(
            pageNumber: 1,
            color: MarkerColor.yellow,
            selectedText: 'First selection',
            textRect: PdfRect(0, 25, 50, 0),
          );

      await container.read(workspaceProviderProvider.notifier).createMarker(
            pageNumber: 5,
            color: MarkerColor.blue,
            selectedText: 'Second selection',
            textRect: PdfRect(100, 400, 300, 200),
          );

      await container.read(workspaceProviderProvider.notifier).createMarker(
            pageNumber: 10,
            color: MarkerColor.green,
            selectedText: 'Third selection',
          );

      // Assert: Verify all markers are in state
      final state = await container.read(workspaceProviderProvider.future);
      expect(state.markers.length, 3);

      // Verify first marker
      expect(state.markers[0].pageNumber, 1);
      expect(state.markers[0].color, MarkerColor.yellow);
      expect(state.markers[0].selectedText, 'First selection');

      // Verify second marker
      expect(state.markers[1].pageNumber, 5);
      expect(state.markers[1].color, MarkerColor.blue);
      expect(state.markers[1].selectedText, 'Second selection');

      // Verify third marker
      expect(state.markers[2].pageNumber, 10);
      expect(state.markers[2].color, MarkerColor.green);
      expect(state.markers[2].selectedText, 'Third selection');

      // Verify each marker has a unique ID
      final ids = state.markers.map((m) => m.id).toSet();
      expect(ids.length, 3);
    });

    test('PDF text selection with minimal data (page and color only)', () async {
      // Arrange
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Act: Create marker with only required fields
      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 7,
            color: MarkerColor.purple,
          );

      // Assert: Verify marker was created with minimal data
      expect(marker.id, isNotEmpty);
      expect(marker.pageNumber, 7);
      expect(marker.color, MarkerColor.purple);
      expect(marker.selectedText, isNull);
      expect(marker.textRect, isNull);
      expect(marker.capturedImagePath, isNull);

      final state = await container.read(workspaceProviderProvider.future);
      expect(state.markers.length, 1);
      expect(state.markers.first.pageNumber, 7);
    });

    test('PDF text selection with image capture path', () async {
      // Arrange
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Act: Create marker with captured image path
      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 12,
            color: MarkerColor.red,
            selectedText: 'Captured region text',
            textRect: PdfRect(50, 200, 200, 50),
            capturedImagePath: './captures/p12_capture.png',
          );

      // Assert: Verify marker includes image path
      expect(marker.capturedImagePath, './captures/p12_capture.png');

      final state = await container.read(workspaceProviderProvider.future);
      expect(state.markers.first.capturedImagePath, './captures/p12_capture.png');
    });

    test('PDF text selection fails with invalid page number', () async {
      // Arrange
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Act & Assert: Verify that invalid page numbers throw ArgumentError
      expect(
        () => container.read(workspaceProviderProvider.notifier).createMarker(
              pageNumber: 0,
              color: MarkerColor.red,
            ),
        throwsArgumentError,
      );

      expect(
        () => container.read(workspaceProviderProvider.notifier).createMarker(
              pageNumber: -5,
              color: MarkerColor.blue,
            ),
        throwsArgumentError,
      );

      // Verify no markers were created
      final state = await container.read(workspaceProviderProvider.future);
      expect(state.markers.length, 0);
    });

    test('Marker retrieval via currentMarkersProvider after text selection', () async {
      // Arrange
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Act: Create markers
      await container.read(workspaceProviderProvider.notifier).createMarker(
            pageNumber: 2,
            color: MarkerColor.yellow,
            selectedText: 'Test marker 1',
          );

      await container.read(workspaceProviderProvider.notifier).createMarker(
            pageNumber: 4,
            color: MarkerColor.green,
            selectedText: 'Test marker 2',
          );

      // Assert: Verify markers are accessible via helper provider
      final markers = container.read(currentMarkersProvider);
      expect(markers.length, 2);
      expect(markers[0].selectedText, 'Test marker 1');
      expect(markers[1].selectedText, 'Test marker 2');
    });
  });
}
