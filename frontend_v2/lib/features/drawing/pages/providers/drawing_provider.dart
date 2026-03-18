import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../utils/file_system_provider.dart';
import '../../models/drawing_model.dart';
import '../../utils/drawing_serializer.dart';

part 'drawing_provider.g.dart';

/// Global drawing mode state (tool, color, size, active toggle).
@Riverpod(keepAlive: true)
class DrawingMode extends _$DrawingMode {
  @override
  DrawingToolState build() => const DrawingToolState();

  void selectTool(String toolId) {
    state = state.copyWith(currentToolId: toolId);
  }

  void setColor(int colorValue) {
    state = state.copyWith(colorValue: colorValue);
  }

  void setSize(double size) {
    state = state.copyWith(strokeSize: size);
  }

  void toggleActive() {
    state = state.copyWith(isActive: !state.isActive);
  }

  void setActive(bool active) {
    state = state.copyWith(isActive: active);
  }
}

/// Per-document drawing strokes with undo/redo and persistence.
/// Uses document path as the family key instead of noteId.
@riverpod
class DrawingStrokes extends _$DrawingStrokes {
  Timer? _saveTimer;

  // Maximum number of undo entries retained to bound memory usage.
  static const int _maxUndoSize = 50;

  @override
  Future<DrawingData> build(String documentPath) async {
    ref.onDispose(() {
      _saveTimer?.cancel();
      _saveTimer = null;
    });

    final capturesDir = await ref.watch(capturesDirectoryProvider.future);
    final filePath =
        DrawingSerializer.buildFilePath(capturesDir.path, documentPath);
    final pageStrokes = await DrawingSerializer.load(filePath: filePath);
    return DrawingData(pageStrokes: pageStrokes);
  }

  void addStroke(DrawingStroke stroke) {
    final current = state.valueOrNull;
    if (current == null) return;

    final page = stroke.pageNumber;
    // Shallow copy: share unchanged page lists, only create a new list for the
    // affected page. Avoids a full deep copy of the entire map on every stroke.
    final newPageStrokes = {...current.pageStrokes};
    newPageStrokes[page] = [...(current.pageStrokes[page] ?? []), stroke];

    state = AsyncData(DrawingData(
      pageStrokes: newPageStrokes,
      undoStack: [], // Clear redo stack on new stroke
    ));

    _autoSave();
  }

  /// Remove a specific stroke by ID from a page (used by eraser hit-test).
  void removeStroke(int pageNumber, String strokeId) {
    final current = state.valueOrNull;
    if (current == null) return;

    // Shallow copy: only rebuild the list for the affected page.
    final newPageStrokes = {...current.pageStrokes};
    final strokes = List<DrawingStroke>.from(newPageStrokes[pageNumber] ?? []);
    strokes.removeWhere((s) => s.id == strokeId);
    newPageStrokes[pageNumber] = strokes;

    state = AsyncData(DrawingData(
      pageStrokes: newPageStrokes,
      undoStack: current.undoStack,
    ));

    _autoSave();
  }

  void undo(int pageNumber) {
    final current = state.valueOrNull;
    if (current == null) return;

    // Shallow copy: only rebuild the list for the affected page.
    final newPageStrokes = {...current.pageStrokes};
    final strokes = List<DrawingStroke>.from(newPageStrokes[pageNumber] ?? []);
    if (strokes.isEmpty) return;

    final removed = strokes.removeLast();
    newPageStrokes[pageNumber] = strokes;

    // Cap undo stack at _maxUndoSize to prevent unbounded memory growth.
    List<DrawingStroke> newUndoStack = [...current.undoStack, removed];
    if (newUndoStack.length >= _maxUndoSize) {
      newUndoStack = newUndoStack.sublist(newUndoStack.length - _maxUndoSize);
    }

    state = AsyncData(DrawingData(
      pageStrokes: newPageStrokes,
      undoStack: newUndoStack,
    ));

    _autoSave();
  }

  void redo(int pageNumber) {
    final current = state.valueOrNull;
    if (current == null) return;

    final undoStack = List<DrawingStroke>.from(current.undoStack);
    if (undoStack.isEmpty) return;

    final idx = undoStack.lastIndexWhere((s) => s.pageNumber == pageNumber);
    if (idx == -1) return;

    final restored = undoStack.removeAt(idx);
    // Shallow copy: only rebuild the list for the affected page.
    final newPageStrokes = {...current.pageStrokes};
    newPageStrokes[pageNumber] = [
      ...(current.pageStrokes[pageNumber] ?? []),
      restored,
    ];

    state = AsyncData(DrawingData(
      pageStrokes: newPageStrokes,
      undoStack: undoStack,
    ));

    _autoSave();
  }

  void _autoSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      final current = state.valueOrNull;
      if (current == null) return;

      final capturesDir = await ref.read(capturesDirectoryProvider.future);
      final filePath =
          DrawingSerializer.buildFilePath(capturesDir.path, documentPath);
      await DrawingSerializer.save(
        filePath: filePath,
        pageStrokes: current.pageStrokes,
      );
    });
  }
}
