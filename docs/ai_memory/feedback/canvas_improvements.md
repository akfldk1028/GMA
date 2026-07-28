---
name: canvas_improvements
description: 캔버스 UI 개선 피드백 - 100% 채우기, 카드 크기 조절, 올가미 투명, 사이드바 연동
type: feedback
---

캔버스는 반드시 뷰포트 100% 채워야 함 (빈 공간/분홍색 배경 금지).
스크랩 카드는 기본 작게, 사용자가 드래그로 리사이즈 가능해야 함.
올가미 캡처 카드는 배경 투명해야 함 (흰색 박스 X).
사이드바 클릭 → 캔버스 해당 카드로 스크롤 연동 필수.
이미지는 BoxFit.contain (crop 금지).

**Why:** 사용자가 반복 수정 요청함. 캔버스 밖 분홍색, 이미지 crop, 카드 크기 고정 모두 UX 문제.
**How to apply:** WorkspaceCanvasPanel, ScrapThumbnailsSidebar 수정 시 항상 확인.
