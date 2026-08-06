import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_provider.freezed.dart';
part 'capture_provider.g.dart';

/// State for the capture mode workflow.
///
/// [isCapturing] indicates whether the user is actively dragging to select
/// a region.
/// [selectedRect] holds the normalized 0-1 selection bounds on the PDF page.
/// [previewImageBytes] is the PNG rendering of the selected region.
/// [showConfirmation] gates the ConfirmScrapPopup visibility.
@freezed
class CaptureState with _$CaptureState {
  const factory CaptureState({
    @Default(false) bool isCapturing,
    Rect? selectedRect,
    Uint8List? previewImageBytes,
    @Default(false) bool showConfirmation,
  }) = _CaptureState;
}

// @MX:ANCHOR: Central capture mode state — read by CapturePageOverlay and
// ConfirmScrapPopup; written by capture UI and capture service callbacks.
// @MX:REASON: fan_in >= 3 callers expected (overlay, popup, toolbar)
/// Notifier managing the capture mode lifecycle.
///
/// Transitions:
///   idle → isCapturing (startCapture)
///   isCapturing → selectedRect set (setSelectedRect)
///   selectedRect → showConfirmation + previewImageBytes (setPreview)
///   showConfirmation → idle (cancelCapture or after accept)
@Riverpod(keepAlive: true)
class CaptureNotifier extends _$CaptureNotifier {
  @override
  CaptureState build() => const CaptureState();

  /// Enter capture mode: enable drag-to-select gesture on PDF pages.
  void startCapture() {
    state = state.copyWith(isCapturing: true);
  }

  /// Exit capture mode and reset all state.
  void cancelCapture() {
    state = const CaptureState();
  }

  /// Store the selected normalized rect (0-1 coordinate space).
  void setSelectedRect(Rect rect) {
    state = state.copyWith(selectedRect: rect);
  }

  /// Store the rendered PNG preview and signal the confirmation popup.
  void setPreview(Uint8List bytes) {
    state = state.copyWith(
      previewImageBytes: bytes,
      showConfirmation: true,
    );
  }

  /// Clear preview bytes and hide the confirmation popup.
  void clearPreview() {
    state = state.copyWith(
      previewImageBytes: null,
      showConfirmation: false,
    );
  }
}
