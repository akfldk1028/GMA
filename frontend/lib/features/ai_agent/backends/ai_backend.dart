/// Abstract interface for AI backends (plugin pattern).
///
/// Same pattern as OcrBackend — new backend = 1 file + 1 line in registry.
abstract class AiBackend {
  /// Unique identifier, e.g. 'ollama', 'local-llama'.
  String get id;

  /// Human-readable label.
  String get label;

  /// Check if this backend is available.
  Future<bool> isAvailable({String? baseUrl});

  /// Generate a response for the given messages.
  ///
  /// [messages] is a list of {role: 'system'|'user'|'assistant', content: '...'}.
  /// Returns the assistant's response text.
  Future<String> generate(
    List<Map<String, String>> messages, {
    String? baseUrl,
    String? model,
  });
}
