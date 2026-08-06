import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../models/drawing_model.dart';

/// JSON serialization for drawing data.
/// Saves/loads per-document drawing strokes to captures directory.
class DrawingSerializer {
  /// Save drawing data for a document.
  static Future<void> save({
    required String filePath,
    required Map<int, List<DrawingStroke>> pageStrokes,
  }) async {
    final allStrokes = <Map<String, dynamic>>[];
    for (final entry in pageStrokes.entries) {
      for (final stroke in entry.value) {
        allStrokes.add({
          ...stroke.toJson(),
          'points': stroke.points.map((p) => p.toJson()).toList(),
        });
      }
    }

    final json = jsonEncode({'strokes': allStrokes});
    await File(filePath).writeAsString(json);
  }

  /// Load drawing data for a document. Returns empty map if file doesn't exist.
  static Future<Map<int, List<DrawingStroke>>> load({
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return {};
    }

    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final strokesList = (json['strokes'] as List<dynamic>?) ?? [];
      final pageStrokes = <int, List<DrawingStroke>>{};

      for (final raw in strokesList) {
        final strokeMap = raw as Map<String, dynamic>;
        final stroke = DrawingStroke.fromJson(strokeMap);
        pageStrokes.putIfAbsent(stroke.pageNumber, () => []).add(stroke);
      }

      return pageStrokes;
    } catch (e) {
      debugPrint('Failed to load drawing data: $e');
      return {};
    }
  }

  /// Build file path for a document's drawing data.
  /// Uses a sanitized version of the document path as the file key.
  static String buildFilePath(String capturesDir, String documentPath) {
    // Sanitize document path to create a safe filename
    final safeName = documentPath
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return path.join(capturesDir, '${safeName}_drawings.json');
  }
}
