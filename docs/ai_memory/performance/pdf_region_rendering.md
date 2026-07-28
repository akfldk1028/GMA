---
name: pdf_region_rendering_optimization
description: ScrapNote 패널 PDF 영역 렌더링 최적화 - viewport culling, 캐시, 알고리즘
type: project
---

# PDF Region Rendering 최적화

## 문제
- `WorkspaceCanvasPanel`이 `SingleChildScrollView` + `Column` 사용
- 스크랩 40개면 40개 전부 동시 빌드 → 로딩 스피너 폭탄
- `PdfPageImageCache`가 페이지당 캐싱하지만, 모든 위젯이 동시 요청

## 적용한 해결책 (2026-03-17)

### 1. Viewport Culling (적용 완료)
- `SingleChildScrollView` + `Column` → `ListView.builder` 교체
- `cacheExtent: 200` — 뷰포트 위아래 200px만 미리 빌드
- flat list 모델 (`_CanvasItem`) 으로 divider/spacer/entry 통합
- 파일: `workspace_canvas_panel.dart`

### 2. PdfPageImageCache (기존 유지)
- 페이지당 1회 렌더, 같은 페이지 스크랩들은 캐시 공유
- `renderScale: 2.0`으로 고해상도
- 파일: `scrapnote/widgets/pdf_region_image.dart`

## 미적용 (추후 필요시)

### Tile-Based Rendering
- 페이지를 256x256 타일로 분할, 뷰포트 교차 타일만 렌더
- PDF.js, MuPDF가 사용하는 방식
- 현재 스크랩 수 기준으로는 과도함

### Priority Queue + Prefetch
- 스크롤 방향으로 1~2개 프리페치, 반대 방향 evict
- `VisibilityDetector` 패키지로 가시성 판단
- 스크랩 100개+ 넘어가면 고려

### LRU Cache Eviction
- 현재 `PdfPageImageCache`는 evict 없음 (전부 메모리 보유)
- 페이지 50+ PDF에서 메모리 이슈 가능 → LRU 추가 필요

**Why:** 스크랩 수십 개일 때 초기 로딩 성능이 사용 경험 직결
**How to apply:** 성능 이슈 재발 시 Tile-Based 또는 Priority Queue 단계적 적용
