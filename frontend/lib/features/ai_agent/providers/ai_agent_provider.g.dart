// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_agent_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiAgentHash() => r'a34d30d0c8d1d912654bfab095ce59204429e034';

/// AI Agent with skill-based GMA MD block generation.
///
/// Copied from [AiAgent].
@ProviderFor(AiAgent)
final aiAgentProvider = NotifierProvider<AiAgent, AiAgentState>.internal(
  AiAgent.new,
  name: r'aiAgentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiAgentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AiAgent = Notifier<AiAgentState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
