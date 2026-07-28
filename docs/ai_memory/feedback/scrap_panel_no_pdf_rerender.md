---
name: scrap_panel_no_pdf_rerender
description: 스크랩 패널에서 PDF 재렌더링 금지 — 저장된 캡처 PNG만 표시
type: feedback
---

오른쪽 스크랩 패널은 PdfRegionImage(PDF 재렌더링) 대신 저장된 캡처 PNG 파일을 Image.file()로 표시해야 한다.

**Why:** PDF 재렌더링은 전체 페이지가 다시 보여서 스크랩 의미가 없고, PdfViewerController 의존성도 불필요하게 추가됨.
**How to apply:** `_ScrapEntry`에서 `PdfRegionImage` 사용 금지. `_resolvedImagePath`로 PNG 파일 경로 확인 → `Image.file()` 사용.
