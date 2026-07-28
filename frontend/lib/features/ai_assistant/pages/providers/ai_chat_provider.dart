import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../ocr/backends/ollama_backend.dart';
import '../../../ocr/pages/providers/ocr_provider.dart';
import '../../models/chat_message_model.dart';

part 'ai_chat_provider.g.dart';

/// Default chat model (general-purpose, not vision).
const _kDefaultChatModel = 'llama3';

@Riverpod(keepAlive: true)
class AiChat extends _$AiChat {
  @override
  List<ChatMessage> build() => [];

  /// Whether a request is currently in-flight.
  bool _isSending = false;
  bool get isSending => _isSending;

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (_isSending) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    _isSending = true;

    try {
      final response = await _callOllama(state);

      final botMsg = ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.assistant,
        content: response,
        timestamp: DateTime.now(),
      );
      state = [...state, botMsg];
    } catch (e) {
      debugPrint('[AiChat] Ollama error: $e');

      final errorMsg = ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.assistant,
        content: _formatError(e),
        timestamp: DateTime.now(),
      );
      state = [...state, errorMsg];
    } finally {
      _isSending = false;
    }
  }

  /// Call Ollama /api/chat with full conversation history.
  Future<String> _callOllama(List<ChatMessage> messages) async {
    // Read Ollama URL from OCR settings (shared config)
    final ocrSettings = ref.read(ocrSettingsProvider).valueOrNull;
    final baseUrl = ocrSettings?.ollamaUrl ?? kDefaultOllamaUrl;

    // Filter out error messages so they don't confuse the model
    final ollamaMessages = messages
        .where((m) =>
            m.role == ChatRole.user ||
            !m.content.startsWith('Ollama') &&
                !m.content.startsWith('오류') &&
                !m.content.startsWith('응답 시간'))
        .map((m) => {
          'role': m.role == ChatRole.user ? 'user' : 'assistant',
          'content': m.content,
        }).toList();

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': _kDefaultChatModel,
            'messages': ollamaMessages,
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
    return (msg?['content'] as String?)?.trim() ?? '(empty response)';
  }

  String _formatError(Object e) {
    final msg = e.toString();
    if (msg.contains('Connection refused') ||
        msg.contains('SocketException')) {
      return 'Ollama 서버에 연결할 수 없습니다. '
          'Ollama가 실행 중인지 확인하세요. (ollama serve)';
    }
    if (msg.contains('TimeoutException')) {
      return '응답 시간이 초과되었습니다. 다시 시도해 주세요.';
    }
    return '오류가 발생했습니다: $msg';
  }

  void clear() {
    state = [];
  }
}
