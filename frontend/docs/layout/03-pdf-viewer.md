# 03. PdfViewerScreen — PDF 뷰어

## 파일 위치
```
lib/features/pdf_viewer/pages/screens/pdf_viewer_screen.dart
```

## 역할
pdfrx의 `PdfViewer` 위젯을 래핑. 2쪽 보기, 텍스트 선택, 드로잉/캡처 오버레이, 페이지 네비게이션 제공.

## 레이아웃
```
Stack
├── PdfViewer (2-page facing layout via FacingPagesLayout)
├── "Add Marker" 버튼 (텍스트 선택 시 top-right)
├── DrawingToolbar + CaptureButton (externalToolbar=false일 때)
│   또는 CaptureButton만 (externalToolbar=true일 때)
└── NavigationControls (하단 중앙 pill bar)
```

## 핵심 파라미터
| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `controller` | `PdfViewerController?` | 외부 컨트롤러 (workspace에서 주입) |
| `onAddMarkerPressed` | `Function?` | 텍스트 선택 → 마커 생성 콜백 |
| `noteId` | `String?` | 드로잉 스토크 저장용 노트 ID |
| `externalToolbar` | `bool` | true: 내부 툴바 숨김, 캡처 버튼만 표시 |

## 2쪽 보기 (FacingPagesLayout)
```dart
layoutPages: (pages, params, helper) => FacingPagesLayout.fromPages(
  pages, params,
  helper: helper,
  firstPageIsCoverPage: true,  // 1페이지는 단독 표시 (표지)
),
```
- pdfrx 내장 `FacingPagesLayout` 사용
- `firstPageIsCoverPage: true` → 1쪽 단독, 2-3쪽 나란히, 4-5쪽 나란히...

## 텍스트 선택 → 마커 흐름
1. `PdfTextSelectionParams.onTextSelectionChange` → `_handleTextSelectionChange`
2. 선택 정보 저장: `_selectedText`, `_selectedPageNumber`, `_selectedTextRect`
3. "Add Marker" 버튼 표시 → 클릭 시 `onAddMarkerPressed` 호출
4. workspace_screen → `openMarkerEditModal()` → MarkerEditModal 표시

## 드로잉/캡처 오버레이
- `_buildCombinedOverlays()` → 페이지별 DrawingOverlay + CaptureOverlay
- DrawingOverlay: 펜/형광펜/지우개 (→ 07-drawing.md)
- CaptureOverlay: 영역 캡처 → 이미지 저장 → 노트에 삽입

## 관련 파일
| 파일 | 역할 |
|------|------|
| `pages/providers/pdf_document_provider.dart` | PDF 문서 로딩/상태 |
| `pages/providers/pdf_marker_provider.dart` | 마커 상태 (paint callback용) |
| `pages/widgets/pdf_page_overlay.dart` | 페이지 위 마커 하이라이트 렌더링 |
| `pages/widgets/marker_pills_strip.dart` | 좌측 마커 필 스트립 |
| `utils/pdf_text_extractor.dart` | PDF 텍스트 추출 유틸리티 |
| `capture/pages/widgets/capture_overlay.dart` | 캡처 오버레이 |
| `capture/pages/providers/capture_provider.dart` | 캡처 모드 상태 |
| `capture/utils/capture_service.dart` | 이미지 저장 서비스 |

## 수정 시 주의사항
- `externalToolbar=true`일 때 내부 DrawingToolbar는 숨기지만 CaptureButton은 표시
- `anyOverlayActive` (드로잉 or 캡처)이면 텍스트 선택 비활성화
- `pdfMarkerStateProvider`를 watch해야 마커 추가 후 paint callback 갱신됨
