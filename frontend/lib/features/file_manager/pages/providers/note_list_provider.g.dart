// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteListHash() => r'99bbf52ad1df4a65cba3efe58d4d39ee0e60a62b';

/// Provider that returns filtered and sorted note list
///
/// Copied from [noteList].
@ProviderFor(noteList)
final noteListProvider = AutoDisposeFutureProvider<List<NoteMetadata>>.internal(
  noteList,
  name: r'noteListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$noteListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NoteListRef = AutoDisposeFutureProviderRef<List<NoteMetadata>>;
String _$isNotesLoadingHash() => r'a8d57e58b022f03bfddfcdbe03bf95345f874bd5';

/// Helper provider to check if notes list is loading
///
/// Copied from [isNotesLoading].
@ProviderFor(isNotesLoading)
final isNotesLoadingProvider = AutoDisposeProvider<bool>.internal(
  isNotesLoading,
  name: r'isNotesLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isNotesLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsNotesLoadingRef = AutoDisposeProviderRef<bool>;
String _$notesCountHash() => r'3c62f9916e5e0b0d0733e925ad1ec1d655345914';

/// Helper provider to get notes count
///
/// Copied from [notesCount].
@ProviderFor(notesCount)
final notesCountProvider = AutoDisposeFutureProvider<int>.internal(
  notesCount,
  name: r'notesCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notesCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotesCountRef = AutoDisposeFutureProviderRef<int>;
String _$isSearchActiveHash() => r'e9d8d0eef0d2292ec9f9b8b9e414dd8dcfffba7f';

/// Helper provider to check if search is active
///
/// Copied from [isSearchActive].
@ProviderFor(isSearchActive)
final isSearchActiveProvider = AutoDisposeProvider<bool>.internal(
  isSearchActive,
  name: r'isSearchActiveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSearchActiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsSearchActiveRef = AutoDisposeProviderRef<bool>;
String _$noteListFilterHash() => r'efe5b4be5dd4e72c0962ecd0a29da1e6f2b72d58';

/// Provider for managing note list filter state
///
/// Copied from [NoteListFilter].
@ProviderFor(NoteListFilter)
final noteListFilterProvider =
    AutoDisposeNotifierProvider<NoteListFilter, NoteListState>.internal(
      NoteListFilter.new,
      name: r'noteListFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$noteListFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NoteListFilter = AutoDisposeNotifier<NoteListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
