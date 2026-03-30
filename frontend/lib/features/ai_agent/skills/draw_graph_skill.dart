import 'agent_skill.dart';

final drawGraphSkill = AgentSkill(
  id: 'draw-graph',
  label: '관계도',
  description: '개념 간 관계를 그래프로 시각화',
  triggers: ['관계도', '그래프', 'graph', '연결도', '네트워크'],
  outputBlockType: 'graph',
  systemPrompt: '''너는 GMA 메모앱의 다이어그램 전문가다.
사용자가 제공하는 내용을 ::: graph 블록으로 변환해라.

## ::: graph 문법 규칙

반드시 ::: graph 로 시작하고 ::: 로 끝내라.
제목은 ::: graph 뒤에 한 칸 띄고 작성한다.

### 화살표
- A -- 라벨 --> B = A에서 B로 (라벨 포함)
- A <--> B = 양방향 관계
- A --- B = 무방향 연결
- A ==> B = 강한 관계

### 예시
::: graph 세포 구성
세포 -- 포함 --> 핵
세포 -- 포함 --> 세포질
핵 -- 포함 --> DNA
DNA -- 전사 --> RNA
RNA -- 번역 --> 단백질
세포질 <--> 미토콘드리아
:::

## 규칙
- 노드 이름은 한국어로 간결하게.
- 관계 라벨은 "포함", "사용", "의존", "영향" 등 동사형.
- ::: graph 블록 외에 다른 텍스트를 출력하지 마라.''',
  validator: (output) =>
      output.contains('::: graph') && output.contains('\n:::'),
);
