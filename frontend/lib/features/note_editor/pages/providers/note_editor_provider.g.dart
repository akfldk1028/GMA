// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteEditorHash() => r'3e7b2e3de0a8f331d6f3ea24a966b6cedeccce6f';

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

abstract class _$NoteEditor
    extends BuildlessAutoDisposeNotifier<TextEditingController?> {
  late final String noteId;

  TextEditingController? build(String noteId);
}

/// Provider that manages the text editing controller for a note editor.
///
/// This provider:
/// - Creates and manages a TextEditingController initialized with note content
/// - Provides insertMarker() method to add marker lines at cursor position
/// - Handles text truncation (150 chars max with ellipsis)
/// - Provides saveContent() method to persist changes to noteProvider
///
/// Usage:
/// ```dart
/// final controller = ref.watch(noteEditorProvider('note-id-123'));
/// controller?.text // access text
///
/// // Insert marker
/// await ref.read(noteEditorProvider('note-id-123').notifier)
///   .insertMarker(color: MarkerColor.red, pageNumber: 3, text: 'selected text...');
/// ```
///
/// Copied from [NoteEditor].
@ProviderFor(NoteEditor)
const noteEditorProvider = NoteEditorFamily();

/// Provider that manages the text editing controller for a note editor.
///
/// This provider:
/// - Creates and manages a TextEditingController initialized with note content
/// - Provides insertMarker() method to add marker lines at cursor position
/// - Handles text truncation (150 chars max with ellipsis)
/// - Provides saveContent() method to persist changes to noteProvider
///
/// Usage:
/// ```dart
/// final controller = ref.watch(noteEditorProvider('note-id-123'));
/// controller?.text // access text
///
/// // Insert marker
/// await ref.read(noteEditorProvider('note-id-123').notifier)
///   .insertMarker(color: MarkerColor.red, pageNumber: 3, text: 'selected text...');
/// ```
///
/// Copied from [NoteEditor].
class NoteEditorFamily extends Family<TextEditingController?> {
  /// Provider that manages the text editing controller for a note editor.
  ///
  /// This provider:
  /// - Creates and manages a TextEditingController initialized with note content
  /// - Provides insertMarker() method to add marker lines at cursor position
  /// - Handles text truncation (150 chars max with ellipsis)
  /// - Provides saveContent() method to persist changes to noteProvider
  ///
  /// Usage:
  /// ```dart
  /// final controller = ref.watch(noteEditorProvider('note-id-123'));
  /// controller?.text // access text
  ///
  /// // Insert marker
  /// await ref.read(noteEditorProvider('note-id-123').notifier)
  ///   .insertMarker(color: MarkerColor.red, pageNumber: 3, text: 'selected text...');
  /// ```
  ///
  /// Copied from [NoteEditor].
  const NoteEditorFamily();

  /// Provider that manages the text editing controller for a note editor.
  ///
  /// This provider:
  /// - Creates and manages a TextEditingController initialized with note content
  /// - Provides insertMarker() method to add marker lines at cursor position
  /// - Handles text truncation (150 chars max with ellipsis)
  /// - Provides saveContent() method to persist changes to noteProvider
  ///
  /// Usage:
  /// ```dart
  /// final controller = ref.watch(noteEditorProvider('note-id-123'));
  /// controller?.text // access text
  ///
  /// // Insert marker
  /// await ref.read(noteEditorProvider('note-id-123').notifier)
  ///   .insertMarker(color: MarkerColor.red, pageNumber: 3, text: 'selected text...');
  /// ```
  ///
  /// Copied from [NoteEditor].
  NoteEditorProvider call(String noteId) {
    return NoteEditorProvider(noteId);
  }

  @override
  NoteEditorProvider getProviderOverride(
    covariant NoteEditorProvider provider,
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
  String? get name => r'noteEditorProvider';
}

/// Provider that manages the text editing controller for a note editor.
///
/// This provider:
/// - Creates and manages a TextEditingController initialized with note content
/// - Provides insertMarker() method to add marker lines at cursor position
/// - Handles text truncation (150 chars max with ellipsis)
/// - Provides saveContent() method to persist changes to noteProvider
///
/// Usage:
/// ```dart
/// final controller = ref.watch(noteEditorProvider('note-id-123'));
/// controller?.text // access text
///
/// // Insert marker
/// await ref.read(noteEditorProvider('note-id-123').notifier)
///   .insertMarker(color: MarkerColor.red, pageNumber: 3, text: 'selected text...');
/// ```
///
/// Copied from [NoteEditor].
class NoteEditorProvider
    extends
        AutoDisposeNotifierProviderImpl<NoteEditor, TextEditingController?> {
  /// Provider that manages the text editing controller for a note editor.
  ///
  /// This provider:
  /// - Creates and manages a TextEditingController initialized with note content
  /// - Provides insertMarker() method to add marker lines at cursor position
  /// - Handles text truncation (150 chars max with ellipsis)
  /// - Provides saveContent() method to persist changes to noteProvider
  ///
  /// Usage:
  /// ```dart
  /// final controller = ref.watch(noteEditorProvider('note-id-123'));
  /// controller?.text // access text
  ///
  /// // Insert marker
  /// await ref.read(noteEditorProvider('note-id-123').notifier)
  ///   .insertMarker(color: MarkerColor.red, pageNumber: 3, text: 'selected text...');
  /// ```
  ///
  /// Copied from [NoteEditor].
  NoteEditorProvider(String noteId)
    : this._internal(
        () => NoteEditor()..noteId = noteId,
        from: noteEditorProvider,
        name: r'noteEditorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$noteEditorHash,
        dependencies: NoteEditorFamily._dependencies,
        allTransitiveDependencies: NoteEditorFamily._allTransitiveDependencies,
        noteId: noteId,
      );

  NoteEditorProvider._internal(
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
  TextEditingController? runNotifierBuild(covariant NoteEditor notifier) {
    return notifier.build(noteId);
  }

  @override
  Override overrideWith(NoteEditor Function() create) {
    return ProviderOverride(
      origin: this,
      override: NoteEditorProvider._internal(
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
  AutoDisposeNotifierProviderElement<NoteEditor, TextEditingController?>
  createElement() {
    return _NoteEditorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteEditorProvider && other.noteId == noteId;
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
mixin NoteEditorRef on AutoDisposeNotifierProviderRef<TextEditingController?> {
  /// The parameter `noteId` of this provider.
  String get noteId;
}

class _NoteEditorProviderElement
    extends
        AutoDisposeNotifierProviderElement<NoteEditor, TextEditingController?>
    with NoteEditorRef {
  _NoteEditorProviderElement(super.provider);

  @override
  String get noteId => (origin as NoteEditorProvider).noteId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
