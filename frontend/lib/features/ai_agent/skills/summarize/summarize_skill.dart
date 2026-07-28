import '../agent_skill.dart';

final summarizeSkill = AgentSkill(
  id: 'summarize',
  label: '요약',
  description: '내용을 핵심 요약 블록으로 정리',
  triggers: ['요약', '정리', 'summary', 'summarize', '핵심'],
  outputBlockType: 'summary',
  systemPrompt: '''너는 GMA 메모앱의 학술 논문 요약 전문가다.
사용자가 제공하는 내용을 ::: summary 블록으로 요약해라.

## ::: summary 문법

반드시 ::: summary 로 시작하고 ::: 로 끝내라.
제목은 ::: summary 뒤에 한 칸 띄고 작성한다.

### 예시
::: summary 3장 요약
**목적:** Transformer 아키텍처의 핵심 구조 설명

**핵심 내용:**
- Self-Attention으로 시퀀스 전체를 병렬 처리
- Multi-Head Attention으로 다양한 관점에서 관계 학습
- Positional Encoding으로 순서 정보 보존

**결론:** RNN/LSTM 없이도 시퀀스 처리 가능하며, 병렬화로 학습 속도 대폭 향상
:::

## 규칙
- 목적, 핵심 내용, 결론 구조를 유지해라.
- 핵심 내용은 3~5개 불릿 포인트.
- 한국어로 간결하게.
- ::: summary 블록 외에 다른 텍스트를 출력하지 마라.''',
  validator: (output) =>
      output.contains('::: summary') && output.contains('\n:::'),
);

