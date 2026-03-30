import '../skills/agent_skill.dart';

/// Builds LLM message lists from skill + user input + PDF context.
class ContextBuilder {
  ContextBuilder._();

  static const _maxNoteContentLength = 2000;

  /// Build messages for the LLM call.
  ///
  /// [skill] provides the system prompt with block syntax rules.
  /// [userMessage] is what the user asked.
  /// [pdfPageText] is the current PDF page text (if available).
  /// [existingNoteContent] is the current note content (if available).
  static List<Map<String, String>> build({
    required AgentSkill skill,
    required String userMessage,
    String? pdfPageText,
    String? existingNoteContent,
  }) {
    final messages = <Map<String, String>>[];

    // System prompt from skill
    messages.add({
      'role': 'system',
      'content': skill.systemPrompt,
    });

    // Build user message with context
    final buffer = StringBuffer();

    if (pdfPageText != null && pdfPageText.isNotEmpty) {
      buffer.writeln('## 현재 PDF 페이지 내용:');
      buffer.writeln(pdfPageText);
      buffer.writeln();
    }

    if (existingNoteContent != null && existingNoteContent.isNotEmpty) {
      buffer.writeln('## 기존 노트 내용:');
      // Truncate to avoid token overflow
      final truncated = existingNoteContent.length > _maxNoteContentLength
          ? '${existingNoteContent.substring(0, _maxNoteContentLength)}...'
          : existingNoteContent;
      buffer.writeln(truncated);
      buffer.writeln();
    }

    buffer.writeln('## 요청:');
    buffer.writeln(userMessage);

    messages.add({
      'role': 'user',
      'content': buffer.toString(),
    });

    return messages;
  }
}
