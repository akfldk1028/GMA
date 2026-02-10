import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/marker_colors.dart';
import '../../../../utils/note_storage_service.dart';
import '../../../note_editor/pages/providers/note_editor_provider.dart';
import '../../models/pdf_marker_model.dart';
import '../../models/workspace_state.dart';

part 'workspace_provider.g.dart';

/// Main workspace provider managing PDF-Note bidirectional linking
@riverpod
class WorkspaceProvider extends _$WorkspaceProvider {
  @override
  FutureOr<WorkspaceState> build() async {
    // Load panel sizes from Hive if available
    final box = await Hive.openBox('workspace_settings');
    final savedSizes = box.get('panel_sizes');

    final panelSizes = savedSizes != null
        ? PanelSizes.fromJson(Map<String, dynamic>.from(savedSizes as Map))
        : const PanelSizes();

    return WorkspaceState(
      panelSizes: panelSizes,
    );
  }

  /// Load a PDF file into the workspace
  Future<void> loadPdf(String pdfPath) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Verify PDF file exists
    final file = File(pdfPath);
    if (!await file.exists()) {
      throw Exception('PDF file not found: $pdfPath');
    }

    state = AsyncData(
      currentState.copyWith(currentPdfPath: pdfPath),
    );
  }

  /// Load a note into the workspace
  /// Optionally loads the note content from filesystem if available
  Future<String?> loadNote(String noteId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    // Update workspace state with current note ID
    state = AsyncData(
      currentState.copyWith(currentNoteId: noteId),
    );

    // Load note content from filesystem using NoteStorageService
    final noteStorage = ref.read(noteStorageServiceProvider);
    final content = await noteStorage.loadNote(noteId: noteId);

    return content;
  }

  /// Update note content with auto-save (debounced)
  /// This should be called when the user types in the note editor
  Future<void> updateNoteContent({
    required String noteId,
    required String content,
  }) async {
    // Validate noteId
    if (noteId.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }

    // Trigger auto-save with debouncing via NoteStorageService
    final noteStorage = ref.read(noteStorageServiceProvider);
    await noteStorage.saveNote(
      noteId: noteId,
      content: content,
    );
  }

  /// Save note content immediately without debouncing
  /// Use this for explicit save operations (e.g., user clicks Save button)
  Future<void> saveNoteImmediate({
    required String noteId,
    required String content,
  }) async {
    // Validate noteId
    if (noteId.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }

    // Save immediately without debouncing
    final noteStorage = ref.read(noteStorageServiceProvider);
    await noteStorage.saveNoteImmediate(
      noteId: noteId,
      content: content,
    );
  }

  /// Create a marker from PDF text selection
  /// This is called when user selects text in PDF viewer
  Future<PdfMarker> createMarker({
    required int pageNumber,
    required MarkerColor color,
    String? selectedText,
    PdfRect? textRect,
    String? capturedImagePath,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      throw Exception('Workspace state not initialized');
    }

    // Validate page number is positive
    if (pageNumber <= 0) {
      throw ArgumentError('Invalid page number: $pageNumber');
    }

    // Create new marker with unique ID
    const uuid = Uuid();
    final marker = PdfMarker(
      id: uuid.v4(),
      pageNumber: pageNumber,
      color: color,
      selectedText: selectedText,
      textRect: textRect,
      capturedImagePath: capturedImagePath,
    );

    // Add marker to state
    final updatedMarkers = [...currentState.markers, marker];
    state = AsyncData(
      currentState.copyWith(markers: updatedMarkers),
    );

    // Insert marker into note editor if a note is currently loaded
    final currentNoteId = currentState.currentNoteId;
    if (currentNoteId != null && selectedText != null) {
      await ref
          .read(noteEditorProvider(currentNoteId).notifier)
          .insertMarker(
            color: color,
            pageNumber: pageNumber,
            text: selectedText,
          );
    }

    return marker;
  }

  /// Navigate PDF viewer to a specific marker
  /// Returns the marker if found, null if marker ID is invalid
  Future<PdfMarker?> navigateToMarker(String markerId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    // Find marker by ID
    try {
      final marker = currentState.markers.firstWhere(
        (m) => m.id == markerId,
      );

      // Validate page number is within reasonable bounds
      if (marker.pageNumber <= 0) {
        throw ArgumentError(
          'Invalid page number in marker: ${marker.pageNumber}',
        );
      }

      return marker;
    } catch (e) {
      // Marker not found or invalid
      return null;
    }
  }

  /// Save panel sizes to persistent storage
  Future<void> savePanelSizes(PanelSizes sizes) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Validate panel sizes sum to approximately 1.0 (allowing small float precision errors)
    final sum = sizes.left + sizes.center + sizes.right;
    if ((sum - 1.0).abs() > 0.01) {
      throw ArgumentError(
        'Panel sizes must sum to 1.0, got: $sum',
      );
    }

    // Validate all sizes are positive
    if (sizes.left <= 0 || sizes.center <= 0 || sizes.right <= 0) {
      throw ArgumentError('All panel sizes must be positive');
    }

    // Update state
    state = AsyncData(
      currentState.copyWith(panelSizes: sizes),
    );

    // Persist to Hive
    final box = await Hive.openBox('workspace_settings');
    await box.put('panel_sizes', sizes.toJson());
  }

  /// Remove a marker by ID
  Future<void> removeMarker(String markerId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedMarkers = currentState.markers
        .where((m) => m.id != markerId)
        .toList();

    state = AsyncData(
      currentState.copyWith(markers: updatedMarkers),
    );
  }

  /// Clear all markers
  Future<void> clearMarkers() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(markers: []),
    );
  }

  /// Reset workspace to initial state
  Future<void> reset() async {
    state = const AsyncData(WorkspaceState());
  }
}

/// Helper provider to check if a PDF is currently loaded
@riverpod
bool isPdfLoaded(IsPdfLoadedRef ref) {
  final workspaceState = ref.watch(workspaceProviderProvider);
  return workspaceState.valueOrNull?.currentPdfPath != null;
}

/// Helper provider to check if a note is currently loaded
@riverpod
bool isNoteLoaded(IsNoteLoadedRef ref) {
  final workspaceState = ref.watch(workspaceProviderProvider);
  return workspaceState.valueOrNull?.currentNoteId != null;
}

/// Helper provider to get current markers
@riverpod
List<PdfMarker> currentMarkers(CurrentMarkersRef ref) {
  final workspaceState = ref.watch(workspaceProviderProvider);
  return workspaceState.valueOrNull?.markers ?? [];
}
