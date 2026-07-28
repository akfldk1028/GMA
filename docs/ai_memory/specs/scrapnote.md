---
name: scrapnote_implementation
description: ScrapNote 시스템 구현 현황 — Task 022~037 완료 + 리디자인 4 Phase 완료
type: project
---

# ScrapNote 구현 상세

## 개념
- 여러 PDF에서 수집한 캡처/올가미를 하나의 노트로 모으는 gma_md 블록
- Element = 독립 엔티티, N:M으로 여러 ScrapNote에 소속 가능
- PDF 고유 ID 기반 → 파일명 변경돼도 링크 안 깨짐

## 문법
```markdown
::: scrapnote 통계정리
@el e001   <!-- PDF1:P3 캡처 -->
@el e002   <!-- PDF1:P5 올가미 -->
@el e003   <!-- PDF2:P12 캡처 -->
:::
```

## 기반 구현 완료 (Task 022~037, master merged)
- PDF Registry, Element Model, :::scrapnote 파싱
- ElementStore (Hive CRUD), PdfRegistry Provider
- Element 생성 Flow, navigateToElement()
- Element Navigator 사이드바

## 리디자인 완료 (2026-03-18, DK-A 브랜치)

### Phase 1: 캡처 전용 패널
- highlight/drawing 패널에서 제외
- "Add Scrap" 텍스트 버튼 삭제

### Phase 2: 올가미(Lasso) 툴
- `ElementType.lasso` 추가
- 자유곡선 선택 → clipPath 마스킹 → 투명 PNG
- 3px 다운샘플링, 확인/취소 UI

### Phase 3: 패널 캔버스화
- 각 스크랩 위 어노테이션 (Hive 저장)
- Annotate 모드 토글

### Phase 4: 멀티 PDF 임포트
- 다른 PDF 스크랩 선택 → 현재 노트에 추가
- Cross-PDF 렌더링 폴백

## Hive Boxes
| Box | 용도 |
|-----|------|
| `element_store` | ScrapElement JSON |
| `scrap_annotations` | 어노테이션 strokes JSON |
| `pdf_registry` | PDF ID↔경로 매핑 |
| `scrapnote_pages` | ScrapNote 페이지 (레거시) |

## 미구현
- 어노테이션 undo/redo, 도구 선택
- 스크랩 삭제/순서 변경 UI
- N:M 관계 관리 UI
