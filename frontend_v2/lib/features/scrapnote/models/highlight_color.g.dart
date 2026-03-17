// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight_color.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lastUsedHighlightColorHash() =>
    r'c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2';

/// Tracks the last-used highlight color for the current session.
/// Resets to [HighlightColors.defaultColor] on app restart.
///
/// Copied from [LastUsedHighlightColor].
@ProviderFor(LastUsedHighlightColor)
final lastUsedHighlightColorProvider =
    NotifierProvider<LastUsedHighlightColor, int>.internal(
      LastUsedHighlightColor.new,
      name: r'lastUsedHighlightColorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lastUsedHighlightColorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LastUsedHighlightColor = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
