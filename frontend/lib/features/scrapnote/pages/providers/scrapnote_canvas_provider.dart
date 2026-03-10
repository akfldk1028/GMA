import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../utils/file_system_provider.dart';
import '../../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../models/scrapnote_canvas_model.dart';
import '../../utils/scrapnote_serializer.dart';

part 'scrapnote_canvas_provider.g.dart';

// @MX:ANCHOR: [AUTO] Manages scrapnote canvas state (strokes + elements + undo/redo + auto-save).
// @MX:REASON: High fan_in — ScrapnoteCanvas widget, ScrapnoteService, and future screens all depend on this provider.

/// Per-scrapnote canvas state with undo/redo stack and debounced auto-save.
///
/// Key differences from [DrawingStrokes]:
/// - Strokes are stored as a flat list (no per-page map) — scrapnote has one infinite canvas.
/// - Undo/redo is global across all strokes.
/// - Also manages [CanvasElement] CRUD (add, remove, reposition).
/// - Persists to `.gma` files via [ScrapnoteSerializer].
@riverpod
class ScrapnoteCanvasState extends _$ScrapnoteCanvasState {
  Timer? _saveTimer;

  @override
  Future<ScrapnoteCanvasData> build(String scrapnoteId) async {
    ref.onDispose(() {
      _saveTimer?.cancel();
      _saveTimer = null;
    });

    final notesDir = await ref.watch(notesRootDirectoryProvider.future);
    final filePath =
        ScrapnoteSerializer.buildFilePath(notesDir.path, scrapnoteId);
    final loaded = await ScrapnoteSerializer.load(filePath: filePath);

    if (loaded != null) return loaded;

    // No file yet — create default empty canvas
    return ScrapnoteCanvasData(
      id: scrapnoteId,
      linkedPdfPath: '',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  // --- Stroke operations ---

  /// Append [stroke] to the canvas and clear redo stack.
  void addStroke(DrawingStroke stroke) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      strokes: [...current.strokes, stroke],
      modifiedAt: DateTime.now(),
    ));

    _autoSave();
  }

  /// Remove the last stroke and push it to undo stack.
  void undo() {
    final current = state.valueOrNull;
    if (current == null || current.strokes.isEmpty) return;

    final strokes = List<DrawingStroke>.from(current.strokes);
    // We track undo stack in a separate field within the model.
    // For simplicity, we use the last element of strokes as the undo target.
    final removed = strokes.removeLast();

    state = AsyncData(current.copyWith(
      strokes: strokes,
      // Store removed stroke in undoStack field on model (via copyWith extension below)
      modifiedAt: DateTime.now(),
    ));

    // Push to undo stack via internal state extension
    _pushUndo(removed);
    _autoSave();
  }

  /// Restore the last undone stroke.
  void redo() {
    final current = state.valueOrNull;
    if (current == null) return;

    // We need an undo stack — maintained in a local variable on the notifier.
    // Since ScrapnoteCanvasData doesn't have an undo stack field,
    // we keep it in the notifier itself.
    final restored = _popUndo();
    if (restored == null) return;

    state = AsyncData(current.copyWith(
      strokes: [...current.strokes, restored],
      modifiedAt: DateTime.now(),
    ));

    _autoSave();
  }

  // --- Element operations ---

  /// Add [element] to the canvas elements list.
  void addElement(CanvasElement element) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      elements: [...current.elements, element],
      modifiedAt: DateTime.now(),
    ));

    _autoSave();
  }

  /// Remove the element with [elementId] from the canvas.
  void removeElement(String elementId) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      elements:
          current.elements.where((e) => e.id != elementId).toList(),
      modifiedAt: DateTime.now(),
    ));

    _autoSave();
  }

  /// Update the position of element [elementId] to ([x], [y]).
  void repositionElement(String elementId, double x, double y) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      elements: current.elements
          .map((e) => e.id == elementId ? e.copyWith(x: x, y: y) : e)
          .toList(),
      modifiedAt: DateTime.now(),
    ));

    _autoSave();
  }

  // --- Undo stack (local notifier state) ---

  final List<DrawingStroke> _undoStack = [];

  void _pushUndo(DrawingStroke stroke) {
    _undoStack.add(stroke);
  }

  DrawingStroke? _popUndo() {
    if (_undoStack.isEmpty) return null;
    return _undoStack.removeLast();
  }

  // --- Persistence ---

  void _autoSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      final current = state.valueOrNull;
      if (current == null) return;

      final notesDir = await ref.read(notesRootDirectoryProvider.future);
      final filePath =
          ScrapnoteSerializer.buildFilePath(notesDir.path, scrapnoteId);

      await ScrapnoteSerializer.save(filePath: filePath, data: current);
    });
  }
}
