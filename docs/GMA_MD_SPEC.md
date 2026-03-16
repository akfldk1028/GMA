# GMA-MD: Custom Markdown Syntax Specification

## 원칙

1. **MD-First**: 모든 콘텐츠는 유효한 Markdown. 커스텀 블록은 `:::` 컨테이너 디렉티브 사용.
2. **Reversible**: `:::` 라인 제거 시 깨끗한 표준 Markdown으로 복원 (MdUnwrapper).
3. **Plugin Pattern**: 새 블록 타입 = `blocks/` 에 1파일 + extension에 1줄 등록.
4. **AI-ready**: AI가 블록을 생성/파싱하기 쉬운 구조.

---

## 컨테이너 블록 공통 문법

```
::: <type> [title] [{key: "value", ...}]
content (표준 Markdown 또는 타입별 전용 문법)
:::
```

CommonMark 확장 제안 기반 (MyST/remark-directive/Pandoc 공통 표준).

### 메타데이터 (선택적)

```markdown
::: concept 미분의 정의 {source: "p.42", tags: "calculus"}
content...
:::
```

- `{key: "value", ...}` 형식으로 제목 뒤에 추가
- 선택적 — 없어도 동작
- Unwrap 시 자동 제거 (역방향 호환)

---

## 블록 타입

### Category A: Structural (학습 구조)

| Type | Aliases | 렌더링 | 학술 근거 |
|------|---------|--------|-----------|
| `concept` | `definition` | 파란 accent 박스 + 본문 | MyST `prf:definition` |
| `theorem` | — | 보라색 double border, "정리: 제목", 수학적 느낌 | MyST `prf:theorem` |
| `proof` | — | 남색 left border, 들여쓰기, QED(■) 종료마크 | MyST `prf:proof` |
| `example` | — | 초록 accent, "예제: 제목", 하단 점선 구분 | MyST `prf:example` |
| `summary` | `abstract`, `tldr` | highlight 배경 카드 | Obsidian `abstract/tldr` |

### Category B: Visual (시각화)

| Type | 렌더링 | 참고 |
|------|--------|------|
| `flow` | 세로 플로우차트 (CustomPaint, 자동 노드 크기) | D2 문법 기반 |
| `graph` | 원형 레이아웃 관계 그래프 (CustomPaint) | flow와 동일 문법 |
| `compare` | 2열 비교 카드 | `---`로 좌우 분리 |
| `timeline` | 세로 타임라인 (위젯 기반) | `날짜 \| 설명` 문법 |
| `mindmap` | 수평 트리 마인드맵 (CustomPaint) | 들여쓰기 기반 계층 |

### Category C: Callout (강조) — Obsidian 호환

| Type | Aliases | 색상 | 아이콘 |
|------|---------|------|--------|
| `note` | — | Blue | Pencil |
| `tip` | `hint`, `important` | Cyan | Lightbulb |
| `warning` | `caution`, `attention` | Orange | ⚠ Warning |
| `question` | `help`, `faq` | Yellow | ? |
| `danger` | `error` | Red | ⚡ Danger |
| `quote` | `cite` | Grey | " Quote |

---

## Diagram Syntax (시각화 문법)

### Flow (순서도)

```markdown
::: flow
문제의식 --> 기존 분석
기존 분석 --> 비교와 대조
비교와 대조 --> 새 관점 제시
새 관점 제시 --> 기존 지식과 연결
:::
```

**화살표 타입:**
- `-->` 순차 (실선)
- `==>` 강조 (굵은선)
- `-.->` 약한 (점선)
- `<-->` 양방향
- `---` 무방향

**분기/합류:**
- `A --> B, C` 분기
- `A, B --> C` 합류

**노드 형태:**
- `텍스트` → 기본 사각형
- `(텍스트)` → 타원/pill (시작/끝)
- `[텍스트]` → 둥근 사각형 (프로세스)
- `{텍스트}` → 다이아몬드 (조건/분기)

**레이블:**
- `A -- 라벨 --> B` — 엣지에 라벨 표시

### Graph (관계 그래프)

```markdown
::: graph 개념 관계도
개념A -- 포함 --> 개념B
개념A -- 관련 --> 개념C
개념B <--> 개념D
개념C --- 개념E
:::
```

Flow와 동일 문법, 원형(circular) 레이아웃으로 렌더링.

### Compare (비교)

```markdown
::: compare 사전적 정의 vs 조작적 정의
사전적 정의: 일반적 의미 규정
고정적, 보편적
---
조작적 정의: 연구 목적에 맞는 정의
맥락에 따라 변화
:::
```

내용은 `---`로 좌우 분리.

### Timeline (타임라인)

```markdown
::: timeline 한국전쟁
1950.06.25 | 한국전쟁 발발
1950.09.15 | 인천상륙작전
1953.07.27 | 정전협정 체결
:::
```

- 문법: `날짜 | 설명` (각 줄)
- 설명 부분은 인라인 마크다운 지원 (**bold**, `$수식$` 등)
- Unwrap: `- 날짜: 설명` 불릿 리스트로 변환

### Mindmap (마인드맵)

```markdown
::: mindmap 미적분학
미적분학
  미분
    도함수
    편미분
  적분
    부정적분
    정적분
:::
```

- 들여쓰기 기반 계층 구조 (2스페이스/레벨)
- 수평 트리 레이아웃 (CustomPaint)
- Unwrap: 들여쓰기 불릿 리스트로 변환

---

## Unwrap 규칙 (GMA-MD → 표준 MD)

| GMA Block | Standard MD |
|-----------|-------------|
| `::: concept 제목` | `## 제목` + 본문 유지 |
| `::: theorem 제목` | `## 정리: 제목` + 본문 |
| `::: proof 제목` | `## 증명: 제목` + 본문 + `□` |
| `::: example 제목` | `## 예제: 제목` + 본문 |
| `::: summary 제목` | `> **제목**` blockquote |
| `::: flow` | 토폴로지 정렬 → 불릿 리스트 |
| `::: graph` | 관계 텍스트 → 불릿 리스트 |
| `::: compare 제목` | `## 제목` + 마크다운 테이블 |
| `::: timeline 제목` | `## 제목` + `- 날짜: 설명` 리스트 |
| `::: mindmap 제목` | `## 제목` + 들여쓰기 불릿 리스트 |
| `::: note/tip/warning/...` | `> **[Type]** 제목` blockquote |
| `{key: "value"}` 메타데이터 | 제거됨 |
| `:::` 열기/닫기 | 제거됨 |

---

## 기존 인라인 문법 (구현 완료)

| 문법 | 설명 |
|------|------|
| `- 🔴 P3  텍스트` | PDF 마커 |
| `[[노트이름]]` | 위키링크 |
| `$수식$` / `$$블록$$` | LaTeX |
| `---\nyaml\n---` | Frontmatter |

---

## 예시

### Concept Block
```markdown
::: concept 미분의 정의
함수 f(x)의 도함수는 다음과 같이 정의된다:
$\lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$
:::
```

### Theorem Block
```markdown
::: theorem 중간값 정리
함수 $f$가 $[a, b]$에서 연속이고 $f(a) \neq f(b)$이면,
$f(a)$와 $f(b)$ 사이의 임의의 값 $k$에 대해 $f(c) = k$인 $c \in (a, b)$가 존재한다.
:::
```

### Proof Block
```markdown
::: proof 중간값 정리 증명
$g(x) = f(x) - k$로 정의하면...
따라서 $g(c) = 0$, 즉 $f(c) = k$이다.
:::
```

### Example Block
```markdown
::: example 미분 계산
$f(x) = x^2$의 도함수를 구하면:
$f'(x) = \lim_{h \to 0} \frac{(x+h)^2 - x^2}{h} = 2x$
:::
```

### Summary Block
```markdown
::: summary 핵심 요약
1. 미분은 순간변화율을 나타낸다
2. 적분은 미분의 역연산이다
3. 미적분의 기본정리로 연결된다
:::
```

### Warning Callout
```markdown
::: warning 주의사항
이 공식은 **연속함수**에서만 적용 가능합니다.
:::
```

### Flowchart
```markdown
::: flow
(시작) --> 데이터 수집
데이터 수집 --> {유효한가?}
{유효한가?} --> 분석 수행
{유효한가?} --> 데이터 수집
분석 수행 --> (완료)
:::
```

### Timeline
```markdown
::: timeline 산업혁명
1760 | 1차 산업혁명 — **증기기관** 발명
1870 | 2차 산업혁명 — 전기, 대량생산
1969 | 3차 산업혁명 — 컴퓨터, 인터넷
2010 | 4차 산업혁명 — AI, IoT
:::
```

### Mindmap
```markdown
::: mindmap 자료구조
자료구조
  선형
    배열
    연결리스트
    스택
    큐
  비선형
    트리
      이진트리
      B-트리
    그래프
:::
```

### Metadata Example
```markdown
::: concept 미분의 정의 {source: "p.42", tags: "calculus, analysis"}
함수의 순간변화율을 구하는 연산이다.
:::
```
