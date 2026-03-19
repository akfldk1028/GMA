---
name: capture_includes_drawings
description: 캡처/올가미 시 PDF 위 필기(드로잉)도 반드시 포함해서 PNG 저장 (WYSIWYG)
type: feedback
---

캡처/올가미는 PDF 원본만이 아니라 사용자가 그 위에 그린 필기(스트로크)도 합성해서 캡처해야 한다.

**Why:** 메모 앱이므로 "보이는 그대로" 캡처되어야 함. PDF만 캡처하면 필기가 빠져서 의미가 없다.
**How to apply:** `CaptureService`/`LassoCaptureService`에 `drawingStrokes` 전달 필수. 캡처 관련 코드 수정 시 스트로크 합성 로직 유지 확인.
