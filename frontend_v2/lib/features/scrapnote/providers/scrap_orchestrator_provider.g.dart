// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrap_orchestrator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scrapOrchestratorHash() => r'9257bf3a4b483c14b86aaeb55c75b27c89158493';

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
