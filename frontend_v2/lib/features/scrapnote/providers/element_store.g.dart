// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$elementStoreNotifierHash() =>
    r'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0';

/// Hive-backed persistent store for all ScrapElement instances.
/// State is a flat list of all elements across all PDFs and types.
///
/// Copied from [ElementStoreNotifier].
@ProviderFor(ElementStoreNotifier)
final elementStoreNotifierProvider =
    NotifierProvider<ElementStoreNotifier, List<ScrapElement>>.internal(
      ElementStoreNotifier.new,
      name: r'elementStoreNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$elementStoreNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ElementStoreNotifier = Notifier<List<ScrapElement>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
