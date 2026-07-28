import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../ocr/backends/ollama_backend.dart' show kDefaultOllamaUrl;
import '../core/ai_backend.dart';
import '../core/ai_capability.dart';
import '../core/ai_generate_options.dart';
import '../core/ai_message.dart';

/// Default chat model for agent skills.
const kDefaultAgentModel = 'qwen2.5:3b';

/// Ollama-based AI backend — calls /api/chat with conversation history.
class OllamaBackend extends AiBackend {
  OllamaBackend({
    this.baseUrl = kDefaultOllamaUrl,
    this.model = kDefaultAgentModel,
  });

  final String baseUrl;
  final String model;

  @override
  String get id => 'ollama';

  @override
  String get label => 'Ollama';

  @override
  Set<AiCapability> get capabilities => {AiCapability.text};

  @override
  int get priority => 20;

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generate(
    List<AiMessage> messages, {
    AiGenerateOptions? options,
  }) async {
    final body = {
      'model': model,
      'messages': messages.map(_serializeMessage).toList(),
      'stream': false,
    };

    if (options?.temperature != null) {
      body['options'] = {'temperature': options!.temperature};
    }

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
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

  Map<String, dynamic> _serializeMessage(AiMessage msg) {
    final role = switch (msg.role) {
      AiRole.system => 'system',
      AiRole.user => 'user',
      AiRole.assistant => 'assistant',
    };

    final result = <String, dynamic>{
      'role': role,
      'content': msg.textContent,
    };

    // Ollama uses separate 'images' field for vision
    final images = msg.parts
        .where((p) => p.type == AiContentType.image && p.bytes != null)
        .map((p) => base64Encode(p.bytes!))
        .toList();
    if (images.isNotEmpty) {
      result['images'] = images;
    }

    return result;
  }
}
