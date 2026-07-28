import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/skills/skill_registry.dart';

void main() {
  group('Skill validators', () {
    test('draw-flow validator accepts valid block', () {
      final skill = getSkillById('draw-flow')!;
      expect(
        skill.validator!('::: flow 테스트\n(시작) --> 끝\n:::'),
        isTrue,
      );
    });

    test('draw-flow validator rejects missing block', () {
      final skill = getSkillById('draw-flow')!;
      expect(skill.validator!('그냥 텍스트'), isFalse);
    });

    test('draw-mindmap validator accepts valid block', () {
      final skill = getSkillById('draw-mindmap')!;
      expect(
        skill.validator!('::: mindmap 주제\n루트\n  자식\n:::'),
        isTrue,
      );
    });

    test('draw-graph validator accepts valid block', () {
      final skill = getSkillById('draw-graph')!;
      expect(
        skill.validator!('::: graph 관계\nA -- 포함 --> B\n:::'),
        isTrue,
      );
    });

    test('draw-compare validator accepts valid block with separator', () {
      final skill = getSkillById('draw-compare')!;
      expect(
        skill.validator!('::: compare A vs B\n왼쪽\n---\n오른쪽\n:::'),
        isTrue,
      );
    });

    test('draw-compare validator rejects without separator', () {
      final skill = getSkillById('draw-compare')!;
      expect(
        skill.validator!('::: compare A vs B\n내용만\n:::'),
        isFalse,
      );
    });

    test('draw-timeline validator accepts valid block with pipe', () {
      final skill = getSkillById('draw-timeline')!;
      expect(
        skill.validator!('::: timeline 역사\n2020 | 시작\n2023 | 현재\n:::'),
        isTrue,
      );
    });

    test('draw-timeline validator rejects without pipe', () {
      final skill = getSkillById('draw-timeline')!;
      expect(
        skill.validator!('::: timeline 역사\n그냥 텍스트\n:::'),
        isFalse,
      );
    });

    test('explain-page validator accepts concept or example', () {
      final skill = getSkillById('explain-page')!;
      expect(
        skill.validator!('::: concept 정의\n설명\n:::'),
        isTrue,
      );
      expect(
        skill.validator!('::: example 비유\n예시\n:::'),
        isTrue,
      );
    });

    test('summarize validator accepts summary block', () {
      final skill = getSkillById('summarize')!;
      expect(
        skill.validator!('::: summary 요약\n핵심 내용\n:::'),
        isTrue,
      );
    });
  });
}
