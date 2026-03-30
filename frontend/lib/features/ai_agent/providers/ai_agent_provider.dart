import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../ai_assistant/models/chat_message_model.dart';
import '../../note_editor/pages/providers/note_editor_provider.dart';
import '../../ocr/pages/providers/ocr_provider.dart';
import '../../pdf_structure/services/pdf_text_extraction_service.dart';
import '../../pdf_viewer/pages/providers/pdf_document_provider.dart';
import '../../workspace/pages/providers/workspace_provider.dart';
import '../backends/ai_backend.dart';
import '../backends/ollama_ai_backend.dart';
import '../services/block_extractor.dart';
import '../services/context_builder.dart';
import '../skills/agent_skill.dart';
import '../skills/skill_registry.dart';

part 'ai_agent_provider.g.dart';

/// Immutable state for the AI agent.
class AiAgentState {
  const AiAgentState({
    this.messages = const [],
    this.isSending = false,
  });

  final List<ChatMessage> messages;
  final bool isSending;

  AiAgentState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
  }) {
    return AiAgentState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// AI Agent with skill-based GMA MD block generation.
@Riverpod(keepAlive: true)
class AiAgent extends _$AiAgent {
  late AiBackend _backend;

  @override
  AiAgentState build() {
    _backend = OllamaAiBackend();
    return const AiAgentState();
  }

  /// Send a message with automatic skill matching.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isSending) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
    );

    try {
      final skill = matchSkill(content);
      final response = skill != null
          ? await _executeSkill(skill, content)
          : await _generalChat(content);

      state = state.copyWith(
        messages: [...state.messages, _assistantMsg(response)],
        isSending: false,
      );
    } catch (e) {
      debugPrint('[AiAgent] error: $e');
      state = state.copyWith(
        messages: [...state.messages, _assistantMsg(_formatError(e))],
        isSending: false,
      );
    }
  }

  /// Execute a specific skill by ID (from skill picker UI).
  Future<void> executeSkillById(String skillId, String userMessage) async {
    if (userMessage.trim().isEmpty || state.isSending) return;

    final skill = getSkillById(skillId);
    if (skill == null) {
      await sendMessage(userMessage);
      return;
    }

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: '[${skill.label}] $userMessage',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
    );

    try {
      final response = await _executeSkill(skill, userMessage);
      state = state.copyWith(
        messages: [...state.messages, _assistantMsg(response)],
        isSending: false,
      );
    } catch (e) {
      debugPrint('[AiAgent] skill error: $e');
      state = state.copyWith(
        messages: [...state.messages, _assistantMsg(_formatError(e))],
        isSending: false,
      );
    }
  }

  /// Insert a specific message's block(s) into the current note.
  bool insertBlockFromMessage(String messageId) {
    final msg = state.messages.where((m) => m.id == messageId).firstOrNull;
    if (msg == null || msg.role != ChatRole.assistant) return false;

    final block = BlockExtractor.extract(msg.content);
    if (!BlockExtractor.hasBlock(block)) return false;

    return _insertBlockAtCursor(block);
  }

  void clear() {
    state = const AiAgentState();
  }

  // ─── Private helpers ──────────────────────────────────

  ChatMessage _assistantMsg(String content) => ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.assistant,
        content: content,
        timestamp: DateTime.now(),
      );

  /// Shared logic: insert [block] text at the current note cursor position.
  bool _insertBlockAtCursor(String block) {
    final ws = ref.read(workspaceProviderProvider).valueOrNull;
    final noteId = ws?.currentNoteId;
    if (noteId == null) return false;

    final controller = ref.read(noteEditorProvider(noteId));
    if (controller == null) return false;

    final text = controller.text;
    final selection = controller.selection;
    final insertPos = selection.isValid ? selection.baseOffset : text.length;

    final prefix =
        insertPos > 0 && !text.substring(0, insertPos).endsWith('\n')
            ? '\n\n'
            : '\n';
    controller.text =
        '${text.substring(0, insertPos)}$prefix$block\n${text.substring(insertPos)}';

    return true;
  }

  Future<String> _executeSkill(AgentSkill skill, String userMessage) async {
    final pdfPageText = await _getCurrentPdfPageText();
    final noteContent = _getCurrentNoteContent();

    final messages = ContextBuilder.build(
      skill: skill,
      userMessage: userMessage,
      pdfPageText: pdfPageText,
      existingNoteContent: noteContent,
    );

    final baseUrl = await _getOllamaUrl();
    var response = await _backend.generate(messages, baseUrl: baseUrl);

    // Validate output; retry once with format reminder
    if (skill.validator != null && !skill.validator!(response)) {
      final retryMessages = List<Map<String, String>>.from(messages)
        ..add({'role': 'assistant', 'content': response})
        ..add({
          'role': 'user',
          'content':
              '출력 형식이 잘못되었다. 반드시 ::: ${skill.outputBlockType ?? ""} 블록 형식으로 다시 작성해라.',
        });
      response = await _backend.generate(retryMessages, baseUrl: baseUrl);
    }

    if (BlockExtractor.hasBlock(response)) {
      return BlockExtractor.extract(response);
    }
    return response;
  }

  Future<String> _generalChat(String content) async {
    final baseUrl = await _getOllamaUrl();

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': '너는 GMA 메모앱의 AI 어시스턴트다. '
            '사용자의 학술 연구와 PDF 분석을 도와준다. '
            '한국어로 답변해라.',
      },
    ];

    // History excluding the just-added user message
    final all = state.messages;
    final history = all.length > 1 ? all.sublist(0, all.length - 1) : <ChatMessage>[];
    final recent = history.length > 10
        ? history.sublist(history.length - 10)
        : history;
    for (final msg in recent) {
      messages.add({
        'role': msg.role == ChatRole.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    messages.add({'role': 'user', 'content': content});
    return _backend.generate(messages, baseUrl: baseUrl);
  }

  Future<String> _getOllamaUrl() async {
    final settings = await ref.read(ocrSettingsProvider.future);
    return settings.ollamaUrl;
  }

  Future<String?> _getCurrentPdfPageText() async {
    final ws = ref.read(workspaceProviderProvider).valueOrNull;
    final pdfPath = ws?.currentPdfPath;
    if (pdfPath == null) return null;

    final pageNumber = ref.read(pdfDocumentProvider).controller?.pageNumber;
    if (pageNumber == null) return null;

    try {
      return await PdfTextExtractionService.extractPageText(
          pdfPath, pageNumber);
    } catch (e) {
      debugPrint('[AiAgent] PDF text extraction failed: $e');
      return null;
    }
  }

  String? _getCurrentNoteContent() {
    final ws = ref.read(workspaceProviderProvider).valueOrNull;
    final noteId = ws?.currentNoteId;
    if (noteId == null) return null;
    return ref.read(noteEditorProvider(noteId))?.text;
  }

  String _formatError(Object e) {
    final msg = e.toString();
    if (msg.contains('Connection refused') ||
        msg.contains('SocketException')) {
      return 'Ollama 서버에 연결할 수 없습니다.\n'
          '`ollama serve` 로 서버를 시작하고, '
          '`ollama pull qwen2.5:3b` 로 모델을 설치하세요.';
    }
    if (msg.contains('TimeoutException')) {
      return '응답 시간이 초과되었습니다. 다시 시도해 주세요.';
    }
    return '오류: $msg';
  }
}
