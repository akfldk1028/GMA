import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/services/context_builder.dart';
import 'package:gma_frontend/features/ai_agent/skills/skill_registry.dart';

void main() {
  group('ContextBuilder.build', () {
    test('includes system prompt from skill', () {
      final skill = getSkillById('draw-flow')!;
      final messages = ContextBuilder.build(
        skill: skill,
        userMessage: '플로우차트 그려줘',
      );

      expect(messages.length, 2);
      expect(messages[0]['role'], 'system');
      expect(messages[0]['content'], contains('::: flow'));
    });

    test('includes PDF text in user message', () {
      final skill = getSkillById('summarize')!;
      final messages = ContextBuilder.build(
        skill: skill,
        userMessage: '요약해줘',
        pdfPageText: 'Transformer는 attention 기반 모델이다.',
      );

      final userContent = messages[1]['content']!;
      expect(userContent, contains('PDF 페이지 내용'));
      expect(userContent, contains('Transformer'));
      expect(userContent, contains('요약해줘'));
    });

    test('includes note content in user message', () {
      final skill = getSkillById('explain-page')!;
      final messages = ContextBuilder.build(
        skill: skill,
        userMessage: '설명해줘',
        existingNoteContent: '# 기존 노트\n내용이 있음',
      );

      final userContent = messages[1]['content']!;
      expect(userContent, contains('기존 노트 내용'));
      expect(userContent, contains('기존 노트'));
    });

    test('truncates long note content', () {
      final skill = getSkillById('draw-flow')!;
      final longNote = 'A' * 5000;
      final messages = ContextBuilder.build(
        skill: skill,
        userMessage: '그려줘',
        existingNoteContent: longNote,
      );

      final userContent = messages[1]['content']!;
      expect(userContent, contains('...'));
      // Original 5000 chars should be truncated to 2000
      expect(userContent.length, lessThan(5000));
    });

    test('works without optional context', () {
      final skill = getSkillById('draw-mindmap')!;
      final messages = ContextBuilder.build(
        skill: skill,
        userMessage: '마인드맵 그려줘',
      );

      expect(messages.length, 2);
      final userContent = messages[1]['content']!;
      expect(userContent, isNot(contains('PDF 페이지 내용')));
      expect(userContent, isNot(contains('기존 노트 내용')));
      expect(userContent, contains('마인드맵 그려줘'));
    });
  });
}
