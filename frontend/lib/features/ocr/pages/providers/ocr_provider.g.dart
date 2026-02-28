// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ocrRecognizeHash() => r'f24c3843caa2ff4ac6604f854fcbca3690ee3ecf';

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

/// One-shot OCR recognition on an image file.
///
/// Copied from [ocrRecognize].
@ProviderFor(ocrRecognize)
const ocrRecognizeProvider = OcrRecognizeFamily();

/// One-shot OCR recognition on an image file.
///
/// Copied from [ocrRecognize].
class OcrRecognizeFamily extends Family<AsyncValue<String>> {
  /// One-shot OCR recognition on an image file.
  ///
  /// Copied from [ocrRecognize].
  const OcrRecognizeFamily();

  /// One-shot OCR recognition on an image file.
  ///
  /// Copied from [ocrRecognize].
  OcrRecognizeProvider call({required String imagePath}) {
    return OcrRecognizeProvider(imagePath: imagePath);
  }

  @override
  OcrRecognizeProvider getProviderOverride(
    covariant OcrRecognizeProvider provider,
  ) {
    return call(imagePath: provider.imagePath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ocrRecognizeProvider';
}

/// One-shot OCR recognition on an image file.
///
/// Copied from [ocrRecognize].
class OcrRecognizeProvider extends AutoDisposeFutureProvider<String> {
  /// One-shot OCR recognition on an image file.
  ///
  /// Copied from [ocrRecognize].
  OcrRecognizeProvider({required String imagePath})
    : this._internal(
        (ref) => ocrRecognize(ref as OcrRecognizeRef, imagePath: imagePath),
        from: ocrRecognizeProvider,
        name: r'ocrRecognizeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ocrRecognizeHash,
        dependencies: OcrRecognizeFamily._dependencies,
        allTransitiveDependencies:
            OcrRecognizeFamily._allTransitiveDependencies,
        imagePath: imagePath,
      );

  OcrRecognizeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.imagePath,
  }) : super.internal();

  final String imagePath;

  @override
  Override overrideWith(
    FutureOr<String> Function(OcrRecognizeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OcrRecognizeProvider._internal(
        (ref) => create(ref as OcrRecognizeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        imagePath: imagePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _OcrRecognizeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OcrRecognizeProvider && other.imagePath == imagePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, imagePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OcrRecognizeRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `imagePath` of this provider.
  String get imagePath;
}

class _OcrRecognizeProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with OcrRecognizeRef {
  _OcrRecognizeProviderElement(super.provider);

  @override
  String get imagePath => (origin as OcrRecognizeProvider).imagePath;
}

String _$ocrSettingsHash() => r'9b9509d35e7b88d91dab7d4fc22f5bcaa8f2ce73';

/// Persisted OCR settings (Hive).
///
/// Copied from [OcrSettings].
@ProviderFor(OcrSettings)
final ocrSettingsProvider =
    AsyncNotifierProvider<OcrSettings, OcrSettingsData>.internal(
      OcrSettings.new,
      name: r'ocrSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ocrSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OcrSettings = AsyncNotifier<OcrSettingsData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
