---
name: note_ui_implementation_progress
description: 260316 노트 UI 긴급용 구현 진행 상황 - 완료/버그수정/미구현 전체 기록
type: project
---

# 노트 UI 긴급용 구현 진행 (2026-03-19 업데이트)

브랜치: DK-A
기획안: `docs/260316/노트 UI 긴급용_1~20.png`

## 수정 완료

### 2026-03-19 (ScrapNote 미구현 기능 전체 구현)

- **Phase 1: 스크랩 삭제 UI**
  - `removeScrapElement()` — 마크다운 @el 제거 + ElementStore 삭제 + 어노테이션 클리어 + PNG 파일 삭제
  - `Dismissible` 래핑 (endToStart 스와이프, 빨간 휴지통, 확인 다이얼로그)

- **Phase 2: 어노테이션 Undo/Redo + 도구 선택**
  - `undoStroke()`, `redoStroke()`, `canUndo()`, `canRedo()` + 인메모리 redo 스택
  - 미니 툴바: 색상 5개 (검정/파랑/빨강/초록/주황), 두께 3단계, undo/redo 버튼
  - `_ScrapEntry`에 `strokeColor`/`strokeSize` 전달

- **Phase 3: 스크랩 순서 변경 (드래그)**
  - `noteScrapProvider` 블록 경로: `_sortByPdfPosition()` 제거 → @el 순서 유지
  - `ReorderableListView.builder` (annotate 모드에선 비활성화)
  - `reorderScraps()` — capture/lasso만 필터해서 reorder 후 전체 리스트 재조합

- **Phase 4: 스크랩 보드 팝업 + 빠른 스크랩**
  - `_handleCaptureCompleted`/`_handleLassoCaptureCompleted` 퀵모드 분기
  - Quick mode: 바로 `createMarker()` / Normal mode: `openScrapBoard()`
  - PDF 툴바에 퀵모드 토글 버튼 (bolt 아이콘)
  - `_confirmScrapCreation`에서 절대경로 → basename 변환

- **Phase 5: 레이아웃 컨트롤 (스왑 + 접기)**
  - `_CanvasHeader`에 swap_horiz / chevron_right 버튼 → `swapLayout()` / `toggleLiveScraps()`

- **Critical 버그 수정 (코드 리뷰)**
  - Drawing stroke가 `capture` 타입으로 잘못 저장 → `elementTypeOverride: ElementType.drawing` 추가
  - Hive 마이그레이션: `_migrateDrawingElements()` — `_stroke_` 패턴으로 60개 수정
  - `LiveScrapsPanel` 필터 누락 → capture/lasso만 표시하도록 수정
  - lasso normal 모드에서 타입 소실 → `pendingScrapElementType` 필드 추가
  - `Padding` key와 `Dismissible` key 중복 제거
  - reorder 인덱스 전체 @el vs 필터된 리스트 불일치 수정

- **패널 리디자인: PDF 재렌더링 → 캡처 PNG 카드**
  - `PdfRegionImage` 제거, `PdfPageImageCache`/`PdfViewerController` 의존성 제거
  - 노트북 카드 스타일: 흰색 카드 + 미세 그림자 + 페이지 배지 + 텍스트 블록쿼트
  - 이미지 maxHeight: 200, 텍스트 maxLines: 4

- **캡처 시 드로잉 합성 (WYSIWYG)**
  - `CaptureService.captureArea()` — `drawingStrokes` 파라미터, PDF + StrokePainter 합성
  - `LassoCaptureService.captureArea()` — 동일 합성
  - `CaptureOverlay`/`LassoOverlay` — `noteId` 전달 → 해당 페이지 스트로크 조회

### 2026-03-18 (ScrapNote 리디자인)
- Phase 1~4 (캡처 전용화, 올가미, 어노테이션, 임포트) 완료
- 코드 리뷰 버그 4건 수정

### 이전
- PDF 렌더링 크래시, Bad state 수정
- ScrapNote 패널 방향 확정 (커밋 beda755)

### 2026-03-19 (캔버스 개선 + 사이드바 연동)
- 사이드바 capture/lasso 전용 필터링
- 사이드바 → 캔버스 scrollToElement 연동 (noteScrapProvider 공유)
- 사이드바 캡처 이미지 썸네일 (32px, BoxFit.contain)
- 캔버스 100% 뷰포트 채움 (boundaryMargin: zero)
- 카드 기본 크기 축소 (180x120)
- 카드 리사이즈 핸들 (우하단 드래그, 100~800 x 80~1000)
- 올가미 카드 투명 배경 (border/shadow 제거, 반투명 헤더)
- 이미지 BoxFit.contain (crop 금지)
- zoom 범위 0.3x~3.0x

## 현재 동작하는 것
- ScrapNote 패널: capture/lasso만 표시 (노트북 카드 스타일)
- 캡처/올가미 시 PDF + 필기 합성된 PNG 저장 (WYSIWYG)
- 스크랩 삭제 (스와이프), 순서 변경 (드래그), 어노테이션 undo/redo
- 어노테이션 도구: 색상 5개, 두께 3단계
- 퀵모드 토글, 스크랩 보드 팝업
- 레이아웃 스왑/접기
- PDF 탭 바 (멀티 PDF)
- 멀티 PDF 임포트
- **사이드바 ↔ 캔버스 연동** (클릭 → 스크롤)
- **카드 자유 리사이즈** (드래그 핸들)
- **올가미 투명 배경**

## 미구현 (다음 작업)
- 복수 선택 + 그룹화 (슬라이드 15, 17-19)
- 페이지 관리/드래그 이동 (슬라이드 16, 20)
- 스크랩 편집 모드 (이동/크기/회전) (슬라이드 14)

**Why:** ScrapNote 핵심 UX 전체 구현 완료. 남은 건 고급 편집 기능.
**How to apply:** 실앱 테스트 → 버그 수정 → 고급 기능 순서.
