// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$captureNotifierHash() => r'bdb99d8ff3354cba488570ebdf57bbaa31d50c19';

/// Notifier managing the capture mode lifecycle.
///
/// Transitions:
///   idle → isCapturing (startCapture)
///   isCapturing → selectedRect set (setSelectedRect)
///   selectedRect → showConfirmation + previewImageBytes (setPreview)
///   showConfirmation → idle (cancelCapture or after accept)
///
/// Copied from [CaptureNotifier].
@ProviderFor(CaptureNotifier)
final captureNotifierProvider =
    NotifierProvider<CaptureNotifier, CaptureState>.internal(
      CaptureNotifier.new,
      name: r'captureNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$captureNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CaptureNotifier = Notifier<CaptureState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
