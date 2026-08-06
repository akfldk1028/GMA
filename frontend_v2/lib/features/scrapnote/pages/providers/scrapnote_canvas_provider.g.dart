// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrapnote_canvas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scrapnoteCanvasHash() => r'558a94915d9411631504a090ec7f267af1e0c01c';

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

abstract class _$ScrapnoteCanvas
    extends BuildlessAutoDisposeAsyncNotifier<ScrapnoteCanvasData> {
  late final String pdfPath;

  FutureOr<ScrapnoteCanvasData> build(String pdfPath);
}

/// Per-PDF scrapnote canvas state with undo/redo and auto-save.
/// Keyed by the PDF file path (same key as DrawingStrokes provider).
///
/// Copied from [ScrapnoteCanvas].
@ProviderFor(ScrapnoteCanvas)
const scrapnoteCanvasProvider = ScrapnoteCanvasFamily();

/// Per-PDF scrapnote canvas state with undo/redo and auto-save.
/// Keyed by the PDF file path (same key as DrawingStrokes provider).
///
/// Copied from [ScrapnoteCanvas].
class ScrapnoteCanvasFamily extends Family<AsyncValue<ScrapnoteCanvasData>> {
  /// Per-PDF scrapnote canvas state with undo/redo and auto-save.
  /// Keyed by the PDF file path (same key as DrawingStrokes provider).
  ///
  /// Copied from [ScrapnoteCanvas].
  const ScrapnoteCanvasFamily();

  /// Per-PDF scrapnote canvas state with undo/redo and auto-save.
  /// Keyed by the PDF file path (same key as DrawingStrokes provider).
  ///
  /// Copied from [ScrapnoteCanvas].
  ScrapnoteCanvasProvider call(String pdfPath) {
    return ScrapnoteCanvasProvider(pdfPath);
  }

  @override
  ScrapnoteCanvasProvider getProviderOverride(
    covariant ScrapnoteCanvasProvider provider,
  ) {
    return call(provider.pdfPath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'scrapnoteCanvasProvider';
}

/// Per-PDF scrapnote canvas state with undo/redo and auto-save.
/// Keyed by the PDF file path (same key as DrawingStrokes provider).
///
/// Copied from [ScrapnoteCanvas].
class ScrapnoteCanvasProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ScrapnoteCanvas,
          ScrapnoteCanvasData
        > {
  /// Per-PDF scrapnote canvas state with undo/redo and auto-save.
  /// Keyed by the PDF file path (same key as DrawingStrokes provider).
  ///
  /// Copied from [ScrapnoteCanvas].
  ScrapnoteCanvasProvider(String pdfPath)
    : this._internal(
        () => ScrapnoteCanvas()..pdfPath = pdfPath,
        from: scrapnoteCanvasProvider,
        name: r'scrapnoteCanvasProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$scrapnoteCanvasHash,
        dependencies: ScrapnoteCanvasFamily._dependencies,
        allTransitiveDependencies:
            ScrapnoteCanvasFamily._allTransitiveDependencies,
        pdfPath: pdfPath,
      );

  ScrapnoteCanvasProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pdfPath,
  }) : super.internal();

  final String pdfPath;

  @override
  FutureOr<ScrapnoteCanvasData> runNotifierBuild(
    covariant ScrapnoteCanvas notifier,
  ) {
    return notifier.build(pdfPath);
  }

  @override
  Override overrideWith(ScrapnoteCanvas Function() create) {
    return ProviderOverride(
      origin: this,
      override: ScrapnoteCanvasProvider._internal(
        () => create()..pdfPath = pdfPath,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pdfPath: pdfPath,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ScrapnoteCanvas, ScrapnoteCanvasData>
  createElement() {
    return _ScrapnoteCanvasProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScrapnoteCanvasProvider && other.pdfPath == pdfPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pdfPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ScrapnoteCanvasRef
    on AutoDisposeAsyncNotifierProviderRef<ScrapnoteCanvasData> {
  /// The parameter `pdfPath` of this provider.
  String get pdfPath;
}

class _ScrapnoteCanvasProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ScrapnoteCanvas,
          ScrapnoteCanvasData
        >
    with ScrapnoteCanvasRef {
  _ScrapnoteCanvasProviderElement(super.provider);

  @override
  String get pdfPath => (origin as ScrapnoteCanvasProvider).pdfPath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
