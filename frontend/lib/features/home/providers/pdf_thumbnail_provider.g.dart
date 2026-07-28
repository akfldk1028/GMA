// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_thumbnail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pdfThumbnailHash() => r'fda77be33ed3c4bec2680c4a48e27d40acd5a4a1';

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

/// Renders PDF first-page thumbnail as PNG bytes.
/// Cached per path by Riverpod — subsequent watches are instant.
///
/// Copied from [pdfThumbnail].
@ProviderFor(pdfThumbnail)
const pdfThumbnailProvider = PdfThumbnailFamily();

/// Renders PDF first-page thumbnail as PNG bytes.
/// Cached per path by Riverpod — subsequent watches are instant.
///
/// Copied from [pdfThumbnail].
class PdfThumbnailFamily extends Family<AsyncValue<Uint8List?>> {
  /// Renders PDF first-page thumbnail as PNG bytes.
  /// Cached per path by Riverpod — subsequent watches are instant.
  ///
  /// Copied from [pdfThumbnail].
  const PdfThumbnailFamily();

  /// Renders PDF first-page thumbnail as PNG bytes.
  /// Cached per path by Riverpod — subsequent watches are instant.
  ///
  /// Copied from [pdfThumbnail].
  PdfThumbnailProvider call(String pdfPath) {
    return PdfThumbnailProvider(pdfPath);
  }

  @override
  PdfThumbnailProvider getProviderOverride(
    covariant PdfThumbnailProvider provider,
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
  String? get name => r'pdfThumbnailProvider';
}

/// Renders PDF first-page thumbnail as PNG bytes.
/// Cached per path by Riverpod — subsequent watches are instant.
///
/// Copied from [pdfThumbnail].
class PdfThumbnailProvider extends AutoDisposeFutureProvider<Uint8List?> {
  /// Renders PDF first-page thumbnail as PNG bytes.
  /// Cached per path by Riverpod — subsequent watches are instant.
  ///
  /// Copied from [pdfThumbnail].
  PdfThumbnailProvider(String pdfPath)
    : this._internal(
        (ref) => pdfThumbnail(ref as PdfThumbnailRef, pdfPath),
        from: pdfThumbnailProvider,
        name: r'pdfThumbnailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pdfThumbnailHash,
        dependencies: PdfThumbnailFamily._dependencies,
        allTransitiveDependencies:
            PdfThumbnailFamily._allTransitiveDependencies,
        pdfPath: pdfPath,
      );

  PdfThumbnailProvider._internal(
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
  Override overrideWith(
    FutureOr<Uint8List?> Function(PdfThumbnailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PdfThumbnailProvider._internal(
        (ref) => create(ref as PdfThumbnailRef),
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
  AutoDisposeFutureProviderElement<Uint8List?> createElement() {
    return _PdfThumbnailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PdfThumbnailProvider && other.pdfPath == pdfPath;
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
mixin PdfThumbnailRef on AutoDisposeFutureProviderRef<Uint8List?> {
  /// The parameter `pdfPath` of this provider.
  String get pdfPath;
}

class _PdfThumbnailProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List?>
    with PdfThumbnailRef {
  _PdfThumbnailProviderElement(super.provider);

  @override
  String get pdfPath => (origin as PdfThumbnailProvider).pdfPath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
