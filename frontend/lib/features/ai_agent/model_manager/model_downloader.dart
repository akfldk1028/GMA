import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'model_registry.dart';

/// Model download state.
enum ModelStatus {
  notInstalled,
  downloading,
  installed,
  error,
}

/// Manages Gemma model download lifecycle.
///
/// Uses FlutterGemma modern API (builder pattern).
class ModelDownloader {
  ModelDownloader._();

  /// Check if the model is already installed.
  static Future<bool> isInstalled() async {
    try {
      return FlutterGemma.hasActiveModel();
    } catch (_) {
      return false;
    }
  }

  /// Download and install the E4B model with progress callback.
  ///
  /// [onProgress] receives percentage (0-100).
  static Future<void> downloadWithProgress(
    void Function(int progress) onProgress,
  ) async {
    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.litertlm,
    )
        .fromNetwork(gemmaE4B.downloadUrl)
        .withProgress(onProgress)
        .install();
  }

  /// Download and install the E4B model (no progress).
  static Future<void> download() async {
    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
      fileType: ModelFileType.litertlm,
    ).fromNetwork(gemmaE4B.downloadUrl).install();
  }

  /// Delete the installed model.
  static Future<void> delete() async {
    try {
      // TODO: FlutterGemma 0.13.2 doesn't expose a direct delete API
      // through the modern facade. May need to use the legacy API or
      // wait for a future version.
      debugPrint('[ModelDownloader] delete: not yet implemented in flutter_gemma modern API');
    } catch (e) {
      debugPrint('[ModelDownloader] delete failed: $e');
    }
  }
}
