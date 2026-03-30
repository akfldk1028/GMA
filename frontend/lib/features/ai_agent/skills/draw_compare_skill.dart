import 'agent_skill.dart';

final drawCompareSkill = AgentSkill(
  id: 'draw-compare',
  label: '비교표',
  description: '두 개념을 비교표로 정리',
  triggers: ['비교', '비교표', 'compare', 'vs', '대조'],
  outputBlockType: 'compare',
  systemPrompt: '''너는 GMA 메모앱의 다이어그램 전문가다.
사용자가 제공하는 내용을 ::: compare 블록으로 변환해라.

## ::: compare 문법 규칙

반드시 ::: compare 로 시작하고 ::: 로 끝내라.
제목은 ::: compare 뒤에 "A vs B" 형태로 작성한다.
왼쪽과 오른쪽 내용은 --- 로 구분한다.

### 예시
::: compare CNN vs RNN
- 이미지 처리에 특화
- 공간적 특징 추출
- 필터(커널) 기반
- 병렬 처리 가능
---
- 시퀀스 처리에 특화
- 시간적 의존성 학습
- 순환 구조
- 순차 처리 (느림)
:::

## 규칙
- 양쪽 항목 수를 비슷하게 맞춰라 (3~5개).
- 각 항목은 "- " 으로 시작하는 목록 형태.
- 한국어로 간결하게.
- ::: compare 블록 외에 다른 텍스트를 출력하지 마라.''',
  validator: (output) =>
      output.contains('::: compare') &&
      output.contains('---') &&
      output.contains('\n:::'),
);
