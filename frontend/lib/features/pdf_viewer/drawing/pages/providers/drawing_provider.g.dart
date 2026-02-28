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
String _$drawingStrokesHash() => r'2bf04c667a17c5afdfccb5055ee626ededbdcf27';

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
  late final String noteId;

  FutureOr<DrawingData> build(String noteId);
}

/// Per-note drawing strokes with undo/redo and persistence.
///
/// Copied from [DrawingStrokes].
@ProviderFor(DrawingStrokes)
const drawingStrokesProvider = DrawingStrokesFamily();

/// Per-note drawing strokes with undo/redo and persistence.
///
/// Copied from [DrawingStrokes].
class DrawingStrokesFamily extends Family<AsyncValue<DrawingData>> {
  /// Per-note drawing strokes with undo/redo and persistence.
  ///
  /// Copied from [DrawingStrokes].
  const DrawingStrokesFamily();

  /// Per-note drawing strokes with undo/redo and persistence.
  ///
  /// Copied from [DrawingStrokes].
  DrawingStrokesProvider call(String noteId) {
    return DrawingStrokesProvider(noteId);
  }

  @override
  DrawingStrokesProvider getProviderOverride(
    covariant DrawingStrokesProvider provider,
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
  String? get name => r'drawingStrokesProvider';
}

/// Per-note drawing strokes with undo/redo and persistence.
///
/// Copied from [DrawingStrokes].
class DrawingStrokesProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DrawingStrokes, DrawingData> {
  /// Per-note drawing strokes with undo/redo and persistence.
  ///
  /// Copied from [DrawingStrokes].
  DrawingStrokesProvider(String noteId)
    : this._internal(
        () => DrawingStrokes()..noteId = noteId,
        from: drawingStrokesProvider,
        name: r'drawingStrokesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$drawingStrokesHash,
        dependencies: DrawingStrokesFamily._dependencies,
        allTransitiveDependencies:
            DrawingStrokesFamily._allTransitiveDependencies,
        noteId: noteId,
      );

  DrawingStrokesProvider._internal(
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
  FutureOr<DrawingData> runNotifierBuild(covariant DrawingStrokes notifier) {
    return notifier.build(noteId);
  }

  @override
  Override overrideWith(DrawingStrokes Function() create) {
    return ProviderOverride(
      origin: this,
      override: DrawingStrokesProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<DrawingStrokes, DrawingData>
  createElement() {
    return _DrawingStrokesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DrawingStrokesProvider && other.noteId == noteId;
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
mixin DrawingStrokesRef on AutoDisposeAsyncNotifierProviderRef<DrawingData> {
  /// The parameter `noteId` of this provider.
  String get noteId;
}

class _DrawingStrokesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DrawingStrokes, DrawingData>
    with DrawingStrokesRef {
  _DrawingStrokesProviderElement(super.provider);

  @override
  String get noteId => (origin as DrawingStrokesProvider).noteId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
