// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrapnote_page_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scrapNotePageStoreHash() =>
    r'3be6f8facdfb9333937b036c7598d8c8c936384e';

/// Persistent store for ScrapNote pages using Hive.
///
/// State is an int revision counter (same pattern as ElementStore).
///
/// Copied from [ScrapNotePageStore].
@ProviderFor(ScrapNotePageStore)
final scrapNotePageStoreProvider =
    NotifierProvider<ScrapNotePageStore, int>.internal(
      ScrapNotePageStore.new,
      name: r'scrapNotePageStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scrapNotePageStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ScrapNotePageStore = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
