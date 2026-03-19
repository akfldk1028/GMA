---
name: project_architecture
description: LinkNote 노드형 모듈화 아키텍처 (n8n 패턴) - 데이터/필터/상태/액션/UI 노드 구조
type: project
---

# 아키텍처 패턴: 노드형 모듈화 (n8n 패턴)

- 각 컴포넌트가 **독립 노드**로 동작, 연결만 바꾸면 교체 가능
- 데이터 노드: `FolderStore`, `FileManager`, `ElementStore`, `PdfRegistry`
- 필터 노드: `allNotesProvider`, `folderNotesProvider`, `trashNotesProvider`
- 상태 노드: `HomeState`, `WorkspaceProvider`
- 액션 노드: `CreateNoteMutation`, `DeleteNoteMutation` 등 개별 Mutation
- UI 노드: `NoteCard`, `NoteGridView`, `SortBar` 등 개별 위젯

**Why:** 유지보수 편의성 최우선, 유저가 n8n 패턴 강하게 선호
**How to apply:** 새 기능 추가 시 반드시 독립 노드로 분리. 한 파일에 여러 역할 금지.
