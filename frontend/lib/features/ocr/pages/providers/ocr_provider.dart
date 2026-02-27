import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backends/ollama_backend.dart';
import '../../ocr_registry.dart';
import '../../ocr_service.dart';

part 'ocr_provider.g.dart';

/// Hive box name for OCR settings.
const _kOcrBoxName = 'ocr_settings';

/// Persisted OCR settings (Hive).
@Riverpod(keepAlive: true)
class OcrSettings extends _$OcrSettings {
  @override
  Future<OcrSettingsData> build() async {
    final box = await Hive.openBox(_kOcrBoxName);
    return OcrSettingsData(
      isEnabled: box.get('isEnabled', defaultValue: false) as bool,
      backendId: box.get('backendId', defaultValue: 'ollama') as String,
      ollamaUrl: box.get('ollamaUrl', defaultValue: kDefaultOllamaUrl) as String,
      modelName: box.get('modelName', defaultValue: kDefaultOllamaModel) as String,
    );
  }

  Future<void> setEnabled(bool value) async {
    final box = await Hive.openBox(_kOcrBoxName);
    await box.put('isEnabled', value);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(isEnabled: value));
    }
  }

  Future<void> setOllamaUrl(String url) async {
    final box = await Hive.openBox(_kOcrBoxName);
    await box.put('ollamaUrl', url);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(ollamaUrl: url));
    }
  }

  Future<void> setModelName(String name) async {
    final box = await Hive.openBox(_kOcrBoxName);
    await box.put('modelName', name);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(modelName: name));
    }
  }

  /// Test connection to the current backend.
  Future<bool> testConnection() async {
    final settings = state.valueOrNull;
    if (settings == null) return false;
    final backend = lookupOcrBackend(settings.backendId);
    if (backend == null) return false;
    return backend.isAvailable(baseUrl: settings.ollamaUrl);
  }
}

/// Simple data class for OCR settings (no Freezed needed — manual copyWith).
class OcrSettingsData {
  const OcrSettingsData({
    this.isEnabled = false,
    this.backendId = 'ollama',
    this.ollamaUrl = kDefaultOllamaUrl,
    this.modelName = kDefaultOllamaModel,
  });

  final bool isEnabled;
  final String backendId;
  final String ollamaUrl;
  final String modelName;

  OcrSettingsData copyWith({
    bool? isEnabled,
    String? backendId,
    String? ollamaUrl,
    String? modelName,
  }) {
    return OcrSettingsData(
      isEnabled: isEnabled ?? this.isEnabled,
      backendId: backendId ?? this.backendId,
      ollamaUrl: ollamaUrl ?? this.ollamaUrl,
      modelName: modelName ?? this.modelName,
    );
  }
}

/// One-shot OCR recognition on an image file.
@riverpod
Future<String> ocrRecognize(
  Ref ref, {
  required String imagePath,
}) async {
  final settings = await ref.read(ocrSettingsProvider.future);
  return OcrService.recognizeFile(
    imagePath,
    backendId: settings.backendId,
    baseUrl: settings.ollamaUrl,
    model: settings.modelName,
  );
}
