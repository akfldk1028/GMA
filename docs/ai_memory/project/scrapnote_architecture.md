---
name: scrapnote_architecture
description: ScrapNote 아키텍처 — 마크다운 source of truth + Hive 스토어 + 4가지 ElementType
type: project
---

# ScrapNote 아키텍처 (2026-03-18 업데이트)

## 연결 완료 (기존 "두 시스템 분리" 문제 해결)

마크다운이 source of truth:
1. 캡처/올가미 → ScrapElement 생성 (Hive `element_store`)
2. `::: scrapnote` 블록에 `@el elementId` 자동 삽입 (ScrapnoteBlockEditor)
3. `noteScrapProvider`가 블록 파싱 → 패널 표시 (capture/lasso만)
4. `syncElementsToBlock()` 자동 백필 (Hive→마크다운)

## ElementType 체계
| Type | 설명 | 패널 표시 | 생성 경로 |
|------|------|-----------|----------|
| highlight | PDF 텍스트 선택 | X | Add Marker 버튼 |
| capture | 사각형 영역 캡처 | O | Capture 버튼 (crop 아이콘) |
| drawing | 펜/하이라이트 필기 | X | 드로잉 모드 |
| lasso | 자유곡선 영역 캡처 | O | Lasso 버튼 (gesture 아이콘) |

## 상호배제 (Mutual Exclusion)
- Drawing ON → Capture OFF, Lasso OFF
- Capture ON → Lasso OFF
- Lasso ON → Capture OFF, Drawing OFF
- `ref.listen()` 3개로 구현

## 어노테이션 (Phase 3)
- `scrap_annotation_provider.dart` (Hive `scrap_annotations` box)
- elementId → List<DrawingStroke> 매핑
- 패널 Annotate 모드 토글 → 스크랩 위 필기

## 멀티 PDF 임포트 (Phase 4)
- `appendElementToBlock()` → 다른 PDF의 스크랩을 현재 노트에 추가
- Cross-PDF 렌더링: PdfPageImageCache 실패 시 capturePath PNG 직접 표시

**Why:** 마크다운↔Hive 연결 완료로 파일만으로 복원 가능. 패널은 캡처 전용으로 정리됨.
**How to apply:** 새 ElementType 추가 시 모든 switch문에 case 추가 필수. createMarker의 elementTypeOverride 활용.
