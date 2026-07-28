---
name: scrap_panel_direction
description: ScrapNote 패널은 캡처/올가미만 표시, 하이라이트/드로잉 제외, 패널 위 필기 가능
type: feedback
---

# ScrapNote 패널 방향 (2026-03-18 업데이트)

1. 오른쪽 패널에는 **사각형 캡처 + 올가미만** 표시 (highlight/drawing 제외)
2. PDF 크롭 이미지 필수 — 텍스트만 보여주면 안 됨
3. **페이지별 그룹 X** → 시간순(생성순) flat 리스트
4. 오른쪽은 **캔버스** — 각 스크랩 위에 필기(어노테이션) 가능
5. 다른 PDF에서 스크랩 **임포트** 가능해야 함
6. 펜/하이라이트는 PDF 위에서만 동작, 패널에 나타나면 안 됨

**Why:** 유저가 "PDF 필기(펜/하이라이트)는 오른쪽 패널에 안 나오고, 사각형 캡처/올가미만 차례대로 나와야 함"이라고 명시함.
**How to apply:** `noteScrapProvider`와 `_applyFilter`에서 capture/lasso만 통과. `elementTypeOverride`로 lasso 타입 구분.
