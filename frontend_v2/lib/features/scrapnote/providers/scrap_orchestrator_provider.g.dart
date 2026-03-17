// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrap_orchestrator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scrapOrchestratorHash() =>
    r'b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1';

/// Central orchestrator for creating and storing ScrapElements.
/// Acts as the single entry point for all scrap insertion workflows.
///
/// Copied from [ScrapOrchestrator].
@ProviderFor(ScrapOrchestrator)
final scrapOrchestratorProvider =
    NotifierProvider<ScrapOrchestrator, void>.internal(
      ScrapOrchestrator.new,
      name: r'scrapOrchestratorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scrapOrchestratorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ScrapOrchestrator = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
