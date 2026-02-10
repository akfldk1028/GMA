// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteStorageServiceHash() =>
    r'9468fc9dac5567e20074d8a682628709c294a397';

/// Service for saving note content to filesystem with debouncing.
/// Prevents excessive file I/O by delaying writes until user stops typing.
///
/// Copied from [noteStorageService].
@ProviderFor(noteStorageService)
final noteStorageServiceProvider =
    AutoDisposeProvider<NoteStorageService>.internal(
      noteStorageService,
      name: r'noteStorageServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$noteStorageServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NoteStorageServiceRef = AutoDisposeProviderRef<NoteStorageService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
