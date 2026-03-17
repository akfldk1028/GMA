// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fileManagerHash() => r'ad788fc81f01b53bcd75b588f7f5b0acd5661f45';

/// See also [FileManager].
@ProviderFor(FileManager)
final fileManagerProvider =
    AutoDisposeAsyncNotifierProvider<FileManager, List<NoteMetadata>>.internal(
      FileManager.new,
      name: r'fileManagerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fileManagerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FileManager = AutoDisposeAsyncNotifier<List<NoteMetadata>>;
String _$createNoteMutationHash() =>
    r'8b6110afd99c9715f3c12d12abb085ee88434329';

/// Mutation provider for creating a new note
///
/// Copied from [CreateNoteMutation].
@ProviderFor(CreateNoteMutation)
final createNoteMutationProvider =
    AutoDisposeAsyncNotifierProvider<
      CreateNoteMutation,
      NoteMetadata?
    >.internal(
      CreateNoteMutation.new,
      name: r'createNoteMutationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createNoteMutationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CreateNoteMutation = AutoDisposeAsyncNotifier<NoteMetadata?>;
String _$deleteNoteMutationHash() =>
    r'1277531404d929dbd2843452b23d36777ee8ace0';

/// Mutation provider for soft-deleting a note (marks isDeleted in frontmatter)
///
/// Copied from [DeleteNoteMutation].
@ProviderFor(DeleteNoteMutation)
final deleteNoteMutationProvider =
    AutoDisposeAsyncNotifierProvider<DeleteNoteMutation, bool?>.internal(
      DeleteNoteMutation.new,
      name: r'deleteNoteMutationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteNoteMutationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeleteNoteMutation = AutoDisposeAsyncNotifier<bool?>;
String _$restoreNoteMutationHash() =>
    r'd32ddcf50ef50b5092cc6d53d754ec34c1f22df2';

/// Restore a soft-deleted note
///
/// Copied from [RestoreNoteMutation].
@ProviderFor(RestoreNoteMutation)
final restoreNoteMutationProvider =
    AutoDisposeAsyncNotifierProvider<RestoreNoteMutation, bool?>.internal(
      RestoreNoteMutation.new,
      name: r'restoreNoteMutationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$restoreNoteMutationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RestoreNoteMutation = AutoDisposeAsyncNotifier<bool?>;
String _$permanentDeleteMutationHash() =>
    r'c227ae64d94c9b6456cdee9b0f95d7be3af80ce4';

/// Permanently delete a note file
///
/// Copied from [PermanentDeleteMutation].
@ProviderFor(PermanentDeleteMutation)
final permanentDeleteMutationProvider =
    AutoDisposeAsyncNotifierProvider<PermanentDeleteMutation, bool?>.internal(
      PermanentDeleteMutation.new,
      name: r'permanentDeleteMutationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$permanentDeleteMutationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PermanentDeleteMutation = AutoDisposeAsyncNotifier<bool?>;
String _$moveToFolderMutationHash() =>
    r'8d976e8303541813d49e9dc627756f4a591062c1';

/// Move note to a folder
///
/// Copied from [MoveToFolderMutation].
@ProviderFor(MoveToFolderMutation)
final moveToFolderMutationProvider =
    AutoDisposeAsyncNotifierProvider<MoveToFolderMutation, bool?>.internal(
      MoveToFolderMutation.new,
      name: r'moveToFolderMutationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$moveToFolderMutationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MoveToFolderMutation = AutoDisposeAsyncNotifier<bool?>;
String _$togglePinMutationHash() => r'b3ed19db9c7c52824b7e7939a65346bdf37a308e';

/// Toggle pin/favorite on a note
///
/// Copied from [TogglePinMutation].
@ProviderFor(TogglePinMutation)
final togglePinMutationProvider =
    AutoDisposeAsyncNotifierProvider<TogglePinMutation, bool?>.internal(
      TogglePinMutation.new,
      name: r'togglePinMutationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$togglePinMutationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TogglePinMutation = AutoDisposeAsyncNotifier<bool?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
