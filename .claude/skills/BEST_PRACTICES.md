# Claude Skills Best Practices

> 공식 문서, GitHub, 커뮤니티에서 수집한 최적의 Skills 작성 가이드

---

## 핵심 원칙 (Official)

### 1. Context is Currency
- **Context window는 공유 자원**: 시스템 프롬프트, 대화 기록, 다른 Skills가 함께 사용
- **Claude는 이미 똑똑함**: 과도한 설명 불필요
- Claude가 모르는 정보만 추가
- 장황한 설명보다 간결한 예시 선호

### 2. Progressive Disclosure (3단계 로딩)

| 단계 | 내용 | 로딩 시점 | 권장 크기 |
|------|------|----------|----------|
| **1. Metadata** | name + description | 항상 | ~100 단어 |
| **2. SKILL.md** | 본문 지침 | 스킬 트리거 시 | <500줄 / <5000단어 |
| **3. Resources** | references/, scripts/ | 필요할 때 | 무제한 |

### 3. Description이 트리거 메커니즘

```yaml
# 나쁜 예
description: 빌드 스킬

# 좋은 예
description: "Flutter 빌드 자동화. 의존성 설치, 코드 생성(Freezed/Riverpod), 앱 빌드.
사용 시점: (1) 코드 변경 후 빌드, (2) Freezed 모델 수정 후, (3) 새 의존성 추가 후"
```

---

## SKILL.md 구조 (Official Template)

```markdown
---
name: skill-name
description: |
  무엇을 하는지 + 언제 사용하는지 상세히 작성.
  이 description이 Claude가 스킬을 선택하는 기준이 됨.
---

# Skill Name

[1-2문장 요약]

## When to Use
- 사용해야 하는 상황 1
- 사용해야 하는 상황 2

## When NOT to Use
- 사용하지 말아야 하는 상황
- 다른 스킬이 더 적합한 경우

## Quick Start
[가장 일반적인 사용 예시 1개]

## Usage
\`\`\`
/skill-name [arguments]
\`\`\`

## Process
### Step 1: [단계명]
[간결한 지침]

## Related Skills
- `/other-skill` - 관련 작업
```

---

## 폴더 구조 (Official)

```
skill-name/
├── SKILL.md              # 필수: 핵심 지침만 (<500줄)
├── scripts/              # 선택: 실행 가능한 스크립트
│   └── run.py            # 반복적/오류가 발생하기 쉬운 작업
├── references/           # 선택: 상세 문서 (필요시 로드)
│   ├── api-docs.md       # API 문서
│   └── troubleshooting.md # 문제 해결
└── assets/               # 선택: 출력에 사용되는 파일
    └── template.html     # 템플릿 파일
```

---

## Frontmatter 옵션 (Complete Reference)

```yaml
---
# 필수
name: skill-name                    # 슬래시 명령어 이름 (소문자, 하이픈)
description: |                      # 트리거 기준 (상세히!)
  무엇을 하는지, 언제 사용하는지

# 선택 - 호출 제어
disable-model-invocation: true      # Claude 자동 호출 방지 (deploy 등)
user-invocable: false               # /메뉴에서 숨김 (백그라운드 지식)

# 선택 - 실행 환경
allowed-tools: Read, Grep, Bash     # 사용 가능한 도구 제한
context: fork                       # 서브에이전트에서 실행
agent: Explore                      # 서브에이전트 타입

# 선택 - 인수 힌트
argument-hint: "[issue-number]"     # 자동완성 힌트
---
```

---

## 작성 스타일 가이드

### DO (해야 할 것)

1. **명령형/동사원형 사용**
2. **When to Use / When NOT to Use 포함**
3. **간결한 예시 우선**
4. **상세 내용은 references/로**

### DON'T (하지 말 것)

1. **과도한 설명** → 간결하게
2. **중복 정보** → SKILL.md에 요약, references/에 상세
3. **깊은 중첩** → references/ 한 단계만

---

*Sources: code.claude.com/docs, github.com/anthropics/skills, github.com/travisvn/awesome-claude-skills*
