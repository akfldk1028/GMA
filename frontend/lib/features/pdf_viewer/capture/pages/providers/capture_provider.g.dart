// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$captureModeHash() => r'23cd5ee99692b43e9d790f241a3cede24966ba13';

/// Global capture mode state — true when area capture is active.
/// Mutually exclusive with drawing mode.
///
/// Copied from [CaptureMode].
@ProviderFor(CaptureMode)
final captureModeProvider = NotifierProvider<CaptureMode, bool>.internal(
  CaptureMode.new,
  name: r'captureModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$captureModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CaptureMode = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
