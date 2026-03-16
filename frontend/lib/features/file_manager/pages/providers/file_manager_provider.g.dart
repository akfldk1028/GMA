// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fileManagerHash() => r'0bfc9afb627115c83f77ef6f328365c649da4ad2';

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
    r'b383608670d3e72f82099e5912b6f3dbd7cebef0';

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
    r'4317cffb7eace24810af316fbe1842a76d3f3847';

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
    r'7553cabcad546f1e572ab5259a61d63ef7f50312';

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
