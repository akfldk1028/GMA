// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteListHash() => r'4cd56ad8b1d628062a53619b68aa97092d69a40c';

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
String _$isNotesLoadingHash() => r'b05433739ab8aa871f49602d525ce19871dad197';

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
String _$notesCountHash() => r'f9f337da596a65062b72176017279897e6cd74ee';

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
String _$isSearchActiveHash() => r'08740de92edfc5b51a4283629a3d620a001789ce';

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
