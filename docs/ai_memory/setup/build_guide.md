---
name: build_guide
description: GMA 프로젝트 클론부터 빌드/실행까지 한번에 가능한 전체 셋업 가이드
type: reference
---

# GMA (LinkNote) Build Guide

## Prerequisites

- **Flutter**: 3.38.x stable (Dart 3.10.x)
- **Git**
- **Windows 11** (Windows 빌드 타겟)
- **IDE**: PyCharm 또는 VS Code

## 1. Clone

```bash
git clone https://github.com/akfldk1028/GMA.git C:/DK/GMA
cd C:/DK/GMA
git checkout DK-A
```

## 2. Reference repos (참조 코드베이스, 빌드에 필수 아님)

```bash
mkdir -p clone
cd clone
git clone https://github.com/nicehash/pdfrx.git      # PDF 엔진 참조
git clone https://github.com/nicehash/printnotes.git  # Markdown 패턴 참조
cd ..
```

## 3. Flutter Setup

```bash
cd frontend

# 의존성 설치
flutter pub get

# 코드 생성 (freezed, riverpod_generator, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 분석 (에러 0 확인)
flutter analyze --no-fatal-infos --no-fatal-warnings
```

## 4. Build & Run

```bash
# Windows 디버그 실행
flutter run -d windows

# Windows 릴리즈 빌드
flutter build windows --release
```

## 5. 핵심 기술 스택

| 역할 | 패키지 |
|------|--------|
| UI | shadcn_ui ^0.45.1 |
| 상태관리 | flutter_riverpod + riverpod_generator |
| PDF | pdfrx ^2.2.0 |
| 모델 | freezed + json_serializable |
| 로컬저장 | hive_flutter |
| 라우팅 | go_router |
| Markdown | markdown + markdown_widget + flutter_math_fork |

## 6. 프로젝트 구조

```
C:/DK/GMA/
├── frontend/          # Flutter 앱 (메인)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── features/  # Feature-first 구조
│   │   │   ├── workspace/     # 메인 3패널 화면
│   │   │   ├── pdf_viewer/    # PDF + 캡처 + 올가미 + 드로잉
│   │   │   ├── scrapnote/     # ScrapNote 시스템
│   │   │   ├── note_editor/   # Markdown 에디터
│   │   │   └── ...
│   │   ├── common_widgets/
│   │   ├── constants/
│   │   ├── routing/
│   │   └── utils/
│   └── pubspec.yaml
├── clone/             # 참조 코드베이스 (pdfrx, printnotes)
├── docs/              # 기획안, 스크린샷
└── CLAUDE.md          # AI 에이전트 가이드
```

## 7. 주의사항

- `dart run build_runner build` 안 하면 `.g.dart`, `.freezed.dart` 파일 없어서 컴파일 에러
- Hive lock 에러 시: `rm C:/Users/User/Documents/app_settings.lock`
- 앱 2중 실행 시 lock 충돌 — 기존 프로세스 먼저 종료: `taskkill /F /IM gma_frontend.exe`
- 배경 항상 흰색 (라이트 테마)
- PDF는 facing pages 레이아웃 필수

## 8. 현재 브랜치

- **DK-A**: 메인 개발 브랜치
- **master**: PR 타겟 브랜치
