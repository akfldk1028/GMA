# 01. WorkspaceScreen — 메인 화면 조합

## 파일 위치
```
lib/features/workspace/pages/screens/workspace_screen.dart
```

## 역할
모든 레이아웃 컴포넌트를 **Stack** 안에서 조합하는 최상위 화면.
라우터에서 `/workspace` 경로로 진입.

## 위젯 트리 구조
```
Focus (키보드 단축키)
└── Scaffold
    └── Stack
        ├── Column (Base Layer)
        │   ├── WorkspaceHeaderV2          → 02-header.md
        │   ├── DrawingToolbar (조건부)     → 07-drawing.md
        │   └── Expanded
        │       └── Row
        │           ├── MarkerPillsStrip   → 04-marker-strip.md
        │           └── Expanded
        │               └── PdfViewerScreen → 03-pdf-viewer.md
        │
        ├── FileBrowserDrawer (조건부)      → 05-modals.md
        ├── NoteEditorModal (조건부)        → 05-modals.md
        └── MarkerEditModal (조건부)        → 05-modals.md
```

## 핵심 로직

### 키보드 단축키 (Focus.onKeyEvent)
| 단축키 | 동작 |
|--------|------|
| `Esc` | 열린 모달/드로어 순서대로 닫기 (마커모달 → 에디터 → 파일브라우저) |
| `Ctrl+E` | 에디터 모달 토글 |
| `Ctrl+B` | 파일 브라우저 토글 |

### 콜백 흐름
```
PDF 텍스트 선택 → _handleAddMarkerPressed → openMarkerEditModal()
마커 필 탭       → _handleMarkerPillTap    → pdfController.goToPage()
마커 필 롱프레스  → _handleMarkerPillLongPress → openEditorModal()
에디터 마커 클릭  → _handleMarkerClick      → pdfController.goToRectInsidePage()
```

### PdfViewerController
- `_pdfController`: PDF 프로그래밍 방식 네비게이션용
- 노트 에디터에서 마커 클릭 → `goToRectInsidePage(pageNumber, textRect)`
- 마커 필 탭 → `goToPage(pageNumber)` 또는 `goToRectInsidePage()`

## 수정 시 주의사항
- Stack 순서가 중요: 오버레이가 기본 레이어 위에 와야 함
- `Focus` 위젯이 최상위에 있어야 키보드 이벤트 캡처 가능
- 모달 열림 상태는 `WorkspaceState`에서 관리 (→ 06-state.md)
