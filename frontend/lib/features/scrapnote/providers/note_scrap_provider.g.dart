// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_scrap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteScrapHash() => r'c793069ac2aa8d258740649a448bf405be847f9c';

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

/// Bridge between note markdown content and the ScrapNote canvas panel.
///
/// Strategy:
/// - If note has `::: scrapnote` block → read `@el` IDs from block (source of truth)
/// - If no block → fallback to all elements for the current PDF from ElementStore
///
/// Sorting: by page number ascending, then by PDF Y-coordinate descending
/// (PDF origin is bottom-left, Y increases upward — higher top = higher on page).
///
/// Copied from [noteScrap].
@ProviderFor(noteScrap)
const noteScrapProvider = NoteScrapFamily();

/// Bridge between note markdown content and the ScrapNote canvas panel.
///
/// Strategy:
/// - If note has `::: scrapnote` block → read `@el` IDs from block (source of truth)
/// - If no block → fallback to all elements for the current PDF from ElementStore
///
/// Sorting: by page number ascending, then by PDF Y-coordinate descending
/// (PDF origin is bottom-left, Y increases upward — higher top = higher on page).
///
/// Copied from [noteScrap].
class NoteScrapFamily extends Family<List<ScrapElement>> {
  /// Bridge between note markdown content and the ScrapNote canvas panel.
  ///
  /// Strategy:
  /// - If note has `::: scrapnote` block → read `@el` IDs from block (source of truth)
  /// - If no block → fallback to all elements for the current PDF from ElementStore
  ///
  /// Sorting: by page number ascending, then by PDF Y-coordinate descending
  /// (PDF origin is bottom-left, Y increases upward — higher top = higher on page).
  ///
  /// Copied from [noteScrap].
  const NoteScrapFamily();

  /// Bridge between note markdown content and the ScrapNote canvas panel.
  ///
  /// Strategy:
  /// - If note has `::: scrapnote` block → read `@el` IDs from block (source of truth)
  /// - If no block → fallback to all elements for the current PDF from ElementStore
  ///
  /// Sorting: by page number ascending, then by PDF Y-coordinate descending
  /// (PDF origin is bottom-left, Y increases upward — higher top = higher on page).
  ///
  /// Copied from [noteScrap].
  NoteScrapProvider call(String noteId) {
    return NoteScrapProvider(noteId);
  }

  @override
  NoteScrapProvider getProviderOverride(covariant NoteScrapProvider provider) {
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
  String? get name => r'noteScrapProvider';
}

/// Bridge between note markdown content and the ScrapNote canvas panel.
///
/// Strategy:
/// - If note has `::: scrapnote` block → read `@el` IDs from block (source of truth)
/// - If no block → fallback to all elements for the current PDF from ElementStore
///
/// Sorting: by page number ascending, then by PDF Y-coordinate descending
/// (PDF origin is bottom-left, Y increases upward — higher top = higher on page).
///
/// Copied from [noteScrap].
class NoteScrapProvider extends AutoDisposeProvider<List<ScrapElement>> {
  /// Bridge between note markdown content and the ScrapNote canvas panel.
  ///
  /// Strategy:
  /// - If note has `::: scrapnote` block → read `@el` IDs from block (source of truth)
  /// - If no block → fallback to all elements for the current PDF from ElementStore
  ///
  /// Sorting: by page number ascending, then by PDF Y-coordinate descending
  /// (PDF origin is bottom-left, Y increases upward — higher top = higher on page).
  ///
  /// Copied from [noteScrap].
  NoteScrapProvider(String noteId)
    : this._internal(
        (ref) => noteScrap(ref as NoteScrapRef, noteId),
        from: noteScrapProvider,
        name: r'noteScrapProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$noteScrapHash,
        dependencies: NoteScrapFamily._dependencies,
        allTransitiveDependencies: NoteScrapFamily._allTransitiveDependencies,
        noteId: noteId,
      );

  NoteScrapProvider._internal(
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
    List<ScrapElement> Function(NoteScrapRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NoteScrapProvider._internal(
        (ref) => create(ref as NoteScrapRef),
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
  AutoDisposeProviderElement<List<ScrapElement>> createElement() {
    return _NoteScrapProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteScrapProvider && other.noteId == noteId;
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
mixin NoteScrapRef on AutoDisposeProviderRef<List<ScrapElement>> {
  /// The parameter `noteId` of this provider.
  String get noteId;
}

class _NoteScrapProviderElement
    extends AutoDisposeProviderElement<List<ScrapElement>>
    with NoteScrapRef {
  _NoteScrapProviderElement(super.provider);

  @override
  String get noteId => (origin as NoteScrapProvider).noteId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
