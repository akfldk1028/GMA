import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/skills/skill_registry.dart';

void main() {
  group('matchSkill', () {
    test('matches flow triggers', () {
      expect(matchSkill('이거 플로우차트로 그려줘')?.id, 'draw-flow');
      expect(matchSkill('순서도 만들어줘')?.id, 'draw-flow');
      expect(matchSkill('흐름도로 정리')?.id, 'draw-flow');
      expect(matchSkill('flowchart please')?.id, 'draw-flow');
    });

    test('matches mindmap triggers', () {
      expect(matchSkill('마인드맵으로 정리해줘')?.id, 'draw-mindmap');
      expect(matchSkill('mindmap 그려')?.id, 'draw-mindmap');
    });

    test('matches graph triggers', () {
      expect(matchSkill('관계도 그려줘')?.id, 'draw-graph');
      expect(matchSkill('그래프로 보여줘')?.id, 'draw-graph');
    });

    test('matches compare triggers', () {
      expect(matchSkill('비교표 만들어줘')?.id, 'draw-compare');
      expect(matchSkill('A vs B 비교해줘')?.id, 'draw-compare');
    });

    test('matches timeline triggers', () {
      expect(matchSkill('타임라인으로 정리')?.id, 'draw-timeline');
      expect(matchSkill('연표 만들어')?.id, 'draw-timeline');
    });

    test('matches explain triggers', () {
      expect(matchSkill('이 페이지 쉽게 설명해줘')?.id, 'explain-page');
      expect(matchSkill('예시로 풀어서 알려줘')?.id, 'explain-page');
    });

    test('matches summarize triggers', () {
      expect(matchSkill('이거 요약해줘')?.id, 'summarize');
      expect(matchSkill('핵심 정리해줘')?.id, 'summarize');
    });

    test('returns null for unmatched input', () {
      expect(matchSkill('안녕하세요'), isNull);
      expect(matchSkill('오늘 날씨 어때?'), isNull);
    });

    test('picks highest scoring skill on multi-match', () {
      // "플로우차트로 비교" → flow has 1 hit, compare has 1 hit
      // but "플로우차트 순서도" → flow has 2 hits → wins
      final skill = matchSkill('플로우차트 순서도로 그려');
      expect(skill?.id, 'draw-flow');
    });
  });

  group('getSkillById', () {
    test('finds existing skill', () {
      expect(getSkillById('draw-flow')?.label, '플로우차트');
      expect(getSkillById('summarize')?.label, '요약');
    });

    test('returns null for unknown id', () {
      expect(getSkillById('nonexistent'), isNull);
    });
  });

  group('skillRegistry', () {
    test('has 7 skills registered', () {
      expect(skillRegistry.length, 7);
    });

    test('all skills have unique ids', () {
      final ids = skillRegistry.map((s) => s.id).toSet();
      expect(ids.length, skillRegistry.length);
    });

    test('all skills have non-empty triggers', () {
      for (final skill in skillRegistry) {
        expect(skill.triggers, isNotEmpty, reason: '${skill.id} has no triggers');
      }
    });

    test('all skills have non-empty systemPrompt', () {
      for (final skill in skillRegistry) {
        expect(skill.systemPrompt, isNotEmpty,
            reason: '${skill.id} has empty systemPrompt');
      }
    });
  });
}
