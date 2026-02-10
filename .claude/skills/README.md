# GMA Claude Skills & Auto-Claude Guide

> GMA 프로젝트 전용 Skills 가이드. PDF 좌표 연동 Markdown 메모 앱 (Flutter).

**반드시 먼저 읽기**: [BEST_PRACTICES.md](BEST_PRACTICES.md) - 공식 문서 기반 최적 작성법

---

## 1. 프로젝트 개요

**GMA** = PDF 좌표 연동 Markdown 메모 앱

| 항목 | 값 |
|------|-----|
| **프레임워크** | Flutter (Feature-First) |
| **UI** | ShadCN UI |
| **상태관리** | Riverpod + Riverpod Generator |
| **PDF** | pdfrx |
| **로컬저장** | Hive |
| **Markdown** | markdown + flutter_math_fork |
| **모델** | Freezed |

### 프로젝트 경로

| 항목 | 경로 |
|------|------|
| Flutter 앱 | `C:\DK\GMA\frontend` |
| Auto-Claude 엔진 | `C:\DK\GMA\clone\AC247\Auto-Claude` |
| 참조: pdfrx | `C:\DK\GMA\clone\pdfrx` |
| 참조: printnotes | `C:\DK\GMA\clone\printnotes` |
| 설계 문서 | `C:\DK\GMA\docs\PROJECT_DESIGN.md` |

---

## 2. Skills 목록

### GMA 전용 Skills (4개)

| 이름 | 명령어 | 용도 |
|------|--------|------|
| gma-build | `/gma-build [target]` | Flutter 빌드 자동화 |
| gma-test | `/gma-test [scope]` | 테스트 실행/분석 |
| gma-feature | `/gma-feature "설명"` | Feature-First 기능 개발 |
| gma-auto-task | `/gma-auto-task "설명"` | Auto-Claude task 생성/빌드 |

### AC247 공통 Skills (3개)

| 이름 | 명령어 | 용도 |
|------|--------|------|
| ac-debug | `/ac-debug [증상]` | 파이프라인 디버깅 |
| ac-explore | (자동) | 코드베이스 탐색 (백그라운드) |
| ac-pipeline-test | `/ac-pipeline-test` | E2E 파이프라인 테스트 |

---

## 3. 빠른 시작

### 새 기능 개발
```bash
/gma-feature "PDF 북마크 관리"
```

### 빌드
```bash
/gma-build code    # 코드 생성만 (Freezed/Riverpod)
/gma-build all     # 전체 빌드
```

### 테스트
```bash
/gma-test all           # 전체 테스트
/gma-test pdf_viewer    # 특정 feature
```

### Auto-Claude 자동 빌드
```bash
/gma-auto-task "Add PDF annotation support"
```

---

## 4. Auto-Claude 연동

### Daemon 실행 (24/7 자동 빌드)

```bash
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\backend
PYTHONUTF8=1 USE_CLAUDE_MD=true .venv/Scripts/python.exe runners/daemon_runner.py \
  --project-dir "C:\DK\GMA\frontend" \
  --status-file "C:\DK\GMA\frontend\.auto-claude\daemon_status.json"
```

### 단일 Task 실행

```bash
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\backend
PYTHONUTF8=1 USE_CLAUDE_MD=true .venv/Scripts/python.exe run.py \
  --spec <spec-id> \
  --project-dir "C:\DK\GMA\frontend" \
  --auto-continue --force
```

### Windows 필수 환경변수

| 변수 | 값 | 이유 |
|------|-----|------|
| `PYTHONUTF8` | `1` | Windows UTF-8 인코딩 |
| `USE_CLAUDE_MD` | `true` | 에이전트가 CLAUDE.md 읽게 함 |

---

## 5. 디렉토리 구조

```
C:\DK\GMA\.claude\skills\
├── README.md                     # 이 파일
├── BEST_PRACTICES.md             # 스킬 작성 가이드
├── gma-build/                    # 빌드 자동화
│   ├── SKILL.md
│   ├── scripts/build.ps1
│   └── references/troubleshooting.md
├── gma-test/                     # 테스트 실행
│   ├── SKILL.md
│   └── scripts/test.ps1
├── gma-feature/                  # Feature 개발
│   ├── SKILL.md
│   ├── scripts/invoke_autoclaude.py
│   └── references/feature_templates.md
├── gma-auto-task/                # Auto-Claude task
│   ├── SKILL.md
│   ├── scripts/create-task.sh
│   └── references/status-sync.md
├── ac-debug/                     # 파이프라인 디버깅
│   ├── SKILL.md
│   └── references/known-bugs.md
├── ac-explore/                   # 코드베이스 탐색
│   └── SKILL.md
└── ac-pipeline-test/             # E2E 테스트
    └── SKILL.md
```

---

## 6. 시행착오 교훈 (중요!)

GMA에서 Auto-Claude를 처음 돌릴 때 발견한 핵심 교훈:

1. **`USE_CLAUDE_MD=true` 필수** — 없으면 에이전트가 참조 레포 경로 모름
2. **`PYTHONUTF8=1` 필수** — Windows에서 한글 깨짐 방지
3. **Rate limit 주의** — 3 concurrent 돌리다 rate limit 걸리면 빈 세션 무한루프
4. **Daemon task 큐잉** — status가 `queue`/`backlog`여야 pickup됨
5. **Spec rename 후 sync** — stale path가 가장 흔한 실패 원인

자세한 버그 패턴: `ac-debug/references/known-bugs.md`

---

*이 문서는 GMA 프로젝트 전용입니다. S3 스킬은 `C:\DK\S3\.claude\skills\`에 있습니다.*
