# Home UI 리워크 상세 (2026-03-06)

## 기획안
- `docs/image/UI/LinkNote Home UI_1~15.jpg` (15장)
- Galaxy Tab 노트 앱 스타일 (Flexcil, Samsung Notes 참고)

## 핵심 변경
- 기존 5탭 Notion 사이드바 → 3탭 아이콘 레일 (All Notes / Trash / Folders)
- Dashboard/Graph/Scraps/Settings → 상단 ⋮ 메뉴에서 접근
- 스플래시 → `/home` (기존 `/dashboard` 대신)
- Workspace 뒤로가기 → `/home` (기존 `/dashboard` 대신)

## 노드형 아키텍처 (파일 구조)

```
features/home/
├── models/
│   └── folder_model.dart          # Freezed: id, name, parentId, order, createdAt
├── providers/
│   ├── folder_store.dart          # [데이터 노드] Hive CRUD, keepAlive
│   ├── home_state_provider.dart   # [상태 노드] 탭/뷰모드/선택/정렬/검색
│   └── home_note_list_provider.dart # [필터 노드] all/trash/folder 노트 필터
└── pages/
    ├── screens/
    │   └── home_screen.dart       # TopBar + SortBar + Body + MultiSelectBar
    └── widgets/
        ├── home_icon_rail.dart     # 접힌 사이드바 (56px)
        ├── home_expanded_sidebar.dart # 펼친 사이드바 (200px)
        ├── home_top_bar.dart       # 탭 타이틀 + 액션 아이콘
        ├── overflow_menu.dart      # ⋮ 메뉴 (편집/뷰토글/핀/네비게이션)
        ├── sort_bar.dart           # 정렬 옵션 드롭다운
        ├── note_card.dart          # 노트 그리드 카드
        ├── note_grid_view.dart     # GridView (반응형)
        ├── note_list_view.dart     # ListView
        ├── multi_select_bottom_bar.dart # 멀티선택 하단바
        ├── folder_chip_bar.dart    # 폴더 아이콘 가로 스크롤 (큰 폴더 아이콘)
        ├── folder_tree_widget.dart # 사이드바 폴더 트리 (계층/접기/파일수)
        ├── folder_create_dialog.dart # 폴더 생성 (서브폴더 지원)
        ├── folder_picker_dialog.dart # 폴더 이동용 피커
        ├── folders_view.dart       # 폴더 탭 (칩바+breadcrumb+정렬+그리드)
        ├── trash_view.dart         # 휴지통 (그리드/리스트 + 빈 상태)
        ├── pdf_link_popup.dart     # PDF 열 때 링크 옵션
        └── search_overlay.dart     # 인라인 검색
```

## 데이터 흐름

```
[FileManager] ──scan──→ List<NoteMetadata>
      ↓                        ↓
[Mutations]            [Filter Providers]
  Create                 allNotes (isDeleted=false, sort, pin)
  Delete (soft)          trashNotes (isDeleted=true)
  Restore                folderNotes (folderId filter)
  Move                        ↓
  Pin                   [UI Widgets]
                          NoteGridView / NoteListView / TrashView
      ↓
[FolderStore] ──Hive──→ List<FolderModel>
      ↓                        ↓
  create/rename/delete   FolderChipBar, FolderTreeWidget
```

## NoteMetadata 확장 필드
- `folderId`: String? (null = 루트)
- `isPinned`: bool (즐겨찾기)
- `isDeleted`: bool (소프트 삭제, frontmatter에 기록)
- `deletedAt`: DateTime? (삭제 시각)

## 라우팅
- `/home` → HomeScreen (ShellRoute, AppShell 포함)
- `/workspace` → WorkspaceScreen (ShellRoute 밖, 독립)
- `/dashboard`, `/scraps`, `/knowledge-graph`, `/settings` → ShellRoute 내

## 기획안 슬라이드 대응
| 슬라이드 | 내용 | 파일 |
|---------|------|------|
| 1~4 | 모든 노트 그리드/리스트 | note_grid_view, note_list_view |
| 5~6 | 사이드바 접힘/펼침 | home_icon_rail, home_expanded_sidebar |
| 7~8 | 정렬/뷰모드 토글 | sort_bar, overflow_menu |
| 9~11 | 멀티 선택 + 하단 액션 | multi_select_bottom_bar |
| 12 | 휴지통 (편집/비우기) | trash_view, overflow_menu |
| 13 | 폴더 (큰 폴더 아이콘 가로 스크롤) | folder_chip_bar, folders_view |
| 14 | 폴더 선택 (타이틀 변경, breadcrumb) | home_top_bar, folders_view |
| 15 | 펼친 사이드바 폴더 트리 (계층/파일수) | folder_tree_widget |
