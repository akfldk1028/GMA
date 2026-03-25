// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiChatHash() => r'8fa6debd126566aa9364e877cba28085770df03a';

/// See also [AiChat].
@ProviderFor(AiChat)
final aiChatProvider = NotifierProvider<AiChat, List<ChatMessage>>.internal(
  AiChat.new,
  name: r'aiChatProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiChatHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AiChat = Notifier<List<ChatMessage>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
