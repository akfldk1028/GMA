# 02. WorkspaceHeaderV2 — 상단 헤더

## 파일 위치
```
lib/features/workspace/pages/widgets/workspace_header_v2.dart
```

## 역할
48px 높이의 상단 바. 파일 브라우저 토글, 문서 제목, 에디터 토글, 추가 메뉴 제공.

## 레이아웃
```
┌─────────────────────────────────────────────────┐
│ [☰ menu]  PDF 파일명 제목         [📝 edit] [...] │
│  48px                                            │
└─────────────────────────────────────────────────┘
```

## 콜백
| 버튼 | 콜백 | 동작 |
|------|------|------|
| ☰ menu | `onToggleFileBrowser` | 파일 브라우저 드로어 열기/닫기 |
| 📝 edit | `onToggleEditor` | 노트 에디터 모달 열기/닫기 |
| ... more | `_showMoreMenu` | ShadDialog로 메뉴 (PDF 열기, 테마, 설정) |

## 의존성
- `workspaceProviderProvider` — PDF 경로에서 제목 추출
- `themeMode$Provider` — 다크/라이트 토글
- `pdfDocumentProvider` — PDF 로드

## 수정 시 주의사항
- `onToggleEditor`는 workspace_screen에서 `isEditorModalOpen` 상태를 토글
- "Open PDF" 메뉴는 `_handleOpenPdf`에서 FilePicker → loadPdf → loadFromFile 순서로 실행
- 제목은 PDF 경로 없으면 "GMA" 기본값
