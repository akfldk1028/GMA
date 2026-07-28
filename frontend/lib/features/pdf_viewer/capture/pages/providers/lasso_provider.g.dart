// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lasso_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lassoModeHash() => r'a0fb967b40a68e265dac780fe7570b8f81371fbb';

/// Global lasso mode state — true when freehand lasso capture is active.
/// Mutually exclusive with drawing mode and capture mode.
///
/// Copied from [LassoMode].
@ProviderFor(LassoMode)
final lassoModeProvider = NotifierProvider<LassoMode, bool>.internal(
  LassoMode.new,
  name: r'lassoModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lassoModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LassoMode = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
