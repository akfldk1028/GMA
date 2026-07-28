import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import '../core/ai_backend.dart';
import '../core/ai_capability.dart';
import '../core/ai_generate_options.dart';
import '../core/ai_message.dart';

/// On-device Gemma backend via flutter_gemma.
///
/// Uses FlutterGemma modern API for model management and inference.
/// Model must be downloaded before use (see model_manager/).
class GemmaBackend extends AiBackend {
  InferenceModel? _model;
  bool _modelSupportsImage = false;

  @override
  String get id => 'gemma';

  @override
  String get label => 'Gemma (On-Device)';

  @override
  Set<AiCapability> get capabilities => {
        AiCapability.text,
        AiCapability.vision,
      };

  @override
  int get priority => 0;

  @override
  Future<bool> isAvailable() async {
    try {
      return FlutterGemma.hasActiveModel();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generate(
    List<AiMessage> messages, {
    AiGenerateOptions? options,
  }) async {
    final hasImages = messages.any((m) => m.hasImages);
    final model = await _ensureModel(
      maxTokens: options?.maxTokens ?? 4096,
      hasImages: hasImages,
    );

    final chat = await model.createChat(
      temperature: options?.temperature ?? 0.7,
      topK: 1,
      supportImage: hasImages,
    );

    // Build prompt from messages — skip system (handled as first user context)
    final systemText = messages
        .where((m) => m.role == AiRole.system)
        .map((m) => m.textContent)
        .join('\n');

    var systemApplied = false;
    for (final msg in messages) {
      if (msg.role == AiRole.system) continue;

      final isUser = msg.role == AiRole.user;
      var text = msg.textContent;

      // Prepend system prompt to first user message only
      if (isUser && systemText.isNotEmpty && !systemApplied) {
        text = '$systemText\n\n$text';
        systemApplied = true;
      }

      if (msg.hasImages) {
        final imageBytes = msg.parts
            .firstWhere((p) => p.type == AiContentType.image)
            .bytes;
        if (imageBytes != null) {
          await chat.addQueryChunk(
            Message.withImage(text: text, imageBytes: imageBytes, isUser: isUser),
          );
          continue;
        }
      }

      await chat.addQueryChunk(Message(text: text, isUser: isUser));
    }

    final response = await chat.generateChatResponse();
    return _extractText(response);
  }

  /// Extract text from ModelResponse (sealed class).
  String _extractText(ModelResponse response) {
    return switch (response) {
      TextResponse(:final token) => token,
      ThinkingResponse(:final content) => content,
      FunctionCallResponse() => '',
      ParallelFunctionCallResponse() => '',
    };
  }

  Future<InferenceModel> _ensureModel({
    required int maxTokens,
    required bool hasImages,
  }) async {
    // Recreate model if image support requirement changed
    if (_model != null && hasImages && !_modelSupportsImage) {
      _model = null;
    }
    if (_model != null) return _model!;

    try {
      _model = await FlutterGemma.getActiveModel(
        maxTokens: maxTokens,
        supportImage: hasImages,
        maxNumImages: hasImages ? 1 : null,
      );
      _modelSupportsImage = hasImages;
      return _model!;
    } catch (e) {
      debugPrint('[GemmaBackend] model init failed: $e');
      rethrow;
    }
  }

  /// Release model resources.
  void dispose() {
    _model = null;
  }
}
