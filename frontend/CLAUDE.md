# GMA Frontend - Agent Guide

> **이 파일은 Auto-Claude 에이전트가 이 프로젝트를 이해하기 위해 읽는 필수 문서다.**

---

## 1. 프로젝트 요약

**GMA** = PDF 좌표 연동 Markdown 메모 앱 (Flutter)

- 왼쪽: PDF 뷰어 (pdfrx)
- 오른쪽: Markdown 에디터 (Wiki-link, Frontmatter, LaTeX)
- 핵심: PDF 텍스트 선택 → 페이지 마커로 노트에 삽입, 마커 클릭 → PDF 점프

---

## 2. 상세 설계 문서

**반드시 읽어라:** `C:\DK\GMA\docs\PROJECT_DESIGN.md`

---

## 3. 참조 코드베이스 (반드시 참고)

### pdfrx (PDF 엔진)
- **경로:** `C:\DK\GMA\clone\pdfrx`
- **핵심 파일:**
  - `packages/pdfrx/lib/src/widgets/pdf_viewer.dart` → PdfViewer 위젯
  - `packages/pdfrx/lib/src/widgets/pdf_viewer_params.dart` → 설정 파라미터
  - `packages/pdfrx_engine/lib/src/pdf_page.dart` → 페이지 API (render, text)
  - `packages/pdfrx_engine/lib/src/pdf_text.dart` → 텍스트/좌표 (PdfPageText, PdfRect)
  - `packages/pdfrx/example/viewer/` → 예제 앱 (마커, 검색, 텍스트 선택 패턴)
- **활용:** PdfViewer, PdfViewerController, PdfTextSelectionParams, PdfPage.render(), PdfRect

### printnotes (Markdown 패턴)
- **경로:** `C:\DK\GMA\clone\printnotes`
- **핵심 파일:**
  - `lib/markdown/build_markdown.dart` → Markdown 렌더링 설정
  - `lib/markdown/rendering/wiki_link.dart` → [[Wiki-link]] 파싱/렌더링 구현
  - `lib/markdown/rendering/latex.dart` → LaTeX 수식 렌더링
  - `lib/ui/screens/editors/notes/note_editor.dart` → 에디터 화면 구조
  - `lib/utils/storage_system.dart` → 파일 시스템 기반 노트 관리
  - `lib/markdown/link_handler.dart` → 링크 처리 핸들러
- **활용:** Wiki-link 파싱 패턴, Markdown 렌더링 커스터마이징, Frontmatter 처리, 파일 관리

---

## 4. 기술 스택

| 역할 | 패키지 | 버전 |
|------|--------|------|
| UI | shadcn_ui | ^0.45.1 |
| 상태관리 | flutter_riverpod + riverpod_generator | ^2.6.1 |
| 라우팅 | go_router | ^14.6.2 |
| PDF | pdfrx | ^1.0.98 |
| HTTP | dio | ^5.7.0 |
| 로컬저장 | hive_flutter | ^1.1.0 |
| 보안저장 | flutter_secure_storage | ^9.2.2 |
| 모델 | freezed + json_serializable | ^2.5.7 |
| Markdown | markdown | ^7.2.2 |
| LaTeX | flutter_math_fork | ^0.7.2 |
| 파일 | path_provider + file_picker | ^2.1.4 |
| HTTP | http | ^1.2.0 |
| UUID | uuid | ^4.5.1 |
| YAML | yaml | ^3.1.2 |

---

## 5. 프로젝트 구조 (Feature-First)

```
lib/
├── main.dart                    # ProviderScope + Hive 초기화
├── app.dart                     # ShadApp.router + 테마
├── common_widgets/              # 공유 위젯 (split_view, color_dot 등)
├── constants/                   # 색상, 테마, API 상수, 마커 색상
│   ├── app_colors.dart
│   ├── app_theme.dart
│   ├── api_endpoints.dart
│   └── marker_colors.dart       # MarkerColor enum (🔴🟡🟢🔵🟣)
├── routing/app_router.dart      # GoRouter (/, /workspace, /note/:id, /settings, /login, /profile)
├── utils/                       # 유틸리티 providers
│   ├── dio_provider.dart        # Dio HTTP 클라이언트
│   └── file_system_provider.dart # 로컬 파일 시스템 접근
└── features/
    ├── workspace/               # ⭐ 메인 3패널 화면 (사이드바+PDF+에디터)
    ├── pdf_viewer/              # ⭐ PDF 뷰어 + 마커 오버레이
    ├── note_editor/             # ⭐ Markdown 에디터 + Wiki-link + LaTeX
    ├── ocr/                     # ⭐ 로컬 LLM OCR (Ollama LLaVA, 플러그인 패턴)
    ├── file_manager/            # 파일 트리/검색
    ├── auth/                    # 인증
    ├── home/                    # 홈 (최근 노트)
    ├── profile/                 # 프로필
    └── settings/                # 설정
```

### Feature 내부 구조
```
features/{name}/
├── models/          # Freezed 데이터 모델 (@freezed)
├── pages/
│   ├── providers/   # Riverpod 상태관리 (@riverpod)
│   ├── screens/     # 화면 위젯 (ConsumerWidget)
│   └── widgets/     # feature 전용 위젯
├── queries/         # GET 요청 (비동기 Provider)
└── mutations/       # POST/PUT/DELETE 요청
```

---

## 6. 명명 규칙

| 타입 | 규칙 | 예시 |
|------|------|------|
| Screen | `*_screen.dart` | `workspace_screen.dart` |
| Widget | 기능명 | `pdf_page_overlay.dart` |
| Provider | `*_provider.dart` | `pdf_marker_provider.dart` |
| Query | `*_query.dart` | `get_me_query.dart` |
| Mutation | `*_mutation.dart` | `login_mutation.dart` |
| Model | `*_model.dart` | `pdf_marker_model.dart` |

---

## 7. 핵심 개발 규칙

### 코드 생성 (필수)
Freezed/Riverpod 모델 수정 후 **반드시** 실행:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Flutter 검증
```bash
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

### Riverpod Provider 패턴
```dart
// Query (조회) - @riverpod 어노테이션
@riverpod
Future<Data> someQuery(SomeQueryRef ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/endpoint');
  return Data.fromJson(response.data);
}

// Mutation (변경) - @riverpod class
@riverpod
class SomeMutation extends _$SomeMutation {
  @override
  FutureOr<Result?> build() => null;

  Future<Result> call({required String param}) async {
    state = const AsyncLoading();
    try {
      final response = await ref.read(dioProvider).post('/endpoint', data: {'param': param});
      final result = Result.fromJson(response.data);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
```

### ShadCN UI 사용
```dart
import 'package:shadcn_ui/shadcn_ui.dart';

ShadButton(onPressed: () {}, child: Text('Click'))
ShadCard(title: Text('Title'), child: ...)
ShadInput(placeholder: Text('Enter text'))
ShadToaster.of(context).show(ShadToast(title: Text('Success!')));
```

---

## 8. PDF ↔ 노트 연동 핵심 로직

### 마커 데이터 모델
```dart
@freezed
class PdfMarker with _$PdfMarker {
  const factory PdfMarker({
    required String id,
    required int pageNumber,       // P3, P5
    required MarkerColor color,    // red, yellow, green, blue, purple
    String? selectedText,          // 발췌 텍스트
    PdfRect? textRect,             // PDF 좌표
    String? capturedImagePath,     // 캡처 이미지 경로
  }) = _PdfMarker;
}
```

### PDF → 노트 (텍스트 선택 → 마커 생성)
1. PdfViewer의 `textSelectionParams.onTextSelectionChange` 콜백
2. 선택된 텍스트 + 페이지 번호 + PdfRect 좌표 추출
3. PdfMarker 생성 → noteProvider에 마커 라인 삽입
4. Markdown: `- 🔴 P3  선택된 텍스트...`

### 노트 → PDF (마커 클릭 → 페이지 점프)
1. Markdown 렌더러에서 마커 라인 (🔴 P3) 탭 감지
2. pdfMarkerProvider에서 해당 마커 조회
3. `PdfViewerController.goToRectInsidePage(pageNumber, textRect)`

### 영역 캡처 → 이미지 임베드
1. 캡처 모드에서 드래그로 영역 선택
2. `PdfPage.render()` 로 선택 영역 렌더링
3. `./captures/` 에 이미지 저장
4. Markdown: `- 🟡 P5\n  ![캡처](./captures/p5_capture.png)`

### OCR 폴백 (이미지 기반 PDF)
1. 영역 캡처 시 네이티브 텍스트 추출 실패 + OCR 활성화:
   - 캡처 이미지 → `OcrService.recognizeFile()` → Ollama LLaVA
   - 추출된 텍스트를 마커의 `selectedText`로 사용
2. 전체 페이지 OCR: `workspace_provider.ocrCurrentPage()`
   - `PdfPage.render()` → 메모리 PNG → Ollama → 마커 삽입
3. 플러그인 패턴: `OcrBackend` 인터페이스 → `ocr_registry.dart`
   - 새 백엔드 추가 = 1파일 + 레지스트리 1줄
4. 설정: Hive `ocr_settings` box (isEnabled, ollamaUrl, modelName)

---

## 9. 화면 라우트

| 화면 | 경로 | 설명 |
|------|------|------|
| Home | `/` | 최근 노트 목록, 빠른 열기 |
| Workspace | `/workspace` | **메인 3패널 (사이드바+PDF+에디터)** |
| Note Only | `/note/:id` | 노트만 편집 (PDF 없이) |
| Settings | `/settings` | 테마, 저장 경로, 마커 색상 설정 |
| Login | `/login` | 인증 |
| Profile | `/profile` | 프로필 |

---

## 10. Windows 주의사항

- `subprocess.run()` 사용 (os.execv 금지)
- `encoding='utf-8'` 항상 지정
- `json.dump(..., ensure_ascii=False)` (한국어 깨짐 방지)
- 파일 경로에 `\` 사용 시 raw string 또는 `/` 사용
