import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/pdf_viewer/capture/pages/providers/capture_provider.dart';

void main() {
  group('CaptureNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state: isCapturing false, no rect, no preview', () {
      final state = container.read(captureNotifierProvider);
      expect(state.isCapturing, isFalse);
      expect(state.selectedRect, isNull);
      expect(state.previewImageBytes, isNull);
      expect(state.showConfirmation, isFalse);
    });

    test('startCapture sets isCapturing to true', () {
      container.read(captureNotifierProvider.notifier).startCapture();
      final state = container.read(captureNotifierProvider);
      expect(state.isCapturing, isTrue);
    });

    test('cancelCapture resets all state to defaults', () {
      // Arrange: put notifier into a non-default state.
      final notifier = container.read(captureNotifierProvider.notifier);
      notifier.startCapture();
      notifier.setSelectedRect(
        const Rect.fromLTRB(0.1, 0.2, 0.5, 0.6),
      );
      notifier.setPreview(Uint8List.fromList([1, 2, 3]));

      // Act.
      notifier.cancelCapture();

      // Assert: all fields reset.
      final state = container.read(captureNotifierProvider);
      expect(state.isCapturing, isFalse);
      expect(state.selectedRect, isNull);
      expect(state.previewImageBytes, isNull);
      expect(state.showConfirmation, isFalse);
    });

    test('setSelectedRect stores the provided rect', () {
      const rect = Rect.fromLTRB(0.1, 0.2, 0.8, 0.9);
      container.read(captureNotifierProvider.notifier).setSelectedRect(rect);

      final state = container.read(captureNotifierProvider);
      expect(state.selectedRect, equals(rect));
    });

    test('setPreview stores bytes and sets showConfirmation to true', () {
      final bytes = Uint8List.fromList([10, 20, 30]);
      container.read(captureNotifierProvider.notifier).setPreview(bytes);

      final state = container.read(captureNotifierProvider);
      expect(state.previewImageBytes, equals(bytes));
      expect(state.showConfirmation, isTrue);
    });

    test('clearPreview nulls bytes and hides confirmation', () {
      // Arrange: set preview first.
      final bytes = Uint8List.fromList([1, 2, 3]);
      final notifier = container.read(captureNotifierProvider.notifier);
      notifier.setPreview(bytes);
      expect(container.read(captureNotifierProvider).showConfirmation, isTrue);

      // Act.
      notifier.clearPreview();

      // Assert.
      final state = container.read(captureNotifierProvider);
      expect(state.previewImageBytes, isNull);
      expect(state.showConfirmation, isFalse);
    });

    test('state transitions follow the capture lifecycle', () {
      final notifier = container.read(captureNotifierProvider.notifier);

      // Step 1: start capture.
      notifier.startCapture();
      expect(container.read(captureNotifierProvider).isCapturing, isTrue);

      // Step 2: set rect.
      const rect = Rect.fromLTRB(0.2, 0.3, 0.7, 0.8);
      notifier.setSelectedRect(rect);
      expect(container.read(captureNotifierProvider).selectedRect, rect);

      // Step 3: set preview.
      final bytes = Uint8List.fromList([0xFF, 0xD8]);
      notifier.setPreview(bytes);
      expect(
          container.read(captureNotifierProvider).showConfirmation, isTrue);

      // Step 4: cancel resets everything.
      notifier.cancelCapture();
      final finalState = container.read(captureNotifierProvider);
      expect(finalState.isCapturing, isFalse);
      expect(finalState.selectedRect, isNull);
      expect(finalState.previewImageBytes, isNull);
      expect(finalState.showConfirmation, isFalse);
    });
  });

  group('CaptureState', () {
    test('equality: two identical states are equal', () {
      const a = CaptureState(isCapturing: false);
      const b = CaptureState(isCapturing: false);
      expect(a, equals(b));
    });

    test('copyWith preserves fields not overridden', () {
      const original = CaptureState(isCapturing: true, showConfirmation: false);
      final copy = original.copyWith(showConfirmation: true);
      expect(copy.isCapturing, isTrue);
      expect(copy.showConfirmation, isTrue);
    });
  });
}
