---
name: current_state
description: 현재 구현 완료된 기능과 활성 작업 상태 (2026-03-19 기준)
type: project
---

# 현재 상태 (2026-03-19)

## 완료된 핵심 기능

### Workspace (3패널 레이아웃)
- 좌: ScrapThumbnailsSidebar (140px, capture/lasso 전용, 캡처 이미지 썸네일)
- 중: PDF Viewer (pdfrx, facing pages)
- 우: WorkspaceCanvasPanel (draw.io 스타일 캔버스)
- 레이아웃 swap (PDF↔ScrapNote 위치 교환)
- 사이드바 클릭 → 캔버스 해당 카드로 스크롤 연동 (scrollToElement)

### PDF Viewer
- pdfrx 기반, facing pages 레이아웃
- 텍스트 선택 → 스크랩 생성
- 영역 캡처 (사각형) + 올가미 캡처 (자유형, clipPath 마스킹 → 투명 PNG)
- 드로잉/필기 레이어
- 캡처 시 PDF + 필기 합성 (WYSIWYG)

### ScrapNote 캔버스 (WorkspaceCanvasPanel)
- InteractiveViewer: zoom 0.3x~3.0x, pan (일반 모드)
- 카드 자유 배치 + 드래그 이동
- 카드 리사이즈 (우하단 핸들, 100~800px x 80~1000px)
- 올가미 카드 투명 배경 (흰색 박스 없음, 반투명 헤더)
- 캔버스 100% 뷰포트 채움 (boundaryMargin: zero)
- **캔버스 위 필기 (annotate 모드)**:
  - Transform + GestureDetector 분리 (InteractiveViewer 없이)
  - 화면좌표 → 캔버스좌표 변환 (Matrix4 inverse + Vector4)
  - ClipRect으로 오버플로우 방지
  - 색상 5개, 두께 3단계, undo
- 스크랩 임포트 (다른 노트에서)
- 이미지 BoxFit.contain (crop 금지)

### 사이드바 ↔ 캔버스 실시간 동기화
- 캔버스 카드 드래그 → Listener.onPointerUp → y/x 정렬 → onOrderChanged 콜백
- 사이드바가 canvasOrder로 즉시 재정렬 (마크다운 async 경로 우회)
- 마크다운 저장은 reorderAllScraps로 백그라운드 처리
- 사이드바 클릭 → 캔버스 scrollToElement

### ScrapNote 데이터
- 4가지 ElementType: highlight, capture, drawing, lasso
- 마크다운 `::: scrapnote` 블록 = source of truth
- `@el[elementId]` 참조 → Hive에 Element 데이터 저장

## 핵심 파일 (수정 빈도 높음)
- `workspace_canvas_panel.dart` — 캔버스 + 카드 + annotate + resize
- `scrap_thumbnails_sidebar.dart` — 좌측 사이드바 (필터링 + 연동)
- `workspace_screen.dart` — 3패널 레이아웃 조합
- `workspace_provider.dart` — 상태 관리 (PDF/노트/스크랩)

## 알려진 이슈
- Hive lock 파일 충돌 (앱 2중 실행 시) → `rm app_settings.lock`
- annotate 모드에서 pan/zoom 불가 (현재 의도된 동작)

**Why:** 다른 컴퓨터에서 작업 재개 시 현재 진행 상황 파악용
**How to apply:** 새 기능 추가 전에 이 상태 확인, 기존 기능 깨지지 않게 주의
