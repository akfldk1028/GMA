import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../utils/file_system_provider.dart';
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

/// Per-note drawing strokes with undo/redo and persistence.
@riverpod
class DrawingStrokes extends _$DrawingStrokes {
  Timer? _saveTimer;

  @override
  Future<DrawingData> build(String noteId) async {
    // Clean up timer on dispose
    ref.onDispose(() {
      _saveTimer?.cancel();
      _saveTimer = null;
    });

    final capturesDir = await ref.watch(capturesDirectoryProvider.future);
    final filePath =
        DrawingSerializer.buildFilePath(capturesDir.path, noteId);
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
      undoStack: [], // Clear redo on new stroke
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

    // Find last undo entry for this page
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
    // Cancel any pending save operation
    _saveTimer?.cancel();

    // Schedule new save operation after 500ms debounce delay
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      final current = state.valueOrNull;
      if (current == null) return;

      final capturesDir = await ref.read(capturesDirectoryProvider.future);
      final filePath =
          DrawingSerializer.buildFilePath(capturesDir.path, noteId);
      await DrawingSerializer.save(
        filePath: filePath,
        pageStrokes: current.pageStrokes,
      );
    });
  }
}
