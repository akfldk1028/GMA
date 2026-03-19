// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrap_annotation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scrapAnnotationStoreHash() =>
    r'565e108b54b6495c89c0b8489943eafda653e314';

/// Persistent store for drawing annotations on scrap entries.
/// Maps elementId → List<DrawingStroke>.
/// Uses Hive JSON-in-Box pattern (same as ElementStore).
///
/// Copied from [ScrapAnnotationStore].
@ProviderFor(ScrapAnnotationStore)
final scrapAnnotationStoreProvider =
    NotifierProvider<ScrapAnnotationStore, int>.internal(
      ScrapAnnotationStore.new,
      name: r'scrapAnnotationStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scrapAnnotationStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ScrapAnnotationStore = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
