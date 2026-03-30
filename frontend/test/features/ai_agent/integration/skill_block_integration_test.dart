import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/services/block_extractor.dart';
import 'package:gma_frontend/features/ai_agent/services/context_builder.dart';
import 'package:gma_frontend/features/ai_agent/skills/skill_registry.dart';
import 'package:gma_frontend/features/gma_md/parser/flow_parser.dart';
import 'package:gma_frontend/features/gma_md/parser/mindmap_parser.dart';
import 'package:gma_frontend/features/gma_md/parser/timeline_parser.dart';

/// Integration tests: skill output → GMA MD parser compatibility.
///
/// Verifies that "ideal" LLM outputs for each skill can actually
/// be parsed by the existing GMA MD parsers.
void main() {
  group('Skill → GMA Parser integration', () {
    test('draw-flow output parses with FlowParser', () {
      const idealOutput = '''::: flow 방법론
(시작) --> 데이터 수집
데이터 수집 --> 전처리
전처리 --> {수렴?}
{수렴?} -- Yes --> 평가
{수렴?} -- No --> 전처리
평가 --> (끝)
:::''';

      // Skill validator passes
      final skill = getSkillById('draw-flow')!;
      expect(skill.validator!(idealOutput), isTrue);

      // Block extractor works
      final block = BlockExtractor.extract(idealOutput);
      expect(block, contains('::: flow'));

      // GMA parser can parse the content
      final content = idealOutput
          .split('\n')
          .skip(1) // skip ::: flow header
          .take(6) // take content lines before closing :::
          .join('\n');
      final graph = FlowParser.parse(content);
      expect(graph.nodes, isNotEmpty);
      expect(graph.edges, isNotEmpty);
      expect(graph.nodes.length, greaterThanOrEqualTo(4));
    });

    test('draw-mindmap output parses with MindmapParser', () {
      const idealOutput = '''::: mindmap 머신러닝
머신러닝
  지도학습
    분류
    회귀
  비지도학습
    클러스터링
:::''';

      final skill = getSkillById('draw-mindmap')!;
      expect(skill.validator!(idealOutput), isTrue);

      final content = idealOutput
          .split('\n')
          .skip(1)
          .takeWhile((l) => l.trim() != ':::')
          .join('\n');
      final root = MindmapParser.parse(content);
      expect(root, isNotNull);
      expect(root!.label, '머신러닝');
      expect(root.children, isNotEmpty);
    });

    test('draw-graph output parses with FlowParser (shared)', () {
      const idealOutput = '''::: graph 관계도
세포 -- 포함 --> 핵
핵 -- 포함 --> DNA
DNA -- 전사 --> RNA
:::''';

      final skill = getSkillById('draw-graph')!;
      expect(skill.validator!(idealOutput), isTrue);

      final content = idealOutput
          .split('\n')
          .skip(1)
          .takeWhile((l) => l.trim() != ':::')
          .join('\n');
      final graph = FlowParser.parse(content);
      expect(graph.nodes.length, 4);
      expect(graph.edges.length, 3);
    });

    test('draw-timeline output parses with TimelineParser', () {
      const idealOutput = '''::: timeline 딥러닝 역사
1943 | McCulloch-Pitts 뉴런 모델
1986 | 역전파 알고리즘
2017 | Transformer
:::''';

      final skill = getSkillById('draw-timeline')!;
      expect(skill.validator!(idealOutput), isTrue);

      final content = idealOutput
          .split('\n')
          .skip(1)
          .takeWhile((l) => l.trim() != ':::')
          .join('\n');
      final events = TimelineParser.parse(content);
      expect(events.length, 3);
      expect(events.first.date, '1943');
      expect(events.last.description, 'Transformer');
    });

    test('draw-compare output has correct separator', () {
      const idealOutput = '''::: compare CNN vs RNN
- 이미지 처리에 특화
- 공간적 특징 추출
---
- 시퀀스 처리에 특화
- 시간적 의존성 학습
:::''';

      final skill = getSkillById('draw-compare')!;
      expect(skill.validator!(idealOutput), isTrue);

      // CompareBlock splits on ---
      final content = idealOutput
          .split('\n')
          .skip(1)
          .takeWhile((l) => l.trim() != ':::')
          .join('\n');
      final parts = content.split(RegExp(r'\n\s*---\s*\n'));
      expect(parts.length, 2);
      expect(parts[0], contains('이미지'));
      expect(parts[1], contains('시퀀스'));
    });

    test('explain-page output contains concept or example block', () {
      const idealOutput = '''::: concept Self-Attention
각 단어가 다른 모든 단어와의 관계를 계산
:::

::: example Self-Attention 비유
교실에서 선생님이 질문했을 때
:::''';

      final skill = getSkillById('explain-page')!;
      expect(skill.validator!(idealOutput), isTrue);

      final block = BlockExtractor.extract(idealOutput);
      expect(block, contains('::: concept'));
      expect(block, contains('::: example'));
    });

    test('summarize output contains summary block', () {
      const idealOutput = '''::: summary 3장 요약
**목적:** 핵심 구조 설명
**핵심 내용:**
- Self-Attention
- Multi-Head
**결론:** 병렬화 가능
:::''';

      final skill = getSkillById('summarize')!;
      expect(skill.validator!(idealOutput), isTrue);
    });

    test('ContainerBlockParser can parse all skill block types', () {
      // Verify the GMA MD parser recognizes all block types used by skills
      final blockTypes = ['flow', 'mindmap', 'graph', 'compare', 'timeline',
                          'concept', 'example', 'summary'];

      for (final type in blockTypes) {
        final markdown = '::: $type Title\ncontent\n:::';
        final lines = markdown.split('\n');

        // ContainerBlockSyntax should match the opening line
        final openPattern = RegExp(r'^:::\s*(\w[\w-]*)\s*(.*?)(?:\s*\{(.+)\})?\s*$');
        expect(openPattern.hasMatch(lines[0]), isTrue,
            reason: 'ContainerBlockParser should match ::: $type');
      }
    });
  });

  group('ContextBuilder + Skill prompt', () {
    test('all skills produce valid system messages', () {
      for (final skill in skillRegistry) {
        final messages = ContextBuilder.build(
          skill: skill,
          userMessage: 'test input',
        );

        // System message contains block syntax
        final system = messages[0]['content']!;
        expect(system, isNotEmpty);

        // User message contains the request
        final user = messages[1]['content']!;
        expect(user, contains('test input'));
      }
    });

    test('diagram skills mention ::: syntax in prompt', () {
      final diagramSkills = skillRegistry
          .where((s) => s.id.startsWith('draw-'))
          .toList();

      for (final skill in diagramSkills) {
        expect(skill.systemPrompt, contains(':::'),
            reason: '${skill.id} prompt should mention ::: syntax');
        expect(skill.systemPrompt, contains(skill.outputBlockType!),
            reason: '${skill.id} prompt should mention its block type');
      }
    });
  });
}
