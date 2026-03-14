import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

import '../models/drawing_model.dart';

/// JSON serialization for drawing data.
/// Saves/loads per-note drawing strokes to captures directory.
class DrawingSerializer {
  /// Save drawing data for a note.
  static Future<void> save({
    required String filePath,
    required Map<int, List<DrawingStroke>> pageStrokes,
  }) async {
    // Flatten to a list for JSON
    final allStrokes = <Map<String, dynamic>>[];
    for (final entry in pageStrokes.entries) {
      for (final stroke in entry.value) {
        allStrokes.add(stroke.toJson());
      }
    }

    if (kIsWeb) return;
    final json = jsonEncode({'strokes': allStrokes});
    await File(filePath).writeAsString(json);
  }

  /// Load drawing data for a note. Returns empty map if file doesn't exist.
  static Future<Map<int, List<DrawingStroke>>> load({
    required String filePath,
  }) async {
    if (kIsWeb) return {};
    final file = File(filePath);
    if (!await file.exists()) {
      return {};
    }

    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final strokesList = (json['strokes'] as List<dynamic>?) ?? [];
      final pageStrokes = <int, List<DrawingStroke>>{};

      for (final raw in strokesList) {
        final stroke = DrawingStroke.fromJson(raw as Map<String, dynamic>);
        pageStrokes.putIfAbsent(stroke.pageNumber, () => []).add(stroke);
      }

      return pageStrokes;
    } catch (_) {
      return {};
    }
  }

  /// Build file path for a note's drawing data.
  static String buildFilePath(String capturesDir, String noteId) =>
      path.join(capturesDir, '${noteId}_drawings.json');
}
