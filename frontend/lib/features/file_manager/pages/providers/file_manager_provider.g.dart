// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fileManagerHash() => r'd302153275a969d247c91f0baeb555669cfaaf8e';

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
    r'c91c45a678f64b2efdff68fc261b293339d72a83';

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
    r'c9b7c576c48196ef32325d5b10969c643d4fcb3e';

/// Mutation provider for deleting a note
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
