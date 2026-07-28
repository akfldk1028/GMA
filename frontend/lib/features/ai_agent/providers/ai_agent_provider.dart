import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../ai_assistant/models/chat_message_model.dart';
import '../../note_editor/pages/providers/note_editor_provider.dart';
import '../../pdf_structure/services/pdf_text_extraction_service.dart';
import '../../pdf_viewer/pages/providers/pdf_document_provider.dart';
import '../../workspace/pages/providers/workspace_provider.dart';
import '../backends/backend_registry.dart';
import '../backends/gemma_backend.dart';
import '../backends/ollama_backend.dart';
import '../core/ai_backend.dart';
import '../core/ai_capability.dart';
import '../core/ai_message.dart';
import '../services/backend_selector.dart';
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
    this.activeBackendId,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final String? activeBackendId;

  AiAgentState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? activeBackendId,
  }) {
    return AiAgentState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      activeBackendId: activeBackendId ?? this.activeBackendId,
    );
  }
}

/// AI Agent with skill-based GMA MD block generation.
///
/// Uses BackendSelector for dynamic backend selection based on
/// skill capabilities (nanoclaw orchestrator pattern).
@Riverpod(keepAlive: true)
class AiAgent extends _$AiAgent {
  @override
  AiAgentState build() {
    _initBackends();
    return const AiAgentState();
  }

  void _initBackends() {
    // Avoid duplicate registration on provider rebuild
    if (registeredBackends.isNotEmpty) return;

    // Register all backends
    registerBackend(GemmaBackend());
    registerBackend(OllamaBackend());

    // OpenRouter only if API key is configured
    // TODO: read from settings when SkillConfigProvider is ready
    // final apiKey = ref.read(settingsProvider).openRouterApiKey;
    // if (apiKey.isNotEmpty) registerBackend(OpenRouterBackend(apiKey: apiKey));
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

    final prefix = insertPos > 0 && !text.substring(0, insertPos).endsWith('\n')
        ? '\n\n'
        : '\n';
    controller.text =
        '${text.substring(0, insertPos)}$prefix$block\n${text.substring(insertPos)}';

    return true;
  }

  /// Select backend dynamically based on skill capabilities, then generate.
  Future<AiBackend> _selectBackend(Set<AiCapability> required) async {
    final backend = await BackendSelector.select(required);
    state = state.copyWith(activeBackendId: backend.id);
    return backend;
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

    final backend = await _selectBackend(skill.requiredCapabilities);
    var response = await backend.generate(messages);

    // Validate output; retry once with format reminder
    if (skill.validator != null && !skill.validator!(response)) {
      final retryMessages = List<AiMessage>.from(messages)
        ..add(AiMessage.text(AiRole.assistant, response))
        ..add(
          AiMessage.text(
            AiRole.user,
            '출력 형식이 잘못되었다. 반드시 ::: ${skill.outputBlockType ?? ""} 블록 형식으로 다시 작성해라.',
          ),
        );
      response = await backend.generate(retryMessages);
    }

    if (BlockExtractor.hasBlock(response)) {
      return BlockExtractor.extract(response);
    }
    return response;
  }

  Future<String> _generalChat(String content) async {
    final backend = await _selectBackend({AiCapability.text});

    final messages = <AiMessage>[
      AiMessage.text(
        AiRole.system,
        '너는 GMA 메모앱의 AI 어시스턴트다. '
        '사용자의 학술 연구와 PDF 분석을 도와준다. '
        '한국어로 답변해라.',
      ),
    ];

    // History excluding the just-added user message
    final all = state.messages;
    final history = all.length > 1
        ? all.sublist(0, all.length - 1)
        : <ChatMessage>[];
    final recent = history.length > 10
        ? history.sublist(history.length - 10)
        : history;
    for (final msg in recent) {
      messages.add(
        AiMessage.text(
          msg.role == ChatRole.user ? AiRole.user : AiRole.assistant,
          msg.content,
        ),
      );
    }

    messages.add(AiMessage.text(AiRole.user, content));
    return backend.generate(messages);
  }

  Future<String?> _getCurrentPdfPageText() async {
    final ws = ref.read(workspaceProviderProvider).valueOrNull;
    final pdfPath = ws?.currentPdfPath;
    if (pdfPath == null) return null;

    final pageNumber = ref.read(pdfDocumentProvider).controller?.pageNumber;
    if (pageNumber == null) return null;

    try {
      return await PdfTextExtractionService.extractPageText(
        pdfPath,
        pageNumber,
      );
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
    if (msg.contains('AiBackendUnavailableException') ||
        msg.contains('No available backend')) {
      return 'AI 백엔드를 사용할 수 없습니다.\n'
          'Gemma 모델을 다운로드하거나, '
          'OpenRouter API 키를 설정하거나, '
          'Ollama 서버를 시작하세요.';
    }
    if (msg.contains('Connection refused') || msg.contains('SocketException')) {
      return 'AI 서버에 연결할 수 없습니다.\n'
          'Gemma 모델을 다운로드하거나, '
          'Ollama 서버를 시작하세요.';
    }
    if (msg.contains('TimeoutException')) {
      return '응답 시간이 초과되었습니다. 다시 시도해 주세요.';
    }
    return '오류: $msg';
  }
}
