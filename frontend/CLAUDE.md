# GMA Frontend — Flutter 개발 가이드

## 빌드 명령어

```bash
# Flutter SDK가 PATH에 없으면:
export PATH="/d/development/flutter/bin:$PATH"
cd "D:/Data/20_Flutter/02_GMA/GMA/frontend"

flutter run -d windows          # 실행
flutter analyze --no-fatal-infos --no-fatal-warnings  # 린트
flutter test                    # 테스트
dart run build_runner build --delete-conflicting-outputs  # Freezed/Riverpod 코드 생성
```

## 구조 (Feature-First)

```
lib/
├── main.dart              # ProviderScope + Hive 초기화 (8 box 미리 open)
├── app.dart               # ShadApp.router + 테마
├── routing/               # GoRouter (/, /workspace, /note/:id, /settings)
├── constants/             # app_colors, app_theme, marker_colors
├── utils/                 # file_system_provider, frontmatter_parser, note_storage_service
├── common_widgets/        # app_shell, responsive, color_dot 등
└── features/              # 17개 feature 모듈
    ├── workspace/         # ⭐ 메인 3패널 (사이드바+PDF+스크랩노트)
    ├── pdf_viewer/        # ⭐ pdfrx 래퍼, 하이라이트/캡처/올가미
    ├── scrapnote/         # ⭐ 캔버스 (카드 배치, 드래그/리사이즈, 드로잉)
    ├── note_editor/       # Markdown 에디터 (Wiki-link, LaTeX)
    ├── gma_md/            # ::: 커스텀 블록 12종 + 파서
    ├── home/              # 폴더/노트 관리, 검색, 휴지통
    ├── file_manager/      # 파일 트리
    ├── ai_agent/          # Ollama 백엔드, 7 스킬
    ├── pdf_structure/     # opendataloader-pdf 연동
    └── (기타: ocr, settings, splash, auth, profile 등)
```

## Feature 내부 패턴

```
features/{name}/
├── models/          # @freezed 데이터 모델
├── pages/
│   ├── providers/   # @riverpod 상태관리
│   ├── screens/     # ConsumerWidget 화면
│   └── widgets/     # feature 전용 위젯
├── queries/         # GET (비동기 Provider)
└── mutations/       # POST/PUT/DELETE
```

## 명명 규칙

| 타입 | 패턴 | 예시 |
|------|------|------|
| Screen | `*_screen.dart` | `workspace_screen.dart` |
| Provider | `*_provider.dart` | `workspace_provider.dart` |
| Query | `*_query.dart` | `get_me_query.dart` |
| Mutation | `*_mutation.dart` | `login_mutation.dart` |
| Model | `*_model.dart` | `pdf_marker_model.dart` |

## Gotchas (치명적)

### pdfrx + ShadApp 충돌
pdfrx가 `DefaultSelectionStyle.of(context).selectionColor!`를 호출 — ShadApp은 이 값을 안 줌.
`app.dart`의 ThemeData에 반드시 `textSelectionTheme: TextSelectionThemeData(selectionColor: ...)` 포함.
증상: 1페이지만 보이고 나머지 안 보임 → Hive 문제로 오인하기 쉬움.

### workspace_provider.dart (~1270줄)
God Object. 수정 시 영향 범위 넓음. state 변경 흐름을 반드시 전체 trace.

### Freezed/Riverpod 코드 생성
모델이나 provider 수정 후 `dart run build_runner build --delete-conflicting-outputs` 필수.
안 돌리면 `.g.dart` 파일 불일치로 컴파일 에러.

## 핵심 기술 스택

| 역할 | 패키지 |
|------|--------|
| UI | shadcn_ui |
| 상태관리 | flutter_riverpod + riverpod_generator |
| 라우팅 | go_router |
| PDF | pdfrx |
| 로컬저장 | hive_flutter |
| 모델 | freezed + json_serializable |
| Markdown | markdown + markdown_widget + flutter_math_fork |
| 드로잉 | perfect_freehand |
