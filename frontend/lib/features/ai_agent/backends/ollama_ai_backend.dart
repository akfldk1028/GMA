import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../ocr/backends/ollama_backend.dart' show kDefaultOllamaUrl;
import 'ai_backend.dart';

/// Default chat model for agent skills.
const kDefaultAgentModel = 'qwen2.5:3b';

/// Ollama-based AI backend — calls /api/chat with conversation history.
class OllamaAiBackend extends AiBackend {
  @override
  String get id => 'ollama';

  @override
  String get label => 'Ollama';

  @override
  Future<bool> isAvailable({String? baseUrl}) async {
    final url = baseUrl ?? kDefaultOllamaUrl;
    try {
      final response = await http
          .get(Uri.parse('$url/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generate(
    List<Map<String, String>> messages, {
    String? baseUrl,
    String? model,
  }) async {
    final url = baseUrl ?? kDefaultOllamaUrl;
    final modelName = model ?? kDefaultAgentModel;

    final response = await http
        .post(
          Uri.parse('$url/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': modelName,
            'messages': messages,
            'stream': false,
          }),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      throw Exception(
        'Ollama API error ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final msg = json['message'] as Map<String, dynamic>?;
    return (msg?['content'] as String?)?.trim() ?? '';
  }
}
