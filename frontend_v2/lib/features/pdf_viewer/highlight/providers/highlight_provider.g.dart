// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$highlightMarkersHash() => r'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0';

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

abstract class _$HighlightMarkers
    extends
        BuildlessAutoDisposeNotifier<Map<int, List<HighlightMarkerData>>> {
  late final String documentPath;

  Map<int, List<HighlightMarkerData>> build(String documentPath);
}

/// Derives per-page [HighlightMarkerData] from the flat [ElementStoreNotifier]
/// state, filtered to [documentPath] and [ScrapElementType.highlight] only.
///
/// Copied from [HighlightMarkers].
@ProviderFor(HighlightMarkers)
const highlightMarkersProvider = HighlightMarkersFamily();

/// Derives per-page [HighlightMarkerData] from the flat [ElementStoreNotifier]
/// state, filtered to [documentPath] and [ScrapElementType.highlight] only.
///
/// Copied from [HighlightMarkers].
class HighlightMarkersFamily
    extends Family<Map<int, List<HighlightMarkerData>>> {
  /// Derives per-page [HighlightMarkerData] from the flat [ElementStoreNotifier]
  /// state, filtered to [documentPath] and [ScrapElementType.highlight] only.
  ///
  /// Copied from [HighlightMarkers].
  const HighlightMarkersFamily();

  /// Derives per-page [HighlightMarkerData] from the flat [ElementStoreNotifier]
  /// state, filtered to [documentPath] and [ScrapElementType.highlight] only.
  ///
  /// Copied from [HighlightMarkers].
  HighlightMarkersProvider call(String documentPath) {
    return HighlightMarkersProvider(documentPath);
  }

  @override
  HighlightMarkersProvider getProviderOverride(
    covariant HighlightMarkersProvider provider,
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
  String? get name => r'highlightMarkersProvider';
}

/// Derives per-page [HighlightMarkerData] from the flat [ElementStoreNotifier]
/// state, filtered to [documentPath] and [ScrapElementType.highlight] only.
///
/// Copied from [HighlightMarkers].
class HighlightMarkersProvider
    extends
        AutoDisposeNotifierProviderImpl<
          HighlightMarkers,
          Map<int, List<HighlightMarkerData>>
        > {
  /// Derives per-page [HighlightMarkerData] from the flat [ElementStoreNotifier]
  /// state, filtered to [documentPath] and [ScrapElementType.highlight] only.
  ///
  /// Copied from [HighlightMarkers].
  HighlightMarkersProvider(String documentPath)
    : this._internal(
        () => HighlightMarkers()..documentPath = documentPath,
        from: highlightMarkersProvider,
        name: r'highlightMarkersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$highlightMarkersHash,
        dependencies: HighlightMarkersFamily._dependencies,
        allTransitiveDependencies:
            HighlightMarkersFamily._allTransitiveDependencies,
        documentPath: documentPath,
      );

  HighlightMarkersProvider._internal(
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
  Map<int, List<HighlightMarkerData>> runNotifierBuild(
    covariant HighlightMarkers notifier,
  ) {
    return notifier.build(documentPath);
  }

  @override
  Override overrideWith(HighlightMarkers Function() create) {
    return ProviderOverride(
      origin: this,
      override: HighlightMarkersProvider._internal(
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
  AutoDisposeNotifierProviderElement<
    HighlightMarkers,
    Map<int, List<HighlightMarkerData>>
  >
  createElement() {
    return _HighlightMarkersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HighlightMarkersProvider &&
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
mixin HighlightMarkersRef
    on
        AutoDisposeNotifierProviderRef<Map<int, List<HighlightMarkerData>>> {
  /// The parameter `documentPath` of this provider.
  String get documentPath;
}

class _HighlightMarkersProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          HighlightMarkers,
          Map<int, List<HighlightMarkerData>>
        >
    with HighlightMarkersRef {
  _HighlightMarkersProviderElement(super.provider);

  @override
  String get documentPath =>
      (origin as HighlightMarkersProvider).documentPath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
