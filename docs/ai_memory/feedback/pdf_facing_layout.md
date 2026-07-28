---
name: pdf_facing_layout
description: PDF 뷰어는 반드시 facing pages 레이아웃 사용 (1페이지 단독, 2-3, 4-5 쌍)
type: feedback
---

PDF 뷰어는 facing pages 레이아웃으로 표시해야 한다.
- 1페이지: 단독 (표지)
- 2-3페이지: 나란히
- 4-5페이지: 나란히
- 이하 동일

**Why:** 유저가 책/논문처럼 2페이지씩 펼쳐서 보길 원함. 단일 페이지 스크롤 불가.
**How to apply:** `PdfViewerParams.layoutPages`에 `_facingPagesLayout` 연결. `layoutPages: null`로 비활성화 금지.
