// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$elementStoreHash() => r'5f265773c7422055a00d7879e5ce657cf118eee2';

/// Persistent store for ScrapElements using Hive.
/// Follows the same JSON-in-Box<String> pattern as PdfRegistry.
///
/// Copied from [ElementStore].
@ProviderFor(ElementStore)
final elementStoreProvider = NotifierProvider<ElementStore, void>.internal(
  ElementStore.new,
  name: r'elementStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$elementStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ElementStore = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
