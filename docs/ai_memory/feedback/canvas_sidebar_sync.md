---
name: canvas_sidebar_sync
description: 캔버스↔사이드바 순서 동기화 — 마크다운 경로 대신 직접 콜백으로 즉시 반영
type: feedback
---

캔버스에서 카드 드래그 시 사이드바 순서가 즉시 동기화되어야 함.

마크다운(noteScrapProvider) 경로는 async 지연 문제 있음 → 직접 콜백 방식 사용.

구현 패턴:
1. WorkspaceCanvasPanel.onOrderChanged 콜백으로 정렬된 ID 리스트 전달
2. WorkspaceScreen에서 setState로 _canvasOrder 저장
3. ScrapThumbnailsSidebar.canvasOrder로 elements 재정렬
4. 마크다운 저장은 reorderAllScraps로 백그라운드 처리

정렬 기준: y축 먼저 → 같은 y면 x축 (위→아래, 왼→오른)
Listener.onPointerUp으로 드래그 종료 감지 (GestureDetector.onPanEnd는 InteractiveViewer와 충돌)

**Why:** noteStateProvider가 async라서 invalidate → rebuild 사이에 지연 발생. 마크다운 경로로는 실시간 동기화 불가능.
**How to apply:** 캔버스↔사이드바 순서 연동 수정 시 반드시 콜백 방식 유지. 마크다운 경로 의존 금지.
