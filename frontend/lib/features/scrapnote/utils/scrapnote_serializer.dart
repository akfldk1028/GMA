import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/scrapnote_canvas_model.dart';

/// JSON serializer for [ScrapnoteCanvasData] saved to `.gma` files.
///
/// The file format wraps the model JSON with a top-level [version] field:
/// ```json
/// { "version": 1, "id": "...", ... }
/// ```
///
/// Uses an atomic write strategy (write to temp file, then rename) to
/// prevent corrupt files on crash or power loss.
// @MX:ANCHOR: [AUTO] Single point of serialization for scrapnote canvas data. Called by providers on save/load.
// @MX:REASON: High fan_in — all canvas persistence flows through save/load methods here.
class ScrapnoteSerializer {
  static const int _currentVersion = 1;

  /// Save [data] to the `.gma` JSON file at [filePath].
  ///
  /// Uses atomic write: writes to a `.tmp` file first, then renames it
  /// to the final path, ensuring the target file is never half-written.
  static Future<void> save({
    required String filePath,
    required ScrapnoteCanvasData data,
  }) async {
    final json = data.toJson();
    // Embed the schema version at the top level
    json['version'] = _currentVersion;

    final encoded = jsonEncode(json);

    // Atomic write: write to temp file, then rename
    final tempPath = '$filePath.tmp';
    final tempFile = File(tempPath);
    await tempFile.writeAsString(encoded, flush: true);
    await tempFile.rename(filePath);
  }

  /// Load [ScrapnoteCanvasData] from the `.gma` JSON file at [filePath].
  ///
  /// Returns `null` if the file does not exist.
  /// Throws on malformed JSON or invalid data.
  static Future<ScrapnoteCanvasData?> load({
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    // Remove the wrapper 'version' key before passing to fromJson
    final dataJson = Map<String, dynamic>.from(json)..remove('version');

    return ScrapnoteCanvasData.fromJson(dataJson);
  }

  /// Build a canonical file path for a scrapnote canvas file.
  ///
  /// [canvasDir] is the directory where `.gma` files are stored.
  /// [canvasId] is the unique ID of the canvas.
  static String buildFilePath(String canvasDir, String canvasId) =>
      p.join(canvasDir, '$canvasId.gma');
}
