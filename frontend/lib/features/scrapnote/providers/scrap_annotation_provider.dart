import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../pdf_viewer/drawing/models/drawing_model.dart';

part 'scrap_annotation_provider.g.dart';

/// Persistent store for drawing annotations on scrap entries.
/// Maps elementId → List<DrawingStroke>.
/// Uses Hive JSON-in-Box pattern (same as ElementStore).
@Riverpod(keepAlive: true)
class ScrapAnnotationStore extends _$ScrapAnnotationStore {
  static const String _boxName = 'scrap_annotations';

  /// In-memory redo stacks per element (not persisted).
  final Map<String, List<DrawingStroke>> _redoStacks = {};

  Box<String> get _box {
    try {
      return Hive.box<String>(_boxName);
    } catch (e) {
      debugPrint('[ScrapAnnotationStore._box] BAD STATE: $e');
      rethrow;
    }
  }

  @override
  int build() => 0;

  void _bump() => state = state + 1;

  /// Add a stroke to the given element's annotation layer.
  /// Clears redo stack for that element.
  void addStroke(String elementId, DrawingStroke stroke) {
    try {
      final strokes = getStrokes(elementId);
      strokes.add(stroke);
      _save(elementId, strokes);
      _redoStacks.remove(elementId);
      _bump();
    } catch (e) {
      debugPrint('[ScrapAnnotationStore.addStroke] error: $e');
    }
  }

  /// Undo last stroke for element. Returns true if undo was performed.
  bool undoStroke(String elementId) {
    try {
      final strokes = getStrokes(elementId);
      if (strokes.isEmpty) return false;
      final removed = strokes.removeLast();
      _redoStacks.putIfAbsent(elementId, () => []).add(removed);
      _save(elementId, strokes);
      _bump();
      return true;
    } catch (e) {
      debugPrint('[ScrapAnnotationStore.undoStroke] error: $e');
      return false;
    }
  }

  /// Redo last undone stroke for element. Returns true if redo was performed.
  bool redoStroke(String elementId) {
    try {
      final redoStack = _redoStacks[elementId];
      if (redoStack == null || redoStack.isEmpty) return false;
      final stroke = redoStack.removeLast();
      final strokes = getStrokes(elementId);
      strokes.add(stroke);
      _save(elementId, strokes);
      _bump();
      return true;
    } catch (e) {
      debugPrint('[ScrapAnnotationStore.redoStroke] error: $e');
      return false;
    }
  }

  /// Whether undo is available for element.
  bool canUndo(String elementId) => getStrokes(elementId).isNotEmpty;

  /// Whether redo is available for element.
  bool canRedo(String elementId) {
    final stack = _redoStacks[elementId];
    return stack != null && stack.isNotEmpty;
  }

  /// Get all strokes for a given element.
  List<DrawingStroke> getStrokes(String elementId) {
    try {
      final raw = _box.get(elementId);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => DrawingStroke.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ScrapAnnotationStore.getStrokes] error for $elementId: $e');
      return [];
    }
  }

  /// Clear all strokes for a given element.
  void clearStrokes(String elementId) {
    try {
      _box.delete(elementId);
      _redoStacks.remove(elementId);
      _bump();
    } catch (e) {
      debugPrint('[ScrapAnnotationStore.clearStrokes] error: $e');
    }
  }

  void _save(String elementId, List<DrawingStroke> strokes) {
    final json = jsonEncode(strokes.map((s) => s.toJson()).toList());
    _box.put(elementId, json);
  }
}
