// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$drawingModeHash() => r'a9c1dd7e59ddc07a7ac87877b82d87a582d9d16c';

/// Global drawing mode state (tool, color, size, active toggle).
///
/// Copied from [DrawingMode].
@ProviderFor(DrawingMode)
final drawingModeProvider =
    NotifierProvider<DrawingMode, DrawingToolState>.internal(
      DrawingMode.new,
      name: r'drawingModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$drawingModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DrawingMode = Notifier<DrawingToolState>;
String _$drawingStrokesHash() => r'cc9358e0a8809e820ba066daecc631a908edd265';

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

abstract class _$DrawingStrokes
    extends BuildlessAutoDisposeAsyncNotifier<DrawingData> {
  late final String documentPath;

  FutureOr<DrawingData> build(String documentPath);
}

/// Per-document drawing strokes with undo/redo and persistence.
/// Uses document path as the family key instead of noteId.
///
/// Copied from [DrawingStrokes].
@ProviderFor(DrawingStrokes)
const drawingStrokesProvider = DrawingStrokesFamily();

/// Per-document drawing strokes with undo/redo and persistence.
/// Uses document path as the family key instead of noteId.
///
/// Copied from [DrawingStrokes].
class DrawingStrokesFamily extends Family<AsyncValue<DrawingData>> {
  /// Per-document drawing strokes with undo/redo and persistence.
  /// Uses document path as the family key instead of noteId.
  ///
  /// Copied from [DrawingStrokes].
  const DrawingStrokesFamily();

  /// Per-document drawing strokes with undo/redo and persistence.
  /// Uses document path as the family key instead of noteId.
  ///
  /// Copied from [DrawingStrokes].
  DrawingStrokesProvider call(String documentPath) {
    return DrawingStrokesProvider(documentPath);
  }

  @override
  DrawingStrokesProvider getProviderOverride(
    covariant DrawingStrokesProvider provider,
  ) {
    return call(provider.documentPath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'drawingStrokesProvider';
}

/// Per-document drawing strokes with undo/redo and persistence.
/// Uses document path as the family key instead of noteId.
///
/// Copied from [DrawingStrokes].
class DrawingStrokesProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DrawingStrokes, DrawingData> {
  /// Per-document drawing strokes with undo/redo and persistence.
  /// Uses document path as the family key instead of noteId.
  ///
  /// Copied from [DrawingStrokes].
  DrawingStrokesProvider(String documentPath)
    : this._internal(
        () => DrawingStrokes()..documentPath = documentPath,
        from: drawingStrokesProvider,
        name: r'drawingStrokesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$drawingStrokesHash,
        dependencies: DrawingStrokesFamily._dependencies,
        allTransitiveDependencies:
            DrawingStrokesFamily._allTransitiveDependencies,
        documentPath: documentPath,
      );

  DrawingStrokesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.documentPath,
  }) : super.internal();

  final String documentPath;

  @override
  FutureOr<DrawingData> runNotifierBuild(covariant DrawingStrokes notifier) {
    return notifier.build(documentPath);
  }

  @override
  Override overrideWith(DrawingStrokes Function() create) {
    return ProviderOverride(
      origin: this,
      override: DrawingStrokesProvider._internal(
        () => create()..documentPath = documentPath,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        documentPath: documentPath,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DrawingStrokes, DrawingData>
  createElement() {
    return _DrawingStrokesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DrawingStrokesProvider &&
        other.documentPath == documentPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, documentPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DrawingStrokesRef on AutoDisposeAsyncNotifierProviderRef<DrawingData> {
  /// The parameter `documentPath` of this provider.
  String get documentPath;
}

class _DrawingStrokesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DrawingStrokes, DrawingData>
    with DrawingStrokesRef {
  _DrawingStrokesProviderElement(super.provider);

  @override
  String get documentPath => (origin as DrawingStrokesProvider).documentPath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
