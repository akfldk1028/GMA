---
name: scrapnote_key_files
description: ScrapNote 시스템 핵심 파일 경로 (파싱, 스토어, UI, 유틸, 올가미, 어노테이션)
type: reference
---

# ScrapNote 핵심 파일 경로

## 파싱 & 렌더링
- `lib/features/gma_md/blocks/scrapnote_block.dart` — `::: scrapnote` 블록 위젯 렌더링
- `lib/features/gma_md/parser/container_block_parser.dart` — `:::` 블록 파서
- `lib/features/gma_md/widgets/element_card.dart` — ElementCard 위젯
- `lib/features/scrapnote/utils/element_ref_parser.dart` — `@el` 파서
- `lib/features/scrapnote/utils/scrapnote_block_editor.dart` — 블록 CRUD 유틸

## 데이터 모델
- `lib/features/scrapnote/models/element_model.dart` — ScrapElement (Freezed), ElementType: highlight/capture/drawing/lasso

## 스토어 & 프로바이더
- `lib/features/scrapnote/providers/element_store.dart` — ElementStore (Hive CRUD)
- `lib/features/scrapnote/providers/note_scrap_provider.dart` — 노트↔패널 브릿지 (capture/lasso 필터)
- `lib/features/scrapnote/providers/scrap_annotation_provider.dart` — 스크랩 어노테이션 (Hive, elementId→strokes)
- `lib/features/scrapnote/services/scrap_insertion_service.dart` — 삽입 확인 플로우

## 올가미 (Lasso)
- `lib/features/pdf_viewer/capture/pages/providers/lasso_provider.dart` — LassoMode (bool 토글)
- `lib/features/pdf_viewer/capture/pages/widgets/lasso_overlay.dart` — 자유곡선 오버레이
- `lib/features/pdf_viewer/capture/utils/lasso_capture_service.dart` — clipPath 마스킹 PNG 생성

## 사각형 캡처
- `lib/features/pdf_viewer/capture/pages/providers/capture_provider.dart` — CaptureMode
- `lib/features/pdf_viewer/capture/pages/widgets/capture_overlay.dart` — 드래그 사각형 오버레이
- `lib/features/pdf_viewer/capture/utils/capture_service.dart` — PDF 영역 렌더 PNG

## Workspace UI
- `lib/features/workspace/pages/widgets/workspace_canvas_panel.dart` — 우측 스크랩 패널 (필터, 어노테이션, 임포트)
- `lib/features/scrapnote/widgets/pdf_region_image.dart` — PDF 크롭 이미지 (캐시, 어노테이션 오버레이)
- `lib/features/workspace/pages/widgets/scrap_board_popup.dart` — 스크랩 확인 팝업

## 핵심 플로우
- `lib/features/workspace/pages/providers/workspace_provider.dart` — createMarker(elementTypeOverride), appendElementToBlock()
- `lib/features/pdf_viewer/pages/screens/pdf_viewer_screen.dart` — 오버레이 통합, 상호배제, 캡처/올가미 핸들러
