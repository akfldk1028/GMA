import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../models/chat_message_model.dart';

part 'ai_chat_provider.g.dart';

@Riverpod(keepAlive: true)
class AiChat extends _$AiChat {
  Timer? _pendingResponse;

  @override
  List<ChatMessage> build() => [];

  void sendMessage(String content) {
    if (content.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    // Cancel any pending placeholder response
    _pendingResponse?.cancel();

    // Placeholder bot response — safely cancellable
    _pendingResponse = Timer(const Duration(milliseconds: 800), () {
      final botMsg = ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.assistant,
        content:
            'This is a placeholder response. AI integration coming soon!',
        timestamp: DateTime.now(),
      );
      state = [...state, botMsg];
    });
  }

  void clear() {
    _pendingResponse?.cancel();
    state = [];
  }
}
