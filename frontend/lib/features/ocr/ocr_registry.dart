import 'ocr_backend.dart';
import 'backends/ollama_backend.dart';

/// Registry of available OCR backends.
/// Add new backend = 1 line here.
final List<OcrBackend> ocrRegistry = [
  OllamaBackend(),
  // Future: TesseractBackend(), GoogleVisionBackend(), ...
];

/// Lookup a backend by [id]. Returns null if not found.
OcrBackend? lookupOcrBackend(String id) {
  for (final backend in ocrRegistry) {
    if (backend.id == id) return backend;
  }
  return null;
}
