import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/scrapnote_canvas_model.dart';

/// JSON serialization for scrapnote canvas data.
/// Saves/loads per-document canvas data to .gma files.
class ScrapnoteSerializer {
  /// Save canvas data to a file.
  static Future<void> save({
    required String filePath,
    required ScrapnoteCanvasData data,
  }) async {
    final json = jsonEncode(data.toJson());
    await File(filePath).writeAsString(json);
  }

  /// Load canvas data from a file.
  /// Returns null if the file does not exist or JSON is invalid.
  static Future<ScrapnoteCanvasData?> load({required String filePath}) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return ScrapnoteCanvasData.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Build the .gma file path for a given PDF path inside the scrapnotes directory.
  /// Sanitizes the PDF path to produce a safe filename.
  static String buildFilePath(String scrapnotesDir, String pdfPath) {
    final safeName = pdfPath
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return path.join(scrapnotesDir, '$safeName.gma');
  }
}
