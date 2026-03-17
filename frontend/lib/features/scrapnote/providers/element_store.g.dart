// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$elementStoreHash() => r'bc1bc72e4163c0df1e9e63be5a54550683d3ae72';

/// Persistent store for ScrapElements using Hive.
/// Follows the same JSON-in-Box pattern as PdfRegistry.
///
/// State is an int revision counter that increments on every mutation,
/// so widgets using `ref.watch(elementStoreProvider)` rebuild on changes.
///
/// Copied from [ElementStore].
@ProviderFor(ElementStore)
final elementStoreProvider = NotifierProvider<ElementStore, int>.internal(
  ElementStore.new,
  name: r'elementStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$elementStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ElementStore = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
