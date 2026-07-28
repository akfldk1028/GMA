# HANDOFF — GMA v1.0.10 (2026-03-31 오후)

## 이번 세션 요약

P0 2건 + P1 일부 + 버그 수정 2건.

## 수정 파일 (7개)

```
scrap_thumbnails_sidebar.dart    — 항목별 X 삭제 버튼 + 확인 다이얼로그 추가
workspace_canvas_panel.dart      — eraser: panEnd에서 stroke+카드 히트테스트 삭제, live stroke eraser 표시
workspace_provider.dart          — [WP.*] 디버그 로그 7줄 제거, createMarker에 try-catch 복원
                                   CanvasElement 생성만 MarkerCreationService로 분리 (fire-and-forget)
marker_creation_service.dart     — 신규. persistToHive + createCanvasElement (PdfRect 비율, 이미지 디코딩 제거)
tool_registry.dart               — HighlighterTool 제거 (펜+지우개만)
scrapnote_block_editor.dart      — hasBlock: findBlocks().isNotEmpty로 수정 (regex multiLine 버그)
note_scrap_provider.dart         — (디버그 로그 추가/제거만, 최종 변경 없음)
```

## 핵심 버그 수정: hasBlock regex

`ScrapnoteBlockEditor.hasBlock`가 `_blockStartRegex.hasMatch(content)`로 전체 문자열에 대해 `^` 매칭.
multiLine 없이는 content 첫줄만 체크 → frontmatter/제목이 있는 노트에서 `::: scrapnote` 못 찾음.
→ `noteScrapProvider`가 항상 빈 리스트 → **캡처/라쏘 후 스크랩 안 보이는 근본 원인**.

수정: `hasBlock` → `findBlocks(content).isNotEmpty` (줄별 파싱과 동일한 로직).

## 주의사항 (이전 세션에서 유지)

- **PdfMarker ID 통일**: workspace UUID를 pdfMarkerState.createMarker(id:)로 전달 필수
- **loadPdf generation 체크**: 각 await 후 `_loadNoteGeneration != gen` 확인
- **Hive box**: main.dart에서 8개 전부 미리 open. lazy open 금지
- **createMarker 순서**: @el→elementStore.add (순서 바뀌면 noteScrapProvider가 @el 못 찾음)
- **리팩토링 주의**: state 변경/invalidate는 반드시 provider 내부에서. static 메서드에 Ref 전달 시 invalidate 동작 다를 수 있음.

## P1 미완료 (다음 세션)

- workspace_provider 1300줄 God Object 분리 (UI토글/마커CRUD/세션관리)
- scrapnote 블록 중복 생성 문제 (CreateNoteMutation 노트 → ensureBlock 2회)
- 테스트 노트 40+개 정리

## 빌드

```bash
cd "D:/Data/20_Flutter/02_GMA/GMA/frontend"
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter run -d windows
```
