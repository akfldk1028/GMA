# HANDOFF — GMA v1.0.6+8 (2026-03-25)

## Goal

GMA = PDF 좌표 연동 Markdown 메모 앱 (Flutter). PDF에서 텍스트/영역을 선택하면 스크랩노트 캔버스에 카드로 연동되고, Markdown 노트와 양방향 싱크.

## 이번 세션에서 한 것 (2026-03-25)

### 버그 수정 4건
1. **loadNote 재진입 보호** — `_loadNoteGeneration` 카운터로 빠른 노트 전환 시 이전 호출 abort (`workspace_provider.dart`)
2. **loadPdf microtask 타이밍** — `Future.microtask(() => loadPdf(...))` → `await loadPdf(...)` 직접 호출로 순서 보장
3. **Java PATH (Windows)** — `_resolveJavaPath()` 도입: direct → `where`/`which` → `JAVA_HOME` 순 탐색 + 캐싱 (`pdf_structure_service.dart`, `pdf_to_markdown_service.dart`)
4. **AI 어시스턴트** — placeholder Timer → Ollama `/api/chat` 실제 연동, OCR과 같은 서버 설정 공유 (`ai_chat_provider.dart`)

### 기능 개선 3건
5. **하이라이트 줄별 렌더링** — `PdfMarker.lineRects` + `enumerateFragmentBoundingRects()`로 네모 하나 대신 줄별 rect 렌더링. Hive 하위 호환 유지 (기존 데이터는 textRect 폴백)
6. **캡처 줌/비율 반영** — `PdfRegionImage` crop을 전체 페이지 폭 대신 실제 선택 영역 + 8% 패딩. 캡처 카드 크기를 이미지 비율 기반으로 계산 (`_ensureLayoutFit` + `createMarker` 이미지 크기 읽기)
7. **색상 팔레트 통일** — 드로잉/하이라이트 팔레트 2개 → 1개로 통합. 하드코딩된 `MarkerColor.green`/`yellow` 제거, `highlightModeColorName` 사용

### 인프라
8. **로고 세팅** — `docs/logo/아트보드 41.png`(쓱 심볼) → Windows/Web 아이콘 + 스플래시
9. **버전업** — 1.0.5+7 → 1.0.6+8
10. **빌드** — AAB(`build/app/outputs/bundle/release/app-release.aab`, 59.3MB) + Windows exe

## What Worked

- `_loadNoteGeneration` 카운터 패턴 — 재진입 보호에 효과적
- pdfrx `enumerateFragmentBoundingRects()` — 줄별 rect를 정확하게 반환
- `PdfRectListConverter` — `List<PdfRect>?` Hive JSON 직렬화 + 기존 데이터 하위 호환
- 캡처 이미지에서 `ui.instantiateImageCodec`로 실제 픽셀 크기 읽기 → 정확한 카드 비율
- `_colorValueToMarkerName` 매핑으로 드로잉/하이라이트 색상 동기화

## What Didn't Work

- `BoxFit.contain` → 캡처 카드에 좌우 여백 생김. `BoxFit.fill`로 변경 (카드 비율이 이미지와 동일하므로 왜곡 없음)
- `Future.microtask(() => loadPdf(...))` — syncElementsToBlock이 PDF 로드 전 실행되는 타이밍 문제. 직접 `await`로 해결
- 캡처 카드 크기를 `CanvasElement.width/height`로만 설정 → `_ensureLayoutFit`에서 고정 `cardH`로 덮어씀. 레이아웃 함수도 같이 수정해야 했음
- 하이라이트 색상을 `highlightModeColorName`에서 읽는데, `createMarker` 호출 곳마다 하드코딩 → 전부 찾아서 교체 필요

## 알려진 이슈

- **`reorderAllScraps` CircularDependencyError** — `workspace_provider.dart:1053`에서 `ref.invalidate` 호출 시 순환 의존. 기능에 영향 없으나 콘솔 에러 출력. 수정 필요.
- **기존 캡처 카드 비율 깨짐** — Hive 레이아웃 캐시에 옛 크기(400x300)가 남아있음. 삭제 후 재캡처하면 정상.

## 주요 규칙 (메모리에 기록됨)

- **vendor 우선**: `vendor/opendataloader-pdf`에 기능이 있으면 pdfrx 대신 사용
- **Flutter SDK 경로**: `/d/development/flutter/bin` (bash PATH에 없으므로 export 필요)
- **메모리 경로**: `D:\DevCache\claude-data\projects\D--Data-20-Flutter-02-GMA\memory\`
- **빌드 명령**: `export PATH="/d/development/flutter/bin:$PATH" && cd "D:/Data/20_Flutter/02_GMA/GMA/frontend"`

## Next Steps

1. **`reorderAllScraps` CircularDependencyError 수정** — `ref.invalidate` 순환 의존 해결
2. **Google Play 업로드** — AAB 파일 준비됨 (`build/app/outputs/bundle/release/app-release.aab`)
3. **Android 아이콘 세팅** — `flutter_launcher_icons`에 android 설정 추가 (현재 windows/web만)
4. **기존 캡처 마이그레이션** — Hive에 저장된 옛 레이아웃(400x300) 자동 재계산 로직
5. **AI 어시스턴트 모델 선택** — 현재 `llama3` 하드코딩, Settings에서 모델 선택 UI 추가
6. **AI 어시스턴트 스트리밍** — 현재 `stream: false`, SSE 스트리밍으로 변경하면 UX 개선
