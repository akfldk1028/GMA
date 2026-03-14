# 06. WorkspaceState + Provider — 상태 관리

## 파일 위치
```
lib/features/workspace/models/workspace_state.dart        — Freezed 모델
lib/features/workspace/pages/providers/workspace_provider.dart — 비즈니스 로직
```

## WorkspaceState 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `currentPdfPath` | `String?` | 현재 열린 PDF 경로 |
| `currentNoteId` | `String?` | 현재 열린 노트 UUID |
| `markers` | `List<PdfMarker>` | 생성된 마커 리스트 |
| `panelSizes` | `PanelSizes` | (legacy, 테스트 호환) |
| `isEditorModalOpen` | `bool` | 에디터 모달 열림 여부 |
| `isFileBrowserOpen` | `bool` | 파일 드로어 열림 여부 |
| `isMarkerEditModalOpen` | `bool` | 마커 편집 모달 열림 여부 |
| `editingMarkerId` | `String?` | 편집 중인 마커 ID (null=새 마커) |
| `pendingMarkerPageNumber` | `int?` | 모달로 전달할 페이지 번호 |
| `pendingMarkerText` | `String?` | 모달로 전달할 선택 텍스트 |
| `pendingMarkerTextRect` | `PdfRect?` | 모달로 전달할 PDF 좌표 |

## WorkspaceProvider 메서드

### 문서 관리
| 메서드 | 설명 |
|--------|------|
| `loadPdf(path)` | PDF 로드 + 노트 없으면 자동 생성 |
| `loadNote(noteId)` | 노트 로드 |
| `updateNoteContent()` | 자동 저장 (디바운스) |
| `saveNoteImmediate()` | 즉시 저장 |

### 마커 관리
| 메서드 | 설명 |
|--------|------|
| `createMarker()` | 마커 생성 + 노트에 삽입 |
| `createDrawingMarker()` | 드로잉 스트로크 마커 |
| `navigateToMarker()` | 마커 ID → PdfMarker 조회 |
| `removeMarker()` | 마커 삭제 |
| `clearMarkers()` | 전체 마커 삭제 |

### UI 상태 제어
| 메서드 | 설명 |
|--------|------|
| `openEditorModal()` | 에디터 모달 열기 |
| `closeEditorModal()` | 에디터 모달 닫기 |
| `toggleFileBrowser()` | 파일 브라우저 토글 |
| `closeFileBrowser()` | 파일 브라우저 닫기 |
| `openMarkerEditModal(page, text, rect)` | 마커 편집 모달 열기 |
| `editMarker(markerId)` | 기존 마커 편집 모달 |
| `closeMarkerEditModal()` | 마커 모달 닫기 + pending 클리어 |

## 수정 시 주의사항
- Freezed 모델 변경 후 반드시: `dart run build_runner build --delete-conflicting-outputs`
- `closeMarkerEditModal()`은 pending 데이터도 전부 null로 클리어해야 함
- `PdfRect`는 JSON 직렬화에 커스텀 `@PdfRectConverter()` 필요
