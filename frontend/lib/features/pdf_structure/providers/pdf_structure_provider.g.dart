// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_structure_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$structureElementsForPageHash() =>
    r'09b170960d44408e0669be19a75ce706a4c711cf';

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

/// Convenience provider: elements for a specific page.
///
/// Copied from [structureElementsForPage].
@ProviderFor(structureElementsForPage)
const structureElementsForPageProvider = StructureElementsForPageFamily();

/// Convenience provider: elements for a specific page.
///
/// Copied from [structureElementsForPage].
class StructureElementsForPageFamily extends Family<List<StructureElement>> {
  /// Convenience provider: elements for a specific page.
  ///
  /// Copied from [structureElementsForPage].
  const StructureElementsForPageFamily();

  /// Convenience provider: elements for a specific page.
  ///
  /// Copied from [structureElementsForPage].
  StructureElementsForPageProvider call(int pageNumber) {
    return StructureElementsForPageProvider(pageNumber);
  }

  @override
  StructureElementsForPageProvider getProviderOverride(
    covariant StructureElementsForPageProvider provider,
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
  String? get name => r'structureElementsForPageProvider';
}

/// Convenience provider: elements for a specific page.
///
/// Copied from [structureElementsForPage].
class StructureElementsForPageProvider
    extends AutoDisposeProvider<List<StructureElement>> {
  /// Convenience provider: elements for a specific page.
  ///
  /// Copied from [structureElementsForPage].
  StructureElementsForPageProvider(int pageNumber)
    : this._internal(
        (ref) => structureElementsForPage(
          ref as StructureElementsForPageRef,
          pageNumber,
        ),
        from: structureElementsForPageProvider,
        name: r'structureElementsForPageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$structureElementsForPageHash,
        dependencies: StructureElementsForPageFamily._dependencies,
        allTransitiveDependencies:
            StructureElementsForPageFamily._allTransitiveDependencies,
        pageNumber: pageNumber,
      );

  StructureElementsForPageProvider._internal(
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
    List<StructureElement> Function(StructureElementsForPageRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StructureElementsForPageProvider._internal(
        (ref) => create(ref as StructureElementsForPageRef),
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
  AutoDisposeProviderElement<List<StructureElement>> createElement() {
    return _StructureElementsForPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StructureElementsForPageProvider &&
        other.pageNumber == pageNumber;
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
mixin StructureElementsForPageRef
    on AutoDisposeProviderRef<List<StructureElement>> {
  /// The parameter `pageNumber` of this provider.
  int get pageNumber;
}

class _StructureElementsForPageProviderElement
    extends AutoDisposeProviderElement<List<StructureElement>>
    with StructureElementsForPageRef {
  _StructureElementsForPageProviderElement(super.provider);

  @override
  int get pageNumber => (origin as StructureElementsForPageProvider).pageNumber;
}

String _$structureHeadingsHash() => r'b4488b0d81d7e93b9a62c235ce1f8fd421880995';

/// Convenience provider: heading list for sidebar tree.
///
/// Copied from [structureHeadings].
@ProviderFor(structureHeadings)
final structureHeadingsProvider =
    AutoDisposeProvider<List<StructureElement>>.internal(
      structureHeadings,
      name: r'structureHeadingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$structureHeadingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StructureHeadingsRef = AutoDisposeProviderRef<List<StructureElement>>;
String _$pdfStructureHash() => r'436aa83f0d9d7177c43b5cd7ae711a501709ab5a';

/// Provider managing PDF structure analysis state.
///
/// Integrates with WorkspaceProvider: call [analyze] when a PDF is loaded,
/// then use [elementsForPage] to get structure data for overlays/sidebar.
///
/// Copied from [PdfStructure].
@ProviderFor(PdfStructure)
final pdfStructureProvider =
    NotifierProvider<PdfStructure, PdfStructureState>.internal(
      PdfStructure.new,
      name: r'pdfStructureProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pdfStructureHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PdfStructure = Notifier<PdfStructureState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
