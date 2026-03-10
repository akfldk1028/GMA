// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrapnote_canvas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scrapnoteCanvasStateHash() =>
    r'b98fdf57c14e5358f29225111538ff6fa1b1fc88';

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

abstract class _$ScrapnoteCanvasState
    extends BuildlessAutoDisposeAsyncNotifier<ScrapnoteCanvasData> {
  late final String scrapnoteId;

  FutureOr<ScrapnoteCanvasData> build(String scrapnoteId);
}

/// Per-scrapnote canvas state with undo/redo stack and debounced auto-save.
///
/// Key differences from [DrawingStrokes]:
/// - Strokes are stored as a flat list (no per-page map) — scrapnote has one infinite canvas.
/// - Undo/redo is global across all strokes.
/// - Also manages [CanvasElement] CRUD (add, remove, reposition).
/// - Persists to `.gma` files via [ScrapnoteSerializer].
///
/// Copied from [ScrapnoteCanvasState].
@ProviderFor(ScrapnoteCanvasState)
const scrapnoteCanvasStateProvider = ScrapnoteCanvasStateFamily();

/// Per-scrapnote canvas state with undo/redo stack and debounced auto-save.
///
/// Key differences from [DrawingStrokes]:
/// - Strokes are stored as a flat list (no per-page map) — scrapnote has one infinite canvas.
/// - Undo/redo is global across all strokes.
/// - Also manages [CanvasElement] CRUD (add, remove, reposition).
/// - Persists to `.gma` files via [ScrapnoteSerializer].
///
/// Copied from [ScrapnoteCanvasState].
class ScrapnoteCanvasStateFamily
    extends Family<AsyncValue<ScrapnoteCanvasData>> {
  /// Per-scrapnote canvas state with undo/redo stack and debounced auto-save.
  ///
  /// Key differences from [DrawingStrokes]:
  /// - Strokes are stored as a flat list (no per-page map) — scrapnote has one infinite canvas.
  /// - Undo/redo is global across all strokes.
  /// - Also manages [CanvasElement] CRUD (add, remove, reposition).
  /// - Persists to `.gma` files via [ScrapnoteSerializer].
  ///
  /// Copied from [ScrapnoteCanvasState].
  const ScrapnoteCanvasStateFamily();

  /// Per-scrapnote canvas state with undo/redo stack and debounced auto-save.
  ///
  /// Key differences from [DrawingStrokes]:
  /// - Strokes are stored as a flat list (no per-page map) — scrapnote has one infinite canvas.
  /// - Undo/redo is global across all strokes.
  /// - Also manages [CanvasElement] CRUD (add, remove, reposition).
  /// - Persists to `.gma` files via [ScrapnoteSerializer].
  ///
  /// Copied from [ScrapnoteCanvasState].
  ScrapnoteCanvasStateProvider call(String scrapnoteId) {
    return ScrapnoteCanvasStateProvider(scrapnoteId);
  }

  @override
  ScrapnoteCanvasStateProvider getProviderOverride(
    covariant ScrapnoteCanvasStateProvider provider,
  ) {
    return call(provider.scrapnoteId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'scrapnoteCanvasStateProvider';
}

/// Per-scrapnote canvas state with undo/redo stack and debounced auto-save.
///
/// Key differences from [DrawingStrokes]:
/// - Strokes are stored as a flat list (no per-page map) — scrapnote has one infinite canvas.
/// - Undo/redo is global across all strokes.
/// - Also manages [CanvasElement] CRUD (add, remove, reposition).
/// - Persists to `.gma` files via [ScrapnoteSerializer].
///
/// Copied from [ScrapnoteCanvasState].
class ScrapnoteCanvasStateProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ScrapnoteCanvasState,
          ScrapnoteCanvasData
        > {
  /// Per-scrapnote canvas state with undo/redo stack and debounced auto-save.
  ///
  /// Key differences from [DrawingStrokes]:
  /// - Strokes are stored as a flat list (no per-page map) — scrapnote has one infinite canvas.
  /// - Undo/redo is global across all strokes.
  /// - Also manages [CanvasElement] CRUD (add, remove, reposition).
  /// - Persists to `.gma` files via [ScrapnoteSerializer].
  ///
  /// Copied from [ScrapnoteCanvasState].
  ScrapnoteCanvasStateProvider(String scrapnoteId)
    : this._internal(
        () => ScrapnoteCanvasState()..scrapnoteId = scrapnoteId,
        from: scrapnoteCanvasStateProvider,
        name: r'scrapnoteCanvasStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$scrapnoteCanvasStateHash,
        dependencies: ScrapnoteCanvasStateFamily._dependencies,
        allTransitiveDependencies:
            ScrapnoteCanvasStateFamily._allTransitiveDependencies,
        scrapnoteId: scrapnoteId,
      );

  ScrapnoteCanvasStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scrapnoteId,
  }) : super.internal();

  final String scrapnoteId;

  @override
  FutureOr<ScrapnoteCanvasData> runNotifierBuild(
    covariant ScrapnoteCanvasState notifier,
  ) {
    return notifier.build(scrapnoteId);
  }

  @override
  Override overrideWith(ScrapnoteCanvasState Function() create) {
    return ProviderOverride(
      origin: this,
      override: ScrapnoteCanvasStateProvider._internal(
        () => create()..scrapnoteId = scrapnoteId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scrapnoteId: scrapnoteId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ScrapnoteCanvasState,
    ScrapnoteCanvasData
  >
  createElement() {
    return _ScrapnoteCanvasStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScrapnoteCanvasStateProvider &&
        other.scrapnoteId == scrapnoteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scrapnoteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ScrapnoteCanvasStateRef
    on AutoDisposeAsyncNotifierProviderRef<ScrapnoteCanvasData> {
  /// The parameter `scrapnoteId` of this provider.
  String get scrapnoteId;
}

class _ScrapnoteCanvasStateProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ScrapnoteCanvasState,
          ScrapnoteCanvasData
        >
    with ScrapnoteCanvasStateRef {
  _ScrapnoteCanvasStateProviderElement(super.provider);

  @override
  String get scrapnoteId =>
      (origin as ScrapnoteCanvasStateProvider).scrapnoteId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
