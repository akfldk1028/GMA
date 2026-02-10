---
name: gma-feature
description: |
  GMA 새 기능 개발 워크플로우. Feature-First 구조로 파일 생성, Freezed 모델, Riverpod 상태관리 포함.
  사용 시점: (1) 새 기능 추가 시, (2) 새 화면 개발 시, (3) API 연동 기능 구현 시
  사용 금지: 기존 기능 수정, 단순 UI 수정, 버그 수정, 리팩토링
argument-hint: "[기능 설명]"
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

# GMA Feature Development Skill

Feature-First 아키텍처로 새 기능을 개발합니다.

## When to Use
- 새로운 화면/기능 추가할 때
- CRUD 기능 구현 시
- API 연동이 필요한 기능 개발 시
- PDF ↔ 노트 연동 기능 확장 시

## When NOT to Use
- 기존 기능 수정 → 직접 파일 수정
- 단순 UI 수정 → 직접 위젯 수정
- 버그 수정 → 해당 파일 직접 수정
- 리팩토링 → 기존 구조 유지

## Quick Start
```bash
/gma-feature "PDF 북마크 관리"
/gma-feature "노트 태그 시스템"
```

새로운 기능을 체계적으로 개발합니다. 필요한 파일 구조를 자동으로 생성합니다.

## 사용법

```
/gma-feature "기능 설명"
```

### 예시
```
/gma-feature "PDF 북마크 관리"
/gma-feature "노트 태그 시스템"
/gma-feature "마커 색상 커스터마이징"
/gma-feature "노트 검색 기능"
```

## 기술 스택

| 역할 | 패키지 |
|------|--------|
| UI | shadcn_ui |
| 상태관리 | flutter_riverpod + riverpod_generator |
| 라우팅 | go_router |
| PDF | pdfrx |
| HTTP | dio |
| 로컬저장 | hive_flutter |
| 모델 | freezed + json_serializable |
| Markdown | markdown + flutter_math_fork |
| 파일 | path_provider + file_picker |

## 워크플로우

### Phase 1: 요구사항 분석
1. 기능 범위 파악
2. 필요한 데이터 모델 설계
3. PDF/노트 연동 여부 확인
4. 참조 코드 확인 (`C:\DK\GMA\clone\pdfrx`, `C:\DK\GMA\clone\printnotes`)

### Phase 2: 파일 구조 생성

#### Feature-First Architecture
```
frontend/lib/features/[feature_name]/
├── models/
│   └── [feature]_model.dart          # Freezed 모델
├── mutations/
│   └── [action]_mutation.dart        # POST/PUT/DELETE
├── queries/
│   └── get_[data]_query.dart         # GET 요청
└── pages/
    ├── providers/
    │   └── [feature]_provider.dart   # Riverpod 상태
    ├── screens/
    │   └── [feature]_screen.dart     # 화면 위젯
    └── widgets/
        └── [component].dart          # 재사용 위젯
```

### Phase 3: 코드 생성
1. Freezed 모델 생성
2. Riverpod provider 생성
3. API 연동 코드 (Dio) 또는 로컬 저장 (Hive)
4. UI 컴포넌트 (ShadCN UI)

### Phase 4: Auto-Claude 연동

복잡한 기능은 전문 에이전트 활용:

```bash
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\backend
.venv\Scripts\python.exe spec_runner.py --task "[기능 설명]"
```

## Feature 템플릿

### Model (Freezed)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[feature]_model.freezed.dart';
part '[feature]_model.g.dart';

@freezed
class [Feature]Model with _$[Feature]Model {
  const factory [Feature]Model({
    required String id,
    required String name,
    // ... fields
  }) = _[Feature]Model;

  factory [Feature]Model.fromJson(Map<String, dynamic> json) =>
      _$[Feature]ModelFromJson(json);
}
```

### Query (Riverpod)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_[feature]_query.g.dart';

@riverpod
Future<[Feature]Model> get[Feature]Query(Get[Feature]QueryRef ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/[feature]');
  return [Feature]Model.fromJson(response.data);
}
```

### Mutation (Riverpod)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '[action]_mutation.g.dart';

@riverpod
class [Action]Mutation extends _$[Action]Mutation {
  @override
  FutureOr<[Response]?> build() => null;

  Future<[Response]> call({required [Params] params}) async {
    state = const AsyncLoading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/api/[endpoint]', data: params.toJson());
      final result = [Response].fromJson(response.data);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
```

### Screen (ShadCN UI)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class [Feature]Screen extends ConsumerWidget {
  const [Feature]Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(get[Feature]QueryProvider);

    return Scaffold(
      body: dataAsync.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

## 코드 생성 후

파일 생성 후 반드시 실행:
```bash
cd C:\DK\GMA\frontend
dart run build_runner build --delete-conflicting-outputs
```

## 참조 코드

- **pdfrx** (`C:\DK\GMA\clone\pdfrx`): PdfViewer, PdfViewerController, PdfTextSelectionParams, PdfRect
- **printnotes** (`C:\DK\GMA\clone\printnotes`): Wiki-link 파싱, Markdown 렌더링, Frontmatter 처리

## 관련 Skills

- `/gma-build` - 빌드 실행
- `/gma-test` - 테스트 실행
