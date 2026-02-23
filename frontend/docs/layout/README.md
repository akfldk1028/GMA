# GMA Layout Architecture

> **유지보수 핵심 문서** — 레이아웃 변경 시 반드시 이 문서를 먼저 읽을 것.

## 전체 구조 요약

```
┌──────────────────────────────────────────────────────┐
│ WorkspaceHeaderV2 (48px)           [menu][title][ed] │
├──────────────────────────────────────────────────────┤
│ DrawingToolbar (노트 로드 시만 표시)                    │
├────┬─────────────────────────────────────────────────┤
│ M  │                                                 │
│ A  │    PdfViewer (2-page facing layout)             │
│ R  │    ┌─────────┬─────────┐                        │
│ K  │    │  Page 1 │  Page 2 │                        │
│ E  │    │         │         │                        │
│ R  │    └─────────┴─────────┘                        │
│ S  │                                                 │
│72px│                                                 │
└────┴─────────────────────────────────────────────────┘

Overlays (Stack 위에 조건부 렌더링):
  ┌─ FileBrowserDrawer (왼쪽 슬라이드인, 300px)
  ├─ NoteEditorModal   (중앙 모달, 85%×90%)
  └─ MarkerEditModal   (중앙 다이얼로그, 420px)
```

## 아키텍처 원칙

1. **PDF-First**: PDF 뷰어가 항상 전체 화면을 차지
2. **Stack 기반 오버레이**: 모달/드로어는 Stack 자식으로 조건부 렌더링
3. **상태 중심 UI**: `WorkspaceState`의 bool 플래그가 모달 열림/닫힘 제어
4. **단방향 데이터 흐름**: WorkspaceProvider → WorkspaceState → UI rebuild

## 파일 인덱스

| 문서 | 내용 |
|------|------|
| [01-workspace-screen.md](./01-workspace-screen.md) | 메인 화면 조합 (Stack + Column + Row) |
| [02-header.md](./02-header.md) | 상단 헤더 (WorkspaceHeaderV2) |
| [03-pdf-viewer.md](./03-pdf-viewer.md) | PDF 뷰어 + 2쪽 보기 + 오버레이 |
| [04-marker-strip.md](./04-marker-strip.md) | 좌측 마커 필 스트립 |
| [05-modals.md](./05-modals.md) | 모달/드로어 (에디터, 마커, 파일브라우저) |
| [06-state.md](./06-state.md) | WorkspaceState + Provider 상태 관리 |
| [07-drawing.md](./07-drawing.md) | 드로잉 시스템 (펜/형광펜/지우개) |
| [08-note-editor.md](./08-note-editor.md) | 마크다운 에디터 내부 구조 |

## OCR 통합

캡처 완료 시 네이티브 텍스트 추출이 실패하면 (이미지 기반 PDF), OCR 활성화 상태에서
자동으로 로컬 Ollama LLaVA를 통해 텍스트 추출을 시도한다.

- **설정:** Settings > OCR (Local LLM) — 활성화/URL/모델명
- **코드:** `features/ocr/` (플러그인 패턴, 새 백엔드 추가 = 1파일 + 레지스트리 1줄)
- **통합:** `_handleCaptureCompleted()` in `pdf_viewer_screen.dart`
