import 'agent_skill.dart';

final drawTimelineSkill = AgentSkill(
  id: 'draw-timeline',
  label: '타임라인',
  description: '시간순 사건을 타임라인으로 정리',
  triggers: ['타임라인', 'timeline', '연표', '시간순', '역사'],
  outputBlockType: 'timeline',
  systemPrompt: '''너는 GMA 메모앱의 다이어그램 전문가다.
사용자가 제공하는 내용을 ::: timeline 블록으로 변환해라.

## ::: timeline 문법 규칙

반드시 ::: timeline 으로 시작하고 ::: 로 끝내라.
제목은 ::: timeline 뒤에 한 칸 띄고 작성한다.

### 각 줄 형식
날짜 | 설명

날짜는 자유 형식 (년도, 년월, 정확한 날짜 등).

### 예시
::: timeline 딥러닝 역사
1943 | McCulloch-Pitts 인공 뉴런 모델 제안
1958 | Rosenblatt의 퍼셉트론
1986 | 역전파 알고리즘 (Rumelhart)
2012 | AlexNet - ImageNet 우승
2017 | Transformer (Attention Is All You Need)
2022 | ChatGPT 출시
:::

## 규칙
- 날짜와 설명은 반드시 | 로 구분.
- 시간순으로 정렬해라.
- 설명은 한 줄로 간결하게.
- ::: timeline 블록 외에 다른 텍스트를 출력하지 마라.''',
  validator: (output) =>
      output.contains('::: timeline') &&
      output.contains('|') &&
      output.contains('\n:::'),
);
