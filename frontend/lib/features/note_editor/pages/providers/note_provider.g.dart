// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteExistsHash() => r'c12b86b5397d3264740fac2af03e51838cec105f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Helper provider to check if a note exists.
///
/// Copied from [noteExists].
@ProviderFor(noteExists)
const noteExistsProvider = NoteExistsFamily();

/// Helper provider to check if a note exists.
///
/// Copied from [noteExists].
class NoteExistsFamily extends Family<AsyncValue<bool>> {
  /// Helper provider to check if a note exists.
  ///
  /// Copied from [noteExists].
  const NoteExistsFamily();

  /// Helper provider to check if a note exists.
  ///
  /// Copied from [noteExists].
  NoteExistsProvider call(String noteId) {
    return NoteExistsProvider(noteId);
  }

  @override
  NoteExistsProvider getProviderOverride(
    covariant NoteExistsProvider provider,
  ) {
    return call(provider.noteId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'noteExistsProvider';
}

/// Helper provider to check if a note exists.
///
/// Copied from [noteExists].
class NoteExistsProvider extends AutoDisposeFutureProvider<bool> {
  /// Helper provider to check if a note exists.
  ///
  /// Copied from [noteExists].
  NoteExistsProvider(String noteId)
    : this._internal(
        (ref) => noteExists(ref as NoteExistsRef, noteId),
        from: noteExistsProvider,
        name: r'noteExistsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$noteExistsHash,
        dependencies: NoteExistsFamily._dependencies,
        allTransitiveDependencies: NoteExistsFamily._allTransitiveDependencies,
        noteId: noteId,
      );

  NoteExistsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.noteId,
  }) : super.internal();

  final String noteId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(NoteExistsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NoteExistsProvider._internal(
        (ref) => create(ref as NoteExistsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        noteId: noteId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _NoteExistsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteExistsProvider && other.noteId == noteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, noteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoteExistsRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `noteId` of this provider.
  String get noteId;
}

class _NoteExistsProviderElement extends AutoDisposeFutureProviderElement<bool>
    with NoteExistsRef {
  _NoteExistsProviderElement(super.provider);

  @override
  String get noteId => (origin as NoteExistsProvider).noteId;
}

String _$noteStateHash() => r'fed53b5183b90c0304189431ab8c7aed9461b0a1';

abstract class _$NoteState extends BuildlessAutoDisposeAsyncNotifier<Note> {
  late final String noteId;

  FutureOr<Note> build(String noteId);
}

/// Provider that manages a single note's state, including content, markers, and frontmatter.
///
/// This provider:
/// - Loads note from file system based on noteId
/// - Parses frontmatter YAML from the note content
/// - Extracts markers from content using MarkerParser
/// - Handles edge cases: empty note, corrupted frontmatter
///
/// Usage:
/// ```dart
/// final note = ref.watch(noteProvider('note-id-123'));
/// ```
///
/// Copied from [NoteState].
@ProviderFor(NoteState)
const noteStateProvider = NoteStateFamily();

/// Provider that manages a single note's state, including content, markers, and frontmatter.
///
/// This provider:
/// - Loads note from file system based on noteId
/// - Parses frontmatter YAML from the note content
/// - Extracts markers from content using MarkerParser
/// - Handles edge cases: empty note, corrupted frontmatter
///
/// Usage:
/// ```dart
/// final note = ref.watch(noteProvider('note-id-123'));
/// ```
///
/// Copied from [NoteState].
class NoteStateFamily extends Family<AsyncValue<Note>> {
  /// Provider that manages a single note's state, including content, markers, and frontmatter.
  ///
  /// This provider:
  /// - Loads note from file system based on noteId
  /// - Parses frontmatter YAML from the note content
  /// - Extracts markers from content using MarkerParser
  /// - Handles edge cases: empty note, corrupted frontmatter
  ///
  /// Usage:
  /// ```dart
  /// final note = ref.watch(noteProvider('note-id-123'));
  /// ```
  ///
  /// Copied from [NoteState].
  const NoteStateFamily();

  /// Provider that manages a single note's state, including content, markers, and frontmatter.
  ///
  /// This provider:
  /// - Loads note from file system based on noteId
  /// - Parses frontmatter YAML from the note content
  /// - Extracts markers from content using MarkerParser
  /// - Handles edge cases: empty note, corrupted frontmatter
  ///
  /// Usage:
  /// ```dart
  /// final note = ref.watch(noteProvider('note-id-123'));
  /// ```
  ///
  /// Copied from [NoteState].
  NoteStateProvider call(String noteId) {
    return NoteStateProvider(noteId);
  }

  @override
  NoteStateProvider getProviderOverride(covariant NoteStateProvider provider) {
    return call(provider.noteId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'noteStateProvider';
}

/// Provider that manages a single note's state, including content, markers, and frontmatter.
///
/// This provider:
/// - Loads note from file system based on noteId
/// - Parses frontmatter YAML from the note content
/// - Extracts markers from content using MarkerParser
/// - Handles edge cases: empty note, corrupted frontmatter
///
/// Usage:
/// ```dart
/// final note = ref.watch(noteProvider('note-id-123'));
/// ```
///
/// Copied from [NoteState].
class NoteStateProvider
    extends AutoDisposeAsyncNotifierProviderImpl<NoteState, Note> {
  /// Provider that manages a single note's state, including content, markers, and frontmatter.
  ///
  /// This provider:
  /// - Loads note from file system based on noteId
  /// - Parses frontmatter YAML from the note content
  /// - Extracts markers from content using MarkerParser
  /// - Handles edge cases: empty note, corrupted frontmatter
  ///
  /// Usage:
  /// ```dart
  /// final note = ref.watch(noteProvider('note-id-123'));
  /// ```
  ///
  /// Copied from [NoteState].
  NoteStateProvider(String noteId)
    : this._internal(
        () => NoteState()..noteId = noteId,
        from: noteStateProvider,
        name: r'noteStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$noteStateHash,
        dependencies: NoteStateFamily._dependencies,
        allTransitiveDependencies: NoteStateFamily._allTransitiveDependencies,
        noteId: noteId,
      );

  NoteStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.noteId,
  }) : super.internal();

  final String noteId;

  @override
  FutureOr<Note> runNotifierBuild(covariant NoteState notifier) {
    return notifier.build(noteId);
  }

  @override
  Override overrideWith(NoteState Function() create) {
    return ProviderOverride(
      origin: this,
      override: NoteStateProvider._internal(
        () => create()..noteId = noteId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        noteId: noteId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<NoteState, Note> createElement() {
    return _NoteStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteStateProvider && other.noteId == noteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, noteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoteStateRef on AutoDisposeAsyncNotifierProviderRef<Note> {
  /// The parameter `noteId` of this provider.
  String get noteId;
}

class _NoteStateProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<NoteState, Note>
    with NoteStateRef {
  _NoteStateProviderElement(super.provider);

  @override
  String get noteId => (origin as NoteStateProvider).noteId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
