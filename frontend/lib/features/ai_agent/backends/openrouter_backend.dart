import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/ai_backend.dart';
import '../core/ai_capability.dart';
import '../core/ai_generate_options.dart';
import '../core/ai_message.dart';

const _kOpenRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
const _kDefaultModel = 'google/gemma-4-e4b';

/// OpenRouter cloud API backend — OpenAI-compatible format.
class OpenRouterBackend extends AiBackend {
  OpenRouterBackend({
    required this.apiKey,
    this.model = _kDefaultModel,
  });

  final String apiKey;
  final String model;

  @override
  String get id => 'openrouter';

  @override
  String get label => 'OpenRouter (Cloud)';

  @override
  Set<AiCapability> get capabilities => {
        AiCapability.text,
        AiCapability.vision,
      };

  @override
  int get priority => 10;

  @override
  Future<bool> isAvailable() async => apiKey.isNotEmpty;

  @override
  Future<String> generate(
    List<AiMessage> messages, {
    AiGenerateOptions? options,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'messages': messages.map(_serializeMessage).toList(),
    };

    if (options?.maxTokens != null) body['max_tokens'] = options!.maxTokens;
    if (options?.temperature != null) body['temperature'] = options!.temperature;
    if (options?.topP != null) body['top_p'] = options!.topP;

    final response = await http
        .post(
          Uri.parse(_kOpenRouterUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://gma-app.dev',
            'X-Title': 'GMA',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      throw Exception(
        'OpenRouter API error ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) return '';

    final msg = choices[0]['message'] as Map<String, dynamic>?;
    return (msg?['content'] as String?)?.trim() ?? '';
  }

  /// Serialize to OpenAI multimodal format.
  Map<String, dynamic> _serializeMessage(AiMessage msg) {
    final role = switch (msg.role) {
      AiRole.system => 'system',
      AiRole.user => 'user',
      AiRole.assistant => 'assistant',
    };

    // Text-only: simple string content
    if (!msg.hasImages && !msg.hasAudio) {
      return {'role': role, 'content': msg.textContent};
    }

    // Multimodal: content array
    final content = <Map<String, dynamic>>[];
    for (final part in msg.parts) {
      switch (part.type) {
        case AiContentType.text:
          content.add({'type': 'text', 'text': part.text ?? ''});
        case AiContentType.image:
          if (part.bytes != null) {
            final b64 = base64Encode(part.bytes!);
            final mime = part.mimeType ?? 'image/png';
            content.add({
              'type': 'image_url',
              'image_url': {'url': 'data:$mime;base64,$b64'},
            });
          }
        case AiContentType.audio:
          // OpenRouter audio support is model-dependent; skip for now
          break;
      }
    }

    return {'role': role, 'content': content};
  }
}
