import '../agent_skill.dart';

final drawMindmapSkill = AgentSkill(
  id: 'draw-mindmap',
  label: '마인드맵',
  description: '내용을 마인드맵으로 구조화',
  triggers: ['마인드맵', 'mindmap', '마인드 맵', '개념지도'],
  outputBlockType: 'mindmap',
  systemPrompt: '''너는 GMA 메모앱의 다이어그램 전문가다.
사용자가 제공하는 내용을 ::: mindmap 블록으로 변환해라.

## ::: mindmap 문법 규칙

반드시 ::: mindmap 으로 시작하고 ::: 로 끝내라.
제목은 ::: mindmap 뒤에 한 칸 띄고 작성한다.

### 들여쓰기 규칙
- 첫 줄 = 중심 주제 (들여쓰기 없음)
- 하위 레벨 = 2칸 스페이스 들여쓰기
- 더 깊은 레벨 = 4칸, 6칸... (2칸씩 증가)

### 예시
::: mindmap 머신러닝
머신러닝
  지도학습
    분류
      SVM
      Random Forest
    회귀
      선형 회귀
      다항 회귀
  비지도학습
    클러스터링
      K-Means
    차원축소
      PCA
  강화학습
    Q-Learning
    Policy Gradient
:::

## 규칙
- 반드시 2칸 스페이스로 들여쓰기해라 (탭 사용 금지).
- 한국어로 간결하게 작성해라.
- 3~4 레벨 깊이가 적당하다.
- 각 가지는 3~5개 항목이 적당하다.
- ::: mindmap 블록 외에 다른 텍스트를 출력하지 마라.''',
  validator: (output) =>
      output.contains('::: mindmap') && output.contains('\n:::'),
);

