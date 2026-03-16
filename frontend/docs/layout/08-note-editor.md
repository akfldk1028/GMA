# 08. NoteEditorScreen — 마크다운 에디터

## 파일 구조
```
lib/features/note_editor/
├── models/
│   ├── note_model.dart           — NoteModel (Freezed)
│   ├── frontmatter_model.dart    — FrontmatterModel (title, linkedPdfPath 등)
│   └── marker_model.dart         — MarkerModel (파싱된 마커 데이터)
├── pages/
│   ├── providers/
│   │   ├── note_provider.dart       — 노트 CRUD (파일시스템)
│   │   └── note_editor_provider.dart — 에디터 상태 (content, 마커 삽입)
│   ├── screens/
│   │   └── note_editor_screen.dart  — 메인 에디터 화면
│   └── widgets/
│       ├── frontmatter_header.dart  — YAML 프론트매터 헤더 표시
│       └── marker_line_widget.dart  — 마커 라인 위젯
└── utils/
    ├── markdown_config.dart      — 마크다운 렌더링 설정
    ├── markdown_extension.dart   — 마크다운 확장 인터페이스
    ├── marker_parser.dart        — 마커 라인 파싱 (🔴 P3 텍스트)
    ├── marker_line_renderer.dart — 마커 라인 렌더러 (클릭 가능)
    ├── wiki_link_renderer.dart   — [[Wiki-link]] 렌더러
    └── latex_renderer.dart       — LaTeX 수식 렌더러
```

## 에디터 모드
```dart
enum EditorMode { edit, split, preview }
```
- **Edit**: 텍스트 에디터만 (markdown 원문)
- **Split**: 좌측 에디터 + 우측 프리뷰
- **Preview**: 마크다운 렌더링만

## 마커 삽입 흐름
1. `WorkspaceProvider.createMarker()` 호출
2. `noteEditorProvider.insertMarker(color, pageNumber, text)` 호출
3. 노트 끝에 `- 🔴 P3  선택된 텍스트...` 형식으로 삽입

## 마커 클릭 → PDF 점프
1. 프리뷰에서 마커 라인 클릭 → `onMarkerClick('page:3-1')` 콜백
2. workspace_screen `_handleMarkerClick()` → `pdfController.goToPage()`

## NoteEditorProvider 주요 메서드
| 메서드 | 설명 |
|--------|------|
| `insertMarker(color, page, text)` | 마커 라인 삽입 |
| `insertCapture(page, filename, dir, text)` | 캡처 이미지 삽입 |
| `updateContent(content)` | 편집 내용 업데이트 |

## 마크다운 확장 (플러그인 패턴)
`MarkdownExtension` 인터페이스 구현으로 새 문법 추가:
- `marker_line_renderer.dart` — 마커 라인 (🔴 P3)
- `wiki_link_renderer.dart` — [[Wiki-link]]
- `latex_renderer.dart` — $수식$

## 수정 시 주의사항
- NoteEditorModal에서 `NoteEditorScreen(noteId, onMarkerClick)`으로 임베딩
- `noteId`가 null이면 빈 상태 표시
- 프론트매터 파싱은 YAML 기반 (yaml 패키지)
