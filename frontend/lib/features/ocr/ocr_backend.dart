import 'dart:typed_data';

/// Abstract interface for OCR backends (plugin pattern).
///
/// New backend = 1 file implementing this interface + 1 line in registry.
abstract class OcrBackend {
  /// Unique identifier, e.g. 'ollama', 'tesseract'.
  String get id;

  /// Human-readable label, e.g. 'Ollama (LLaVA)'.
  String get label;

  /// Check if this backend is available (e.g. server reachable, model loaded).
  Future<bool> isAvailable({String? baseUrl});

  /// Run OCR on the given image bytes. Returns extracted text.
  Future<String> recognize(
    Uint8List imageBytes, {
    String? baseUrl,
    String? model,
    String? prompt,
  });
}
