# GMA - PDF-Linked Markdown Annotation App


아내가 잘못이해햇음 사진봐바 이제 pdf 에는 어떤 필기를 하든 뭐 선을긋든
맨오른쪽에는 아무것도 안나오고 이제 우리 캡쳐 사각형으로하는것이자 이거나
포토샵의 올가미툴이 잇으면 그걸로 사람들이 사각형이나 올가미로해 그러면
그것만 맨오른쪽에 차례때로 정리가되는거야

근데 이거 맨오른쪽이 하나의 캔버스에 차례차례 띄워지고 거기위에든 밑에든 사람들이 
또 필기할수잇게 이게바로 스크랩노트
근데 맨왼쪽 레이어는 이 pdf 의 링크 그대로 나타나되

맨오른쪽은 다른 pdf 들의 스크랩도 불러와질수잇어야해 이거 순차적생각 mcp 써서
planmode로하고 이거 우리가 개발한 문법으로 진행되어야해 
  ❯ 올가미도 지금 추가해야해 커뮤니티나 웹이나 깃 봐바                



## 1. 프로젝트 개요

PDF 문서를 왼쪽에 열고, 오른쪽에 Markdown 노트를 작성하면서
**PDF의 특정 페이지/좌표와 노트가 양방향으로 연결되는** 학습용 메모 앱.

### 핵심 컨셉

**앱 플로우:** Splash → Dashboard → Workspace

```
Splash (1.5s)  →  Dashboard (노트-PDF 대시보드)  →  Workspace
                  ┌──────────────────────────┐
                  │ LinkNote    [+New][PDF][⚙]│
                  │ ┌──────┐ ┌──────┐ ┌────┐ │
                  │ │Note 1│ │Note 2│ │ .. │ │
                  │ │📄 PDF│ │📄 2  │ │    │ │
                  │ │3 elem│ │5 elem│ │    │ │
                  │ └──────┘ └──────┘ └────┘ │
                  └──────────────────────────┘
                               ↓ tap
┌──────────────────────────────────────────────────────┐
│ WorkspaceHeaderV2                                    │
├────┬─────────────────────────────────────────────────┤
│ M  │  PDF Viewer (fullscreen)                        │
│ A  │  + Sticky Note (floating)                       │
│ R  │                                                 │
│ K  │  Overlays:                                      │
│ S  │  - NoteEditorModal (Ctrl+E)                     │
│    │  - FileBrowserDrawer (Ctrl+B)                   │
│    │  - ElementNavigatorDrawer                       │
│    │  - MarkerEditModal                              │
└────┴─────────────────────────────────────────────────┘
```

### 이미지 분석 결과 (사용자 레퍼런스)

| 영역 | 기능 |
|------|------|
| **좌측 PDF** | 페이지 번호 표시, 스크롤 가능, 링크 클릭 가능 |
| **우측 노트** | 파일 메타데이터 (file, file-path) |
| | Wiki-link: `[[3blue1brown/NN]]`, `[[3blue1brown/LLM]]` |
| | 색상 코드 마커: 🔴 P3, 🟡 P5 (페이지별 색상 구분) |
| | PDF 텍스트 발췌 + 페이지 번호 |
| | PDF 이미지/다이어그램 캡처 임베드 |
| | Unlinked References 섹션 |

---

## 2. 핵심 기능 정의

### 2.1 PDF Viewer (좌측 패널)
- PDF 파일 열기 (로컬 파일, 드래그앤드롭)
- 페이지 네비게이션 (스크롤, 페이지 점프)
- 줌 인/아웃
- **텍스트 선택** → 우클릭/버튼으로 노트에 발췌 추가
- **영역 캡처** → 드래그로 이미지 영역 선택 → 노트에 임베드
- **OCR (로컬 LLM)** → 이미지 기반 PDF(스캔본)에서 텍스트 추출 (Ollama LLaVA)
- 페이지 마커 오버레이 (노트에서 참조 중인 페이지에 색상 점 표시)
- 텍스트 검색

### 2.2 Markdown Editor (우측 패널)
- Markdown 실시간 편집 + 프리뷰 토글
- **파일 메타데이터 (Frontmatter)**:
  ```yaml
  ---
  file: DMDA_WK06_1760326528155_0.pdf
  file-path: ./assets/DMDA_WK06_1760326528155_0.pdf
  created: 2026-02-04
  tags: [machine-learning, logistic-regression]
  ---
  ```
- **PDF 페이지 마커 문법**:
  ```markdown
  - 🔴 P3  Dictionary-based sentiment analysis is...
  - 🟡 P5  [캡처된 이미지]
  ```
  - 클릭 시 PDF 뷰어가 해당 페이지로 자동 스크롤
- **Wiki-link**: `[[노트이름]]` 또는 `[[폴더/노트이름]]`
- **이미지 임베드**: PDF에서 캡처한 이미지 표시
- LaTeX 수식 지원: `$inline$`, `$$block$$`
- 자동 저장

### 2.3 PDF ↔ 노트 연동 (핵심 차별점)
- **PDF → 노트**: 텍스트 선택 시 페이지 번호 + 색상 마커로 노트에 자동 삽입
- **노트 → PDF**: 마커(P3, P5) 클릭 시 PDF 해당 페이지로 점프
- **영역 캡처**: PDF의 특정 영역을 이미지로 캡처해 노트에 임베드
- **색상 코딩**: 페이지별 또는 카테고리별 색상 구분 (🔴🟡🟢🔵🟣)
- **좌표 저장**: 텍스트 선택 좌표를 메타데이터에 저장하여 정확한 위치로 복귀

### 2.4 파일 관리
- 노트 폴더 구조 (로컬 파일시스템 기반)
- PDF 에셋 관리 (./assets/ 폴더)
- 노트 목록/검색/태그 필터링
- Unlinked References (현재 노트를 참조하는 다른 노트 자동 탐색)

---

## 3. 기술 스택

### 개발 방식: Auto-Claude (AC247) 자동화

**AC247 = 개발 오케스트레이터**. 에이전트 팀이 자율적으로 코드를 작성한다.

```
┌──────────────────────────────────────────────────────────────────┐
│                    AC247 (Auto-Claude)                            │
│               Planner → Coder → QA Reviewer → Merge              │
│                                                                    │
│  참조 코드베이스 (에이전트가 읽고 학습):                              │
│  ├── C:\DK\GMA\clone\pdfrx       → PDF 렌더링/좌표 패턴           │
│  └── C:\DK\GMA\clone\printnotes  → Markdown/Wiki-link 패턴       │
│                                                                    │
│  타겟 프로젝트:                                                     │
│  └── C:\DK\GMA\frontend          → 빌드 결과물 (Flutter 앱)       │
└──────────────────────────────────────────────────────────────────┘
```

### 참조 프로젝트 (에이전트가 읽을 레퍼런스)

| 참조 프로젝트 | 경로 | 에이전트 활용 포인트 |
|-------------|------|-------------------|
| **pdfrx** | `clone/pdfrx` | PDF 렌더링, 텍스트 선택, 좌표 시스템, 페이지 네비게이션 |
| **printnotes** | `clone/printnotes` | Markdown 편집/렌더링, Wiki-link, 프론트매터, 파일 관리 |

### Flutter 패키지

| 역할 | 패키지 | 용도 |
|------|--------|------|
| UI 컴포넌트 | `shadcn_ui` | 버튼, 카드, 입력, 토스트 |
| PDF 뷰어 | `pdfrx` | PDF 렌더링, 텍스트 선택, 좌표 |
| 상태관리 | `flutter_riverpod` | 전역 상태 (PDF 상태, 노트 상태, 연동) |
| 코드생성 | `riverpod_generator` | Provider 자동 생성 |
| 라우팅 | `go_router` | 화면 전환 |
| HTTP | `http` | OCR 백엔드 (Ollama REST API) |
| HTTP | `dio` | 백엔드 API (향후) |
| 로컬저장 | `hive_flutter` | 설정, 캐시, 마커 메타데이터 |
| 보안저장 | `flutter_secure_storage` | 인증 토큰 |
| 모델 | `freezed` | 불변 데이터 모델 |
| Markdown | `markdown` | Markdown 파싱 |
| LaTeX | `flutter_math_fork` | 수식 렌더링 |
| 파일 | `path_provider` + `file_picker` | 파일 접근 |

---

## 4. 데이터 모델

### 4.1 PDF 마커 (Annotation)

```dart
@freezed
class PdfMarker with _$PdfMarker {
  const factory PdfMarker({
    required String id,
    required String pdfPath,       // PDF 파일 경로
    required int pageNumber,       // 페이지 번호 (P3, P5)
    required MarkerColor color,    // 🔴🟡🟢🔵🟣
    String? selectedText,          // 선택된 텍스트
    PdfRect? textRect,             // PDF 좌표 (텍스트 위치)
    PdfRect? captureRect,          // 이미지 캡처 영역
    String? capturedImagePath,     // 캡처된 이미지 저장 경로
    required DateTime createdAt,
  }) = _PdfMarker;
}

enum MarkerColor { red, yellow, green, blue, purple }
```

### 4.2 노트 (Note)

```dart
@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String title,
    required String content,       // Markdown 원본
    String? linkedPdfPath,         // 연결된 PDF 경로
    required List<PdfMarker> markers,  // PDF 마커 목록
    required List<String> tags,
    required List<String> wikiLinks,   // [[참조]] 목록
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Note;
}
```

### 4.3 노트 파일 구조 (Markdown + Frontmatter)

```markdown
---
file: DMDA_WK06_1760326528155_0.pdf
file-path: ./assets/DMDA_WK06_1760326528155_0.pdf
created: 2026-02-04
tags: [machine-learning, logistic-regression]
markers:
  - id: m1
    page: 3
    color: red
    text: "Dictionary-based sentiment analysis is..."
    rect: [120.5, 340.2, 580.0, 360.8]
  - id: m2
    page: 5
    color: yellow
    capture: ./captures/p5_logistic_regression.png
    rect: [100.0, 200.0, 500.0, 450.0]
---

# DMDA WK06

[[컴퓨터&미디어&인터넷&컴퓨터]]

- [[3blue1brown/NN]]
- [[3blue1brown/LLM]]
- test

- 🔴 P3  Dictionary-based sentiment analysis is a method of evaluating...
- 🔴 P3  It is widely used due to its simplicity and interpretability...

- 🟡 P5
  ![Logistic Regression](./captures/p5_logistic_regression.png)

  $$\ln\left(\frac{p}{1-p}\right) = \beta_0 + \beta_1 x_1 + \beta_2 x_3 + \cdots + \beta_k x_k$$

▸ Unlinked References
```

---

## 5. 화면 구조

### 5.1 Workspace 화면 (PDF 전체화면 + 오버레이)

```
┌──────────────────────────────────────────────────────┐
│ [🏠][≡][📁/📑]  PDF Title       [📝][✏️][⋮]         │
├────┬─────────────────────────────────────────────────┤
│ M  │  PDF Viewer (fullscreen)                        │
│ A  │  + Sticky Note (floating, toggleable)           │
│ R  │                                                 │
│ K  │  Overlays:                                      │
│ S  │  - NoteEditorModal (Ctrl+E)                     │
│    │  - FileBrowserDrawer (Ctrl+B)                   │
│    │  - ElementNavigatorDrawer                       │
│    │  - MarkerEditModal                              │
└────┴─────────────────────────────────────────────────┘
```

- **🏠 Home:** Dashboard로 복귀
- **≡ Menu:** FileBrowser / ElementNavigator 사이드바 토글
- **📁/📑:** 사이드바 모드 전환 (File Browser ↔ Element Navigator)
- **📝 Sticky Note:** 플로팅 메모 토글
- **✏️ Editor:** NoteEditorModal 열기
- **⋮ More:** Open PDF, Toggle Theme, Settings

### 5.2 화면 목록

| 화면 | 경로 | 설명 |
|------|------|------|
| Splash | `/splash` | 브랜딩 + 로딩 (1.5초 후 Dashboard로 이동) |
| Dashboard | `/dashboard` | 노트-PDF 대시보드 (홈 화면) |
| Workspace | `/workspace` | PDF 전체화면 + 오버레이 모달 |
| Note Only | `/note/:id` | 노트만 편집 (PDF 없이) |
| Settings | `/settings` | 테마, 저장 경로, 마커 색상 설정 |

---

## 6. Feature 모듈 구조

```
lib/
├── main.dart
├── app.dart
│
├── common_widgets/
│   ├── split_view.dart              # 리사이즈 가능한 패널 분할
│   ├── color_dot.dart               # 🔴🟡🟢 색상 점
│   └── wiki_link_chip.dart          # [[링크]] 칩 위젯
│
├── constants/
│   ├── app_colors.dart
│   ├── app_theme.dart
│   ├── api_endpoints.dart
│   └── marker_colors.dart           # 마커 색상 정의
│
├── routing/
│   └── app_router.dart
│
├── utils/
│   ├── dio_provider.dart
│   ├── markdown_parser.dart         # 커스텀 Markdown 파서
│   ├── frontmatter_parser.dart      # YAML frontmatter 파싱
│   ├── wiki_link_resolver.dart      # [[링크]] 해석
│   └── file_system_provider.dart    # 로컬 파일 접근
│
└── features/
    ├── auth/                        # 인증 (기존)
    │
    ├── workspace/                   # ⭐ 메인 작업 화면
    │   ├── models/
    │   │   ├── workspace_model.dart     # 워크스페이스 상태
    │   │   └── panel_layout_model.dart  # 패널 크기/배치
    │   ├── pages/
    │   │   ├── providers/
    │   │   │   └── workspace_provider.dart
    │   │   ├── screens/
    │   │   │   └── workspace_screen.dart   # 3패널 메인
    │   │   └── widgets/
    │   │       ├── sidebar_panel.dart
    │   │       └── status_bar.dart
    │   ├── queries/
    │   └── mutations/
    │
    ├── pdf_viewer/                  # ⭐ PDF 뷰어
    │   ├── models/
    │   │   ├── pdf_document_model.dart
    │   │   └── pdf_marker_model.dart    # 마커 데이터
    │   ├── pages/
    │   │   ├── providers/
    │   │   │   ├── pdf_provider.dart         # PDF 문서 상태
    │   │   │   ├── pdf_marker_provider.dart  # 마커 관리
    │   │   │   └── pdf_selection_provider.dart # 텍스트 선택
    │   │   ├── screens/
    │   │   │   └── pdf_viewer_screen.dart
    │   │   └── widgets/
    │   │       ├── pdf_page_overlay.dart     # 마커 오버레이
    │   │       ├── text_selection_toolbar.dart
    │   │       ├── area_capture_overlay.dart # 영역 캡처 UI
    │   │       └── page_navigator.dart
    │   ├── queries/
    │   └── mutations/
    │
    ├── note_editor/                 # ⭐ Markdown 에디터
    │   ├── models/
    │   │   ├── note_model.dart
    │   │   └── marker_syntax_model.dart  # 🔴 P3 파싱 모델
    │   ├── pages/
    │   │   ├── providers/
    │   │   │   ├── note_provider.dart        # 노트 상태
    │   │   │   ├── editor_provider.dart      # 에디터 모드
    │   │   │   └── autosave_provider.dart    # 자동 저장
    │   │   ├── screens/
    │   │   │   └── note_editor_screen.dart
    │   │   └── widgets/
    │   │       ├── markdown_renderer.dart    # MD 렌더링
    │   │       ├── marker_line_widget.dart   # 🔴 P3 라인
    │   │       ├── wiki_link_widget.dart     # [[링크]] 렌더
    │   │       ├── frontmatter_header.dart   # 메타 표시
    │   │       ├── captured_image_widget.dart
    │   │       ├── latex_block_widget.dart
    │   │       ├── editor_toolbar.dart
    │   │       └── unlinked_references.dart  # 역참조 섹션
    │   ├── queries/
    │   └── mutations/
    │
    ├── ocr/                         # ⭐ 로컬 LLM OCR (플러그인 패턴)
    │   ├── ocr_backend.dart             # 추상 인터페이스
    │   ├── ocr_registry.dart            # 백엔드 레지스트리
    │   ├── ocr_service.dart             # 오케스트레이션 (파일/페이지 → 텍스트)
    │   ├── backends/
    │   │   └── ollama_backend.dart      # Ollama LLaVA 구현
    │   └── pages/providers/
    │       └── ocr_provider.dart        # Riverpod 설정 + 호출
    │
    ├── file_manager/                # 파일/폴더 관리
    │   ├── models/
    │   │   └── file_tree_model.dart
    │   ├── pages/
    │   │   ├── providers/
    │   │   │   └── file_manager_provider.dart
    │   │   ├── screens/
    │   │   │   └── file_browser_screen.dart
    │   │   └── widgets/
    │   │       ├── file_tree_view.dart
    │   │       └── search_bar.dart
    │   ├── queries/
    │   └── mutations/
    │
    ├── home/                        # 홈 (최근 노트)
    │   └── pages/screens/
    │       └── home_screen.dart
    │
    ├── profile/                     # 프로필
    │   └── pages/screens/
    │       └── profile_screen.dart
    │
    └── settings/                    # 설정
        └── pages/screens/
            └── settings_screen.dart
```

---

## 7. 핵심 유저 플로우

### Flow 1: PDF에서 텍스트 발췌 → 노트에 추가

```
1. PDF에서 텍스트 드래그 선택
2. 선택 툴바 팝업: [색상 선택 🔴🟡🟢] [노트에 추가] [복사]
3. "노트에 추가" 클릭
4. 시스템이 자동으로:
   a. 페이지 번호 추출 (예: P3)
   b. 선택 텍스트 추출
   c. PDF 좌표 저장 (PdfRect)
   d. Markdown에 마커 라인 삽입:
      "- 🔴 P3  Dictionary-based sentiment analysis is..."
   e. frontmatter markers 배열에 추가
5. 노트 자동 저장
```

### Flow 2: 노트에서 마커 클릭 → PDF 페이지 이동

```
1. 에디터에서 "🔴 P3" 마커 클릭
2. pdf_marker_provider가 마커 ID 조회
3. PdfViewerController.goToRectInsidePage(
     pageNumber: 3,
     rect: marker.textRect  // 저장된 좌표
   )
4. PDF 뷰어가 해당 페이지+위치로 스크롤 + 하이라이트
```

### Flow 3: PDF 영역 캡처 → 노트에 이미지 삽입

```
1. PDF 뷰어에서 캡처 모드 활성화 (버튼 클릭)
2. 드래그로 영역 선택
3. 시스템이:
   a. PdfPage.render()로 선택 영역 렌더링
   b. 이미지를 ./captures/ 폴더에 저장
   c. Markdown에 삽입:
      "- 🟡 P5"
      "  ![캡처](./captures/p5_capture_001.png)"
   d. frontmatter markers에 captureRect 저장
```

### Flow 3.5: 이미지 기반 PDF → OCR → 텍스트 추출

```
1. 영역 캡처 완료 시, 네이티브 텍스트 추출 시도
2. 텍스트가 없으면 (이미지 PDF) + OCR 활성화 상태:
   a. 캡처된 이미지를 Ollama LLaVA에 전송
   b. POST /api/generate {model: "llava", images: [base64], prompt: "..."}
   c. 응답 텍스트를 마커의 selectedText로 사용
3. 전체 페이지 OCR도 가능:
   a. PdfPage.render() → 전체 페이지 이미지 생성 (메모리)
   b. Ollama LLaVA로 OCR
   c. 결과를 파란색 마커로 노트에 삽입
4. 설정: Settings > OCR (Local LLM) 에서 활성화/URL/모델 설정
```

### Flow 4: Wiki-link 네비게이션

```
1. 에디터에서 [[3blue1brown/NN]] 클릭
2. wiki_link_resolver가 파일 시스템에서 검색
3. 해당 노트 파일을 에디터에 로드
4. 이전 노트는 히스토리 스택에 push
```

---

## 8. 상태 관리 설계

### Provider 구조 (Riverpod)

```
┌─────────────────────────────────────────┐
│           workspaceProvider             │
│  (패널 레이아웃, 전체 상태 조율)          │
└───────┬──────────────┬──────────────────┘
        │              │
┌───────▼──────┐ ┌─────▼──────────────────┐
│ pdfProvider  │ │ noteProvider           │
│ - document   │ │ - current note         │
│ - controller │ │ - content              │
│ - page num   │ │ - markers              │
└───────┬──────┘ └─────┬──────────────────┘
        │              │
┌───────▼──────────────▼──────────────────┐
│         pdfMarkerProvider               │
│  (PDF ↔ 노트 연동의 핵심)                │
│  - 마커 목록 관리                        │
│  - 텍스트 선택 → 마커 생성               │
│  - 마커 클릭 → PDF 페이지 점프           │
│  - 영역 캡처 → 이미지 저장              │
└─────────────────────────────────────────┘

┌─────────────────┐  ┌──────────────────┐
│ fileManagerProv  │  │ autosaveProv     │
│ - 파일 트리      │  │ - 3초 디바운스   │
│ - 검색           │  │ - 저장 상태 표시  │
└─────────────────┘  └──────────────────┘
```

---

## 9. PDF 좌표 시스템 활용 (pdfrx)

```
PDF 좌표계 (pdfrx):        Flutter 좌표계:
  Y ▲                        (0,0) ────► X
    │                          │
    │  (x, y)                  │  (x, y)
    │                          ▼
    └──────► X                 Y

주의: PDF는 좌하단이 원점, Flutter는 좌상단이 원점
pdfrx가 내부적으로 변환 처리
```

### 마커 좌표 저장 형식

```json
{
  "id": "m1",
  "page": 3,
  "color": "red",
  "text": "Dictionary-based sentiment analysis...",
  "rect": {
    "left": 120.5,
    "top": 360.8,
    "right": 580.0,
    "bottom": 340.2
  }
}
```

---

## 10. 로컬 저장 구조

```
~/GMA_Notes/                         # 사용자 지정 루트 폴더
├── .gma/
│   ├── config.json                  # 앱 설정
│   └── index.json                   # 노트 인덱스 (빠른 검색용)
│
├── assets/                          # PDF 원본 저장
│   ├── DMDA_WK06_1760326528155_0.pdf
│   └── ML_Lecture_02.pdf
│
├── captures/                        # PDF 캡처 이미지
│   ├── p5_logistic_regression.png
│   └── p12_neural_network.png
│
├── notes/                           # Markdown 노트
│   ├── DMDA_WK06.md
│   ├── ML_Lecture_02.md
│   └── refs/
│       ├── 3blue1brown/
│       │   ├── NN.md
│       │   └── LLM.md
│       └── nvidia/
│           └── sentiment-analysis.md
│
└── trash/                           # 휴지통
```

---

## 11. ScrapNote 기획 (핵심 신규 기능)

### 11.1 개념

ScrapNote는 여러 PDF에서 수집한 하이라이트/필기를 하나의 노트로 모으는 **gma_md 블록 타입**이다.

기존 블록(`:::concept`, `:::theorem`)이 "내용을 렌더링"하는 역할이라면,
`:::scrapnote`는 **PDF element를 수집·링크·네비게이션**하는 역할.

```
기존:  Note ──1:1── PDF ──contains── Marker (노트 텍스트에 임베드)
신규:  Element (독립 엔티티) ──N:M── ScrapNote (gma_md 블록)
```

### 11.2 Element (핵심 데이터 단위)

PDF에서 하이라이트하거나 필기한 것 = **하나의 Element**.

```
Element {
  id:          고유 ID (UUID)
  pdfId:       PDF 고유 ID (파일명 변경돼도 유지)
  pageNumber:  페이지 번호
  type:        highlight | drawing
  rect:        PDF 좌표 (PdfRect, 하이라이트 영역)
  strokes:     필기 스트로크 데이터 (드로잉인 경우)
  selectedText: 발췌 텍스트 (하이라이트인 경우)
  imagePath:   캡처/필기 이미지 경로
  createdAt:   생성 시각
}
```

**특징:**
- 독립 엔티티로 별도 저장 (노트 마크다운에 임베드 X)
- 하나의 Element가 **여러 ScrapNote에 소속** 가능 (N:M)
- **PDF 고유 ID** 기반 연결 → 파일명 변경돼도 링크 안 깨짐

### 11.3 ScrapNote 문법 (`:::scrapnote`)

```markdown
::: scrapnote 통계정리
@el e001   <!-- PDF1:P3 하이라이트 — "중심극한정리는..." -->
@el e002   <!-- PDF1:P5 필기 이미지 -->
@el e003   <!-- PDF2:P12 하이라이트 — "표본분산의 정의..." -->
:::
```

- `:::scrapnote [제목]` 으로 블록 선언
- 내부에 `@el [elementId]` 로 element 참조
- 같은 element ID가 여러 scrapnote 블록에 나올 수 있음 (N:M)
- 순서 = 작성 순서 (사용자가 하이라이트/필기한 순)

### 11.4 유저 플로우

```
1. PDF1 열고 중요 문장 하이라이트
   → Element A 자동 생성 → 현재 ScrapNote에 순서대로 추가

2. PDF2 열고 그림 위에 필기
   → Element B 자동 생성 → 같은 ScrapNote에 추가

3. "통계정리" ScrapNote 클릭
   → 사이드바에 Element A, B 목록이 쫙 나열

4. Element A 클릭
   → PDF1의 P3 페이지로 이동 (zoom 레벨 유지, 페이지만 이동)

5. Element A를 "기말고사" ScrapNote에도 추가
   → 같은 Element가 2개 ScrapNote에 존재

6. PDF1 파일명 변경
   → 고유 ID 기반이라 링크 안 깨짐
```

### 11.5 레이아웃 (실제 구현)

```
┌──────────────────────────────────────────────────────┐
│ [🏠][≡][📑] PDF Title             [📝][✏️][⋮]       │
├──────────────┬───────────────────────────────────────┤
│ Element Nav  │  PDF Viewer (fullscreen)              │
│ (drawer)     │                                       │
│              │  + Sticky Note (floating)             │
│ 🔴 PDF1:P3  │                                       │
│ 🟡 PDF1:P5  │  Overlays:                            │
│ 🔵 PDF2:P12 │  - NoteEditorModal (::: scrapnote)    │
│ ✏️ PDF2:P8  │  - FileBrowserDrawer                  │
│              │  - MarkerEditModal                    │
└──────────────┴───────────────────────────────────────┘
```

- **Element Navigator (사이드바 드로어)** = 현재 PDF의 element 목록, 클릭 → 해당 페이지 이동
- **PDF Viewer (전체화면)** = element 클릭 시 해당 페이지로 이동 (zoom 유지)
- **NoteEditorModal (오버레이)** = `:::scrapnote` 블록 편집, Ctrl+E로 토글
- **Sticky Note (플로팅)** = 간단한 메모 위젯, 토글 가능

### 11.6 기존 시스템 대비 변경점

| 항목 | 현재 | ScrapNote |
|------|------|-----------|
| PDF 연결 | Note 1:1 PDF | **ScrapNote : N개 PDF** |
| 마커 저장 | 노트 마크다운 텍스트 (`🔴 P3 텍스트...`) | **Element = 독립 엔티티** (별도 저장) |
| 소속 | 마커는 1개 노트에만 | **Element는 여러 ScrapNote에 소속 (N:M)** |
| PDF 식별 | 파일 경로 | **PDF 고유 ID** (파일명 변경 안전) |
| 네비게이션 | 마커 클릭 → zoom to rect | **zoom 유지 + page만 이동** |

### 11.7 구현 범위 (예상)

- **gma_md 블록:** `blocks/scrapnote_block.dart` + `block_registry.dart`에 등록
- **Element 모델:** 독립 Freezed 모델 + 별도 저장소 (Hive 또는 JSON)
- **PDF 고유 ID 시스템:** PDF 등록 시 UUID 부여, 경로 변경 추적
- **사이드바 모드:** 파일 트리 ↔ Element 네비게이터 전환
- **PDF 네비게이션:** zoom 유지 + 페이지만 이동하는 새 네비게이션 모드
- **N:M 관계 관리:** Element ↔ ScrapNote 매핑 저장

---

## 12. 개발 우선순위

### Phase 1: 코어 (MVP)
1. ✅ Flutter 프로젝트 초기 셋업
2. 3패널 레이아웃 (사이드바 + PDF + 에디터)
3. pdfrx 기반 PDF 뷰어 통합
4. 기본 Markdown 에디터 (편집 + 프리뷰)
5. PDF 텍스트 선택 → 노트에 마커 추가
6. 마커 클릭 → PDF 페이지 점프
7. 로컬 파일 저장/로드

### Phase 2: 고급 기능
8. PDF 영역 캡처 → 이미지 저장 + 임베드
9. Wiki-link `[[]]` 파싱 + 네비게이션
10. Frontmatter 파싱 + 표시
11. 파일 트리 사이드바
12. 전체 텍스트 검색
13. 자동 저장

### Phase 3: 폴리싱
14. Unlinked References 섹션
15. LaTeX 수식 렌더링
16. 마커 색상 커스터마이징
17. 테마 (라이트/다크)
18. 키보드 단축키
19. 드래그앤드롭 PDF 열기

### Phase 4: 확장 (향후)
20. 클라우드 동기화 (백엔드 연동)
21. ✅ OCR (로컬 LLM — Ollama LLaVA, 플러그인 패턴 스캐폴딩 완료)
22. AI 요약 (선택 텍스트 자동 요약)
23. 멀티 PDF 동시 열기
24. 모바일 대응

---

## 12. 참조 프로젝트 활용 계획

### pdfrx에서 가져올 것
- `PdfViewer` 위젯 직접 사용 (패키지 의존성)
- `PdfViewerController` 로 페이지 네비게이션
- `PdfTextSelectionParams` 로 텍스트 선택 핸들링
- `PdfPage.render()` 로 영역 캡처
- `PdfPageText` / `PdfRect` 로 좌표 관리
- 예제 앱의 마커 시스템 패턴 참고

### printnotes에서 참고할 것
- 커스텀 Markdown 위젯 렌더링 구조
- Wiki-link 파싱 (`[[filename]]`, `[[filename#header]]`)
- Frontmatter 파싱 패턴 (cosmic_frontmatter)
- 파일 시스템 기반 노트 관리
- 에디터 ↔ 프리뷰 토글 구조
- 태그 시스템

---

## 13. Auto-Claude (AC247) 실행 가이드

### 13.1 전체 구조

```
C:\DK\GMA\
├── frontend/                ← 타겟 프로젝트 (--project-dir)
├── clone/
│   ├── AC247/               ← Auto-Claude 엔진
│   ├── pdfrx/               ← 참조 코드 (PDF)
│   └── printnotes/          ← 참조 코드 (Markdown)
├── docs/
│   └── PROJECT_DESIGN.md    ← 이 문서
└── .auto-claude/            ← AC247이 생성 (specs, worktrees)
```

### 13.2 사전 준비

```powershell
# 1. AC247 백엔드 의존성 설치
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\backend
uv venv && uv pip install -r requirements.txt

# 2. AC247 프론트엔드 (Electron UI) 설치
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\frontend
npm install

# 3. GMA frontend를 git repo로 초기화 (worktree에 필요)
cd C:\DK\GMA\frontend
git init && git add -A && git commit -m "Initial Flutter setup"

# 4. 환경 변수 (.env)
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\backend
# .env 파일에 CLAUDE_CODE_OAUTH_TOKEN 설정 필요
```

### 13.3 Design Task로 전체 분해 (추천: 먼저 실행)

```powershell
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\backend

# GMA 프로젝트를 자식 태스크들로 자동 분해
python runners/spec_runner.py \
  --task "PDF-Linked Markdown Annotation App: 3-panel layout (sidebar + PDF viewer + markdown editor), PDF text selection with page markers, marker click to PDF page jump, area capture to image, wiki-links, frontmatter, auto-save. Reference code: C:\DK\GMA\clone\pdfrx (PDF engine), C:\DK\GMA\clone\printnotes (Markdown patterns). Tech: Flutter + Riverpod + shadcn_ui + pdfrx + go_router + freezed. See C:\DK\GMA\docs\PROJECT_DESIGN.md for full spec." \
  --project-dir C:\DK\GMA\frontend \
  --task-type design \
  --no-build
```

이렇게 하면 AC247이 자동으로 5~10개 자식 태스크로 분해한다:
- `001-split-panel-layout`
- `002-pdf-viewer-integration`
- `003-markdown-editor`
- `004-pdf-note-linking`
- `005-wiki-links`
- etc.

### 13.4 데몬 시작 (자동 실행)

```powershell
# 데몬이 specs/ 감시하면서 자동으로 Planner → Coder → QA 실행
python runners/daemon_runner.py \
  --project-dir C:\DK\GMA\frontend \
  --status-file C:\DK\GMA\frontend\.auto-claude\daemon_status.json
```

### 13.5 Electron UI로 모니터링

```powershell
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\frontend
npm run dev
# → Kanban Board에서 태스크 상태 확인
# → Agent Terminals에서 실시간 로그 확인
```

### 13.6 수동 실행 (개별 태스크)

```powershell
# 특정 태스크만 빌드
python run.py --spec 001 --project-dir C:\DK\GMA\frontend

# QA만 재실행
python run.py --spec 001 --qa --project-dir C:\DK\GMA\frontend

# 태스크 목록 확인
python run.py --list --project-dir C:\DK\GMA\frontend
```

### 13.7 에이전트 파이프라인 흐름

```
spec_runner --task-type design
  ↓
.auto-claude/specs/ 에 자식 태스크 생성
  ↓
daemon_runner (감시 중)
  ↓ (각 태스크마다)
  ├─ Planner: PROJECT_DESIGN.md + 참조코드 읽고 구현 계획 수립
  ├─ Coder:   계획에 따라 코드 작성 (pdfrx/printnotes 패턴 참고)
  ├─ QA:      flutter analyze + 빌드 검증 + 코드 리뷰
  │    ↓ (실패 시)
  │    QA Fixer → 수정 → QA 재검증 (최대 3회)
  └─ Auto-merge → main 브랜치 반영
```
