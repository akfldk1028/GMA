import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../utils/file_system_provider.dart';
import '../../models/scrapnote_canvas_model.dart';
import '../../services/scrapnote_service.dart';
import '../../utils/scrapnote_serializer.dart';
import '../../../drawing/models/drawing_model.dart';

part 'scrapnote_canvas_provider.g.dart';

// @MX:ANCHOR: Central canvas state provider for scrapnote — family keyed by pdfPath
// @MX:REASON: fan_in >= 3 callers: ScrapnoteCanvas widget, ScrapOrchestrator, ScrapnoteScreen
/// Per-PDF scrapnote canvas state with undo/redo and auto-save.
/// Keyed by the PDF file path (same key as DrawingStrokes provider).
@riverpod
class ScrapnoteCanvas extends _$ScrapnoteCanvas {
  Timer? _saveTimer;

  // Undo stacks for strokes and elements (separate for clarity)
  final List<DrawingStroke> _strokeUndoStack = [];
  final List<CanvasElement> _elementUndoStack = [];

  @override
  Future<ScrapnoteCanvasData> build(String pdfPath) async {
    ref.onDispose(() {
      _saveTimer?.cancel();
      _saveTimer = null;
    });

    final scrapnotesDir =
        await ref.watch(scrapnotesDirectoryProvider.future);
    return ScrapnoteService.getOrCreate(
      scrapnotesDir: scrapnotesDir.path,
      pdfPath: pdfPath,
    );
  }

  /// Add a freehand stroke to the canvas.
  void addStroke(DrawingStroke stroke) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        strokes: [...current.strokes, stroke],
        modifiedAt: DateTime.now(),
      ),
    );
    _strokeUndoStack.clear();
    _autoSave();
  }

  /// Remove a stroke by its ID.
  void removeStroke(String strokeId) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        strokes: current.strokes.where((s) => s.id != strokeId).toList(),
        modifiedAt: DateTime.now(),
      ),
    );
    _autoSave();
  }

  /// Add a canvas element (placed scrap).
  void addElement(CanvasElement element) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        elements: [...current.elements, element],
        layerOrder: [...current.layerOrder, element.id],
        modifiedAt: DateTime.now(),
      ),
    );
    _elementUndoStack.clear();
    _autoSave();
  }

  /// Remove a canvas element by its ID.
  void removeElement(String elementId) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        elements: current.elements.where((e) => e.id != elementId).toList(),
        layerOrder:
            current.layerOrder.where((id) => id != elementId).toList(),
        modifiedAt: DateTime.now(),
      ),
    );
    _autoSave();
  }

  /// Undo the last stroke or element addition.
  void undo() {
    final current = state.valueOrNull;
    if (current == null) return;

    // Undo the most recently added stroke first, then elements
    if (current.strokes.isNotEmpty) {
      final strokes = [...current.strokes];
      final removed = strokes.removeLast();
      _strokeUndoStack.add(removed);
      state = AsyncData(
        current.copyWith(strokes: strokes, modifiedAt: DateTime.now()),
      );
      _autoSave();
    } else if (current.elements.isNotEmpty) {
      final elements = [...current.elements];
      final removed = elements.removeLast();
      _elementUndoStack.add(removed);
      final layerOrder =
          current.layerOrder.where((id) => id != removed.id).toList();
      state = AsyncData(
        current.copyWith(
          elements: elements,
          layerOrder: layerOrder,
          modifiedAt: DateTime.now(),
        ),
      );
      _autoSave();
    }
  }

  /// Redo the last undone stroke or element.
  void redo() {
    final current = state.valueOrNull;
    if (current == null) return;

    if (_strokeUndoStack.isNotEmpty) {
      final restored = _strokeUndoStack.removeLast();
      state = AsyncData(
        current.copyWith(
          strokes: [...current.strokes, restored],
          modifiedAt: DateTime.now(),
        ),
      );
      _autoSave();
    } else if (_elementUndoStack.isNotEmpty) {
      final restored = _elementUndoStack.removeLast();
      state = AsyncData(
        current.copyWith(
          elements: [...current.elements, restored],
          layerOrder: [...current.layerOrder, restored.id],
          modifiedAt: DateTime.now(),
        ),
      );
      _autoSave();
    }
  }

  void _autoSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      final current = state.valueOrNull;
      if (current == null) return;

      final scrapnotesDir =
          await ref.read(scrapnotesDirectoryProvider.future);
      final filePath = ScrapnoteSerializer.buildFilePath(
        scrapnotesDir.path,
        pdfPath,
      );
      await ScrapnoteSerializer.save(filePath: filePath, data: current);
    });
  }
}
