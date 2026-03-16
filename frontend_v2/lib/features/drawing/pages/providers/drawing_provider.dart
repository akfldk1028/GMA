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
    final pageStrokes = Map<int, List<DrawingStroke>>.from(current.pageStrokes);
    pageStrokes[page] = [...(pageStrokes[page] ?? []), stroke];

    state = AsyncData(DrawingData(
      pageStrokes: pageStrokes,
      undoStack: [], // Clear redo stack on new stroke
    ));

    _autoSave();
  }

  /// Remove a specific stroke by ID from a page (used by eraser hit-test).
  void removeStroke(int pageNumber, String strokeId) {
    final current = state.valueOrNull;
    if (current == null) return;

    final pageStrokes = Map<int, List<DrawingStroke>>.from(current.pageStrokes);
    final strokes = List<DrawingStroke>.from(pageStrokes[pageNumber] ?? []);
    strokes.removeWhere((s) => s.id == strokeId);
    pageStrokes[pageNumber] = strokes;

    state = AsyncData(DrawingData(
      pageStrokes: pageStrokes,
      undoStack: current.undoStack,
    ));

    _autoSave();
  }

  void undo(int pageNumber) {
    final current = state.valueOrNull;
    if (current == null) return;

    final pageStrokes = Map<int, List<DrawingStroke>>.from(current.pageStrokes);
    final strokes = List<DrawingStroke>.from(pageStrokes[pageNumber] ?? []);
    if (strokes.isEmpty) return;

    final removed = strokes.removeLast();
    pageStrokes[pageNumber] = strokes;

    state = AsyncData(DrawingData(
      pageStrokes: pageStrokes,
      undoStack: [...current.undoStack, removed],
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
    final pageStrokes = Map<int, List<DrawingStroke>>.from(current.pageStrokes);
    pageStrokes[pageNumber] = [...(pageStrokes[pageNumber] ?? []), restored];

    state = AsyncData(DrawingData(
      pageStrokes: pageStrokes,
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
