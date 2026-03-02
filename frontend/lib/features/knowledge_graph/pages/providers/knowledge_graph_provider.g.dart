// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_graph_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$knowledgeGraphProvHash() =>
    r'4cec5034c02fd30ffc92c9b4e881850623f1532d';

/// Builds a [KnowledgeGraph] from the current note list, PDF registry
/// and ScrapElement store, then lays it out with force-directed placement.
///
/// Copied from [KnowledgeGraphProv].
@ProviderFor(KnowledgeGraphProv)
final knowledgeGraphProvProvider =
    AutoDisposeAsyncNotifierProvider<
      KnowledgeGraphProv,
      KnowledgeGraph
    >.internal(
      KnowledgeGraphProv.new,
      name: r'knowledgeGraphProvProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$knowledgeGraphProvHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$KnowledgeGraphProv = AutoDisposeAsyncNotifier<KnowledgeGraph>;
String _$graphFilterProvHash() => r'56554b1c986173f61f6d9e79dacf73ff3f50f1e1';

/// Simple filter state provider.
///
/// Copied from [GraphFilterProv].
@ProviderFor(GraphFilterProv)
final graphFilterProvProvider =
    AutoDisposeNotifierProvider<GraphFilterProv, GraphFilter>.internal(
      GraphFilterProv.new,
      name: r'graphFilterProvProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$graphFilterProvHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GraphFilterProv = AutoDisposeNotifier<GraphFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
