// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrap_insertion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scrapInsertionServiceHash() =>
    r'9c477746863349c37a56d557863b5108f6ef0839';

/// Provides a singleton [ScrapInsertionService] instance.
///
/// Copied from [scrapInsertionService].
@ProviderFor(scrapInsertionService)
final scrapInsertionServiceProvider = Provider<ScrapInsertionService>.internal(
  scrapInsertionService,
  name: r'scrapInsertionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scrapInsertionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScrapInsertionServiceRef = ProviderRef<ScrapInsertionService>;
String _$activeScrapProposalHash() =>
    r'd3902cf3f31123df80cf0c35f785a7f33091959a';

/// Tracks the currently active scrap proposal for the confirm popup.
///
/// Listens to the [ScrapInsertionService.proposals] stream and exposes
/// the latest proposal (or null if none is active).
///
/// Copied from [ActiveScrapProposal].
@ProviderFor(ActiveScrapProposal)
final activeScrapProposalProvider =
    AutoDisposeNotifierProvider<ActiveScrapProposal, Object?>.internal(
      ActiveScrapProposal.new,
      name: r'activeScrapProposalProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeScrapProposalHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveScrapProposal = AutoDisposeNotifier<Object?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
