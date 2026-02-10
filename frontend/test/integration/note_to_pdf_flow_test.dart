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
    testDir = await Directory.systemTemp.createTemp('note_to_pdf_test_');
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

  group('Note→PDF Integration Flow', () {
    test('Marker click retrieves correct marker for PDF navigation', () async {
      // Arrange: Set up provider container and create a marker
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Create a marker (simulating previous PDF text selection)
      final createdMarker = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 5,
            color: MarkerColor.yellow,
            selectedText: 'Important text on page 5',
            textRect: PdfRect(50.0, 100.0, 200.0, 150.0),
          );

      // Act: Simulate marker click by calling navigateToMarker
      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(createdMarker.id);

      // Assert: Verify marker was retrieved with correct navigation data
      expect(marker, isNotNull);
      expect(marker!.id, createdMarker.id);
      expect(marker.pageNumber, 5);
      expect(marker.color, MarkerColor.yellow);
      expect(marker.selectedText, 'Important text on page 5');
      expect(marker.textRect, isNotNull);
      expect(marker.textRect!.left, 50.0);
      expect(marker.textRect!.top, 100.0);
      expect(marker.textRect!.right, 200.0);
      expect(marker.textRect!.bottom, 150.0);
    });

    test('Marker click with page-only navigation (no textRect)', () async {
      // Arrange: Set up provider container
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Create marker without textRect (page-only navigation)
      final createdMarker = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 12,
            color: MarkerColor.blue,
            selectedText: 'Text on page 12',
          );

      // Act: Simulate marker click
      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(createdMarker.id);

      // Assert: Verify marker has page number but no textRect
      expect(marker, isNotNull);
      expect(marker!.pageNumber, 12);
      expect(marker.textRect, isNull);
      expect(marker.selectedText, 'Text on page 12');
    });

    test('Marker click with invalid marker ID returns null', () async {
      // Arrange: Set up provider container
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Act: Try to navigate to non-existent marker
      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker('invalid-marker-id-123');

      // Assert: Verify null is returned for invalid marker ID
      expect(marker, isNull);
    });

    test('Marker click retrieves correct marker from multiple markers', () async {
      // Arrange: Set up provider container and create multiple markers
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Create multiple markers
      final marker1 = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 1,
            color: MarkerColor.red,
            selectedText: 'First marker',
            textRect: PdfRect(0, 0, 100, 100),
          );

      final marker2 = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 5,
            color: MarkerColor.green,
            selectedText: 'Second marker',
            textRect: PdfRect(50, 50, 150, 150),
          );

      final marker3 = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 10,
            color: MarkerColor.purple,
            selectedText: 'Third marker',
            textRect: PdfRect(100, 100, 200, 200),
          );

      // Act: Navigate to the second marker
      final retrievedMarker = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(marker2.id);

      // Assert: Verify correct marker was retrieved
      expect(retrievedMarker, isNotNull);
      expect(retrievedMarker!.id, marker2.id);
      expect(retrievedMarker.pageNumber, 5);
      expect(retrievedMarker.color, MarkerColor.green);
      expect(retrievedMarker.selectedText, 'Second marker');

      // Verify it's not one of the other markers
      expect(retrievedMarker.id, isNot(marker1.id));
      expect(retrievedMarker.id, isNot(marker3.id));
    });

    test('Marker click with captured image path for area capture', () async {
      // Arrange: Set up provider container
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Create marker with captured image (area capture scenario)
      final createdMarker = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 8,
            color: MarkerColor.red,
            selectedText: 'Captured area',
            textRect: PdfRect(25.0, 75.0, 300.0, 400.0),
            capturedImagePath: './captures/p8_capture.png',
          );

      // Act: Simulate marker click
      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(createdMarker.id);

      // Assert: Verify marker includes image path for rendering
      expect(marker, isNotNull);
      expect(marker!.pageNumber, 8);
      expect(marker.capturedImagePath, './captures/p8_capture.png');
      expect(marker.textRect, isNotNull);
    });

    test('Marker navigation validates page number is positive', () async {
      // Arrange: Set up provider container
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      // Create a valid marker first
      final marker = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 3,
            color: MarkerColor.yellow,
            selectedText: 'Valid marker',
          );

      // Verify marker was created
      final state = await container.read(workspaceProviderProvider.future);
      expect(state.markers.length, 1);

      // Act & Assert: Verify navigateToMarker validates page number
      final retrievedMarker = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(marker.id);

      expect(retrievedMarker, isNotNull);
      expect(retrievedMarker!.pageNumber, greaterThan(0));
    });

    test('Multiple marker clicks navigate to different pages correctly', () async {
      // Arrange: Set up provider container with markers on different pages
      final container = await setupWorkspaceContainer();
      addTearDown(container.dispose);

      final markerPage3 = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 3,
            color: MarkerColor.red,
            selectedText: 'Page 3 content',
          );

      final markerPage7 = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 7,
            color: MarkerColor.blue,
            selectedText: 'Page 7 content',
          );

      final markerPage15 = await container
          .read(workspaceProviderProvider.notifier)
          .createMarker(
            pageNumber: 15,
            color: MarkerColor.green,
            selectedText: 'Page 15 content',
          );

      // Act: Simulate clicking markers in different order
      final marker1 = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(markerPage7.id);

      final marker2 = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(markerPage3.id);

      final marker3 = await container
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(markerPage15.id);

      // Assert: Verify each navigation returns correct page
      expect(marker1!.pageNumber, 7);
      expect(marker2!.pageNumber, 3);
      expect(marker3!.pageNumber, 15);
    });
  });
}
