# GMA Feature Templates

## Feature 구조 템플릿

새 feature 생성 시 다음 구조를 따릅니다:

```
frontend/lib/features/[feature_name]/
├── models/
│   └── [feature]_model.dart
├── mutations/
│   └── [action]_mutation.dart
├── queries/
│   └── get_[data]_query.dart
└── pages/
    ├── providers/
    │   └── [feature]_provider.dart
    ├── screens/
    │   └── [feature]_screen.dart
    └── widgets/
        └── [widget_name].dart
```

---

## 1. Model Template (Freezed)

### `models/[feature]_model.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[feature]_model.freezed.dart';
part '[feature]_model.g.dart';

/// [Feature] 데이터 모델
@freezed
class [Feature]Model with _$[Feature]Model {
  const factory [Feature]Model({
    required String id,
    required String name,
    String? description,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _[Feature]Model;

  factory [Feature]Model.fromJson(Map<String, dynamic> json) =>
      _$[Feature]ModelFromJson(json);
}
```

---

## 2. Query Template (GET 요청)

### `queries/get_[feature]_query.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../utils/dio_provider.dart';
import '../models/[feature]_model.dart';

part 'get_[feature]_query.g.dart';

/// 단일 [Feature] 조회
@riverpod
Future<[Feature]Model> get[Feature]Query(
  Get[Feature]QueryRef ref, {
  required String id,
}) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/[feature]s/$id');
  return [Feature]Model.fromJson(response.data);
}

/// [Feature] 목록 조회
@riverpod
Future<List<[Feature]Model>> get[Feature]ListQuery(
  Get[Feature]ListQueryRef ref, {
  int page = 1,
  int limit = 20,
}) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/[feature]s', queryParameters: {
    'page': page,
    'limit': limit,
  });

  return (response.data as List)
      .map((item) => [Feature]Model.fromJson(item))
      .toList();
}
```

---

## 3. Mutation Template (POST/PUT/DELETE)

### `mutations/create_[feature]_mutation.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../utils/dio_provider.dart';
import '../models/[feature]_model.dart';

part 'create_[feature]_mutation.g.dart';

/// [Feature] 생성 Mutation
@riverpod
class Create[Feature]Mutation extends _$Create[Feature]Mutation {
  @override
  FutureOr<[Feature]Model?> build() => null;

  Future<[Feature]Model> call({
    required Create[Feature]Request request,
  }) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/api/[feature]s',
        data: request.toJson(),
      );

      final result = [Feature]Model.fromJson(response.data);
      state = AsyncData(result);

      // 관련 쿼리 무효화
      ref.invalidate(get[Feature]ListQueryProvider);

      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
```

---

## 4. Provider Template

### `pages/providers/[feature]_provider.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/[feature]_model.dart';

part '[feature]_provider.g.dart';

/// [Feature] 페이지 상태
@freezed
class [Feature]PageState with _$[Feature]PageState {
  const factory [Feature]PageState({
    @Default(false) bool isEditing,
    [Feature]Model? selectedItem,
    @Default('') String searchQuery,
  }) = _[Feature]PageState;
}

/// [Feature] 페이지 Provider
@riverpod
class [Feature]PageNotifier extends _$[Feature]PageNotifier {
  @override
  [Feature]PageState build() => const [Feature]PageState();

  void setEditing(bool value) {
    state = state.copyWith(isEditing: value);
  }

  void selectItem([Feature]Model? item) {
    state = state.copyWith(selectedItem: item);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
```

---

## 5. Screen Template (ShadCN UI)

### `pages/screens/[feature]_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../queries/get_[feature]_query.dart';
import '../providers/[feature]_provider.dart';

class [Feature]Screen extends ConsumerWidget {
  const [Feature]Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(get[Feature]ListQueryProvider());
    final pageState = ref.watch([feature]PageNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('[Feature]'),
        actions: [
          ShadButton.ghost(
            onPressed: () => _showAddDialog(context, ref),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: dataAsync.when(
        data: (items) => _buildList(items, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 16),
              ShadButton(
                onPressed: () => ref.invalidate(get[Feature]ListQueryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<[Feature]Model> items, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(child: Text('No items yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => [Feature]ListItem(item: items[index]),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement add dialog
  }
}
```

---

## GMA 특화: PDF 마커 모델 예시

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

## GMA 특화: Hive 로컬 저장 패턴

```dart
/// Hive box 초기화 (main.dart)
await Hive.initFlutter();
Hive.registerAdapter(NoteModelAdapter());
await Hive.openBox<NoteModel>('notes');

/// Provider에서 Hive 사용
@riverpod
Box<NoteModel> noteBox(NoteBoxRef ref) {
  return Hive.box<NoteModel>('notes');
}

@riverpod
List<NoteModel> allNotes(AllNotesRef ref) {
  final box = ref.watch(noteBoxProvider);
  return box.values.toList();
}
```

---

## 코드 생성 명령어

Feature 파일 생성 후 반드시 실행:

```bash
cd C:\DK\GMA\frontend
dart run build_runner build --delete-conflicting-outputs
```

Watch 모드 (개발 중 권장):

```bash
dart run build_runner watch --delete-conflicting-outputs
```
