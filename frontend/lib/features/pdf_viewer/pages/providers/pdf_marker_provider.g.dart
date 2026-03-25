// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_marker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$markersForPageHash() => r'55e252f7e03793df07aafe050d6667d463e283b7';

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

/// Provider to get markers for a specific page number.
///
/// Copied from [markersForPage].
@ProviderFor(markersForPage)
const markersForPageProvider = MarkersForPageFamily();

/// Provider to get markers for a specific page number.
///
/// Copied from [markersForPage].
class MarkersForPageFamily extends Family<List<PdfMarker>> {
  /// Provider to get markers for a specific page number.
  ///
  /// Copied from [markersForPage].
  const MarkersForPageFamily();

  /// Provider to get markers for a specific page number.
  ///
  /// Copied from [markersForPage].
  MarkersForPageProvider call(int pageNumber) {
    return MarkersForPageProvider(pageNumber);
  }

  @override
  MarkersForPageProvider getProviderOverride(
    covariant MarkersForPageProvider provider,
  ) {
    return call(provider.pageNumber);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'markersForPageProvider';
}

/// Provider to get markers for a specific page number.
///
/// Copied from [markersForPage].
class MarkersForPageProvider extends AutoDisposeProvider<List<PdfMarker>> {
  /// Provider to get markers for a specific page number.
  ///
  /// Copied from [markersForPage].
  MarkersForPageProvider(int pageNumber)
    : this._internal(
        (ref) => markersForPage(ref as MarkersForPageRef, pageNumber),
        from: markersForPageProvider,
        name: r'markersForPageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$markersForPageHash,
        dependencies: MarkersForPageFamily._dependencies,
        allTransitiveDependencies:
            MarkersForPageFamily._allTransitiveDependencies,
        pageNumber: pageNumber,
      );

  MarkersForPageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pageNumber,
  }) : super.internal();

  final int pageNumber;

  @override
  Override overrideWith(
    List<PdfMarker> Function(MarkersForPageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarkersForPageProvider._internal(
        (ref) => create(ref as MarkersForPageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pageNumber: pageNumber,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<PdfMarker>> createElement() {
    return _MarkersForPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkersForPageProvider && other.pageNumber == pageNumber;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pageNumber.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarkersForPageRef on AutoDisposeProviderRef<List<PdfMarker>> {
  /// The parameter `pageNumber` of this provider.
  int get pageNumber;
}

class _MarkersForPageProviderElement
    extends AutoDisposeProviderElement<List<PdfMarker>>
    with MarkersForPageRef {
  _MarkersForPageProviderElement(super.provider);

  @override
  int get pageNumber => (origin as MarkersForPageProvider).pageNumber;
}

String _$hasMarkersHash() => r'8294819a2b517aca4cc065c2fd43770fb150fa9f';

/// Provider to check if any markers exist.
///
/// Copied from [hasMarkers].
@ProviderFor(hasMarkers)
final hasMarkersProvider = AutoDisposeProvider<bool>.internal(
  hasMarkers,
  name: r'hasMarkersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasMarkersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasMarkersRef = AutoDisposeProviderRef<bool>;
String _$markerCountHash() => r'f2fb3a7f2fce11fc8778bc0b1351ffed9cbbc4f7';

/// Provider to get total marker count.
///
/// Copied from [markerCount].
@ProviderFor(markerCount)
final markerCountProvider = AutoDisposeProvider<int>.internal(
  markerCount,
  name: r'markerCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$markerCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarkerCountRef = AutoDisposeProviderRef<int>;
String _$pdfMarkerStateHash() => r'5ae20c521c2c5ca22cc93f0a9879a804d841a6b5';

/// Provider for managing PDF markers with Hive storage.
/// Uses marker ID as Hive key for safe CRUD (no index-based access).
///
/// Copied from [PdfMarkerState].
@ProviderFor(PdfMarkerState)
final pdfMarkerStateProvider =
    AutoDisposeAsyncNotifierProvider<PdfMarkerState, List<PdfMarker>>.internal(
      PdfMarkerState.new,
      name: r'pdfMarkerStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pdfMarkerStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PdfMarkerState = AutoDisposeAsyncNotifier<List<PdfMarker>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
