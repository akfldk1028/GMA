# 05. 모달 & 드로어 — 오버레이 시스템

## 아키텍처
모든 모달/드로어는 `workspace_screen.dart`의 **Stack** 자식으로 조건부 렌더링.
`Navigator.push()`를 사용하지 않음 → 테스트 용이, 상태 예측 가능.

```dart
Stack(
  children: [
    Column(...),  // Base layer
    if (state.isFileBrowserOpen)   FileBrowserDrawer(...),
    if (state.isEditorModalOpen)   NoteEditorModal(...),
    if (state.isMarkerEditModalOpen) MarkerEditModal(...),
  ],
)
```

---

## A. NoteEditorModal — 중앙 에디터 모달

### 파일
```
lib/features/workspace/pages/widgets/note_editor_modal.dart
```

### 레이아웃
```
┌──────────────────────────────────┐
│         (dimmed background)       │
│   ┌──────────────────────────┐   │
│   │ [📝 Note Editor]    [X] │   │  44px 헤더
│   ├──────────────────────────┤   │
│   │                          │   │
│   │    NoteEditorScreen      │   │  85% × 90%
│   │    (Edit/Split/Preview)  │   │
│   │                          │   │
│   └──────────────────────────┘   │
└──────────────────────────────────┘
```

### 애니메이션
- ScaleTransition (0.95 → 1.0) + FadeTransition
- 200ms, easeOutCubic

### 열기/닫기
- 열기: `WorkspaceProvider.openEditorModal()` → `isEditorModalOpen = true`
- 닫기: 배경 탭, X 버튼, Esc 키, Ctrl+E

### 내부 위젯
`NoteEditorScreen` (→ 08-note-editor.md)을 그대로 임베딩.

---

## B. MarkerEditModal — 마커 생성/편집 다이얼로그

### 파일
```
lib/features/workspace/pages/widgets/marker_edit_modal.dart
```

### 레이아웃
```
┌──────────────────────────────────┐
│         (dimmed background)       │
│       ┌──────────────────┐       │
│       │ Add Marker  [P3] │       │  420px 너비
│       ├──────────────────┤       │
│       │ "선택된 텍스트..."  │       │
│       ├──────────────────┤       │
│       │ Color: 🔴🟡🟢🔵🟣│       │
│       ├──────────────────┤       │
│       │    [Cancel] [OK] │       │
│       └──────────────────┘       │
└──────────────────────────────────┘
```

### 애니메이션
- FadeTransition, 200ms

### 데이터 흐름
1. PDF 텍스트 선택 → `openMarkerEditModal(pageNumber, text, textRect)`
2. 모달에서 색상 선택 → Confirm
3. `WorkspaceProvider.createMarker()` → 마커 생성 + 노트에 삽입

### 주의
- `_colorInitialized` 플래그: 편집 모드에서 기존 색상 덮어쓰기 방지
- `pendingMarkerTextRect`를 통해 textRect 전달

---

## C. FileBrowserDrawer — 파일 탐색기 드로어

### 파일
```
lib/features/workspace/pages/widgets/file_browser_drawer.dart
```

### 레이아웃
```
┌─────────────┬──────────────────────────┐
│             │                          │
│  File       │    (dimmed background)   │
│  Browser    │                          │
│  300px      │                          │
│             │                          │
│  (slide-in) │                          │
│             │                          │
└─────────────┴──────────────────────────┘
```

### 애니메이션
- SlideTransition (왼쪽에서 슬라이드인) + FadeTransition
- 250ms, easeOutCubic

### 내부 위젯
`FileBrowserScreen`을 임베딩.

### 관련 파일
```
lib/features/file_manager/pages/screens/file_browser_screen.dart   — 파일 목록 화면
lib/features/file_manager/pages/providers/file_manager_provider.dart — 파일 시스템 상태
lib/features/file_manager/pages/widgets/file_tree_widget.dart       — 트리 위젯
lib/features/file_manager/pages/widgets/note_list_item.dart         — 노트 리스트 아이템
lib/features/file_manager/pages/widgets/note_create_dialog.dart     — 노트 생성 다이얼로그
lib/features/file_manager/models/note_metadata_model.dart           — 노트 메타데이터 모델
```

---

## 모달 우선순위 (Esc 닫기 순서)
1. MarkerEditModal (가장 위)
2. NoteEditorModal
3. FileBrowserDrawer (가장 아래)
