import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/marker_colors.dart';
import '../../../workspace/models/pdf_marker_model.dart';

part 'pdf_marker_provider.g.dart';

const String _markersBoxName = 'pdf_markers';

/// Provider for managing PDF markers with Hive storage.
/// Uses marker ID as Hive key for safe CRUD (no index-based access).
@riverpod
class PdfMarkerState extends _$PdfMarkerState {
  Box<Map<dynamic, dynamic>>? _box;

  @override
  FutureOr<List<PdfMarker>> build() async {
    _box = await Hive.openBox<Map<dynamic, dynamic>>(_markersBoxName);
    return _loadAllMarkers();
  }

  /// Load all markers from Hive storage.
  List<PdfMarker> _loadAllMarkers() {
    if (_box == null) return [];

    final markers = <PdfMarker>[];
    for (final key in _box!.keys) {
      final value = _box!.get(key);
      if (value != null) {
        try {
          final json = Map<String, dynamic>.from(value);
          markers.add(PdfMarker.fromJson(json));
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
    }
    return markers;
  }

  /// Create a new marker and persist to storage.
  Future<PdfMarker> createMarker({
    required int pageNumber,
    required MarkerColor color,
    String? selectedText,
    PdfRect? textRect,
    String? capturedImagePath,
  }) async {
    if (_box == null) {
      throw Exception('Marker storage not initialized');
    }

    final marker = PdfMarker(
      id: const Uuid().v4(),
      pageNumber: pageNumber,
      color: color,
      selectedText: selectedText,
      textRect: textRect,
      capturedImagePath: capturedImagePath,
    );

    await _box!.put(marker.id, marker.toJson());

    // Update state with new marker
    final currentMarkers = state.valueOrNull ?? [];
    state = AsyncData([...currentMarkers, marker]);

    return marker;
  }

  /// Get a specific marker by ID.
  PdfMarker? getMarkerById(String id) {
    final markers = state.valueOrNull ?? [];
    try {
      return markers.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all markers for a specific page.
  List<PdfMarker> getMarkersByPage(int pageNumber) {
    final markers = state.valueOrNull ?? [];
    return markers.where((m) => m.pageNumber == pageNumber).toList();
  }

  /// Update an existing marker.
  Future<void> updateMarker(PdfMarker updatedMarker) async {
    if (_box == null) {
      throw Exception('Marker storage not initialized');
    }

    final currentMarkers = state.valueOrNull ?? [];
    final index = currentMarkers.indexWhere((m) => m.id == updatedMarker.id);

    if (index == -1) {
      throw Exception('Marker not found: ${updatedMarker.id}');
    }

    // Update in Hive by marker ID key
    await _box!.put(updatedMarker.id, updatedMarker.toJson());

    // Update state
    final newMarkers = [...currentMarkers];
    newMarkers[index] = updatedMarker;
    state = AsyncData(newMarkers);
  }

  /// Delete a marker by ID.
  Future<void> deleteMarker(String id) async {
    if (_box == null) {
      throw Exception('Marker storage not initialized');
    }

    // Delete from Hive by key
    await _box!.delete(id);

    // Update state
    final currentMarkers = state.valueOrNull ?? [];
    state = AsyncData(currentMarkers.where((m) => m.id != id).toList());
  }

  /// Delete all markers for a specific page.
  Future<void> deleteMarkersByPage(int pageNumber) async {
    final markersToDelete = getMarkersByPage(pageNumber);

    for (final marker in markersToDelete) {
      await deleteMarker(marker.id);
    }
  }

  /// Clear all markers from storage.
  Future<void> clearAllMarkers() async {
    if (_box == null) {
      throw Exception('Marker storage not initialized');
    }

    await _box!.clear();
    state = const AsyncData([]);
  }
}

/// Provider to get markers for a specific page number.
@riverpod
List<PdfMarker> markersForPage(Ref ref, int pageNumber) {
  final markerState = ref.watch(pdfMarkerStateProvider);
  return markerState.when(
    data: (markers) => markers.where((m) => m.pageNumber == pageNumber).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Provider to check if any markers exist.
@riverpod
bool hasMarkers(Ref ref) {
  final markerState = ref.watch(pdfMarkerStateProvider);
  return markerState.valueOrNull?.isNotEmpty ?? false;
}

/// Provider to get total marker count.
@riverpod
int markerCount(Ref ref) {
  final markerState = ref.watch(pdfMarkerStateProvider);
  return markerState.valueOrNull?.length ?? 0;
}
