import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:pdfrx/pdfrx.dart';

// @MX:NOTE: CaptureService uses pdfrx PdfPage.render() + PdfImageExt.createImage()
// to rasterize a region of a PDF page. The PdfImage is rendered at 2x resolution,
// converted to a dart:ui Image via decodeImageFromPixels (BGRA8888), then the
// normalized selectedRect is cropped and encoded as PNG.

/// Renders a rectangular region of a PDF page to PNG bytes.
///
/// All coordinates use normalized 0-1 space (top-left origin) relative to
/// the page dimensions.
class CaptureService {
  CaptureService._();

  /// Render a region of [page] to PNG bytes.
  ///
  /// [normalizedRect] must be in 0-1 coordinate space (top-left origin).
  /// [pixelRatio] controls render resolution; default 2.0 gives retina quality.
  ///
  /// Returns PNG-encoded [Uint8List] ready for display or file storage.
  ///
  /// Throws [ArgumentError] if [normalizedRect] is empty.
  static Future<Uint8List> renderRegion({
    required PdfPage page,
    required Rect normalizedRect,
    double pixelRatio = 2.0,
  }) async {
    if (normalizedRect.isEmpty) {
      throw ArgumentError('normalizedRect must not be empty');
    }

    // Page dimensions in PDF-native points.
    final pageWidthPt = page.width;
    final pageHeightPt = page.height;

    // Desired full-page render dimensions at the given pixel ratio.
    final renderWidth = (pageWidthPt * pixelRatio).round();
    final renderHeight = (pageHeightPt * pixelRatio).round();

    // Render the full page to a PdfImage (raw BGRA bytes).
    // PdfPage.render() returns PdfImage? — null if rendering failed.
    final pdfImage = await page.render(
      fullWidth: renderWidth.toDouble(),
      fullHeight: renderHeight.toDouble(),
    );

    if (pdfImage == null) {
      throw StateError('PdfPage.render() returned null — page rendering failed.');
    }

    // Convert raw BGRA PdfImage to a dart:ui Image using the pdfrx extension.
    final fullImage = await pdfImage.createImage();

    try {
      // Compute crop rect in pixel space from normalized coordinates.
      final cropRect = Rect.fromLTRB(
        (normalizedRect.left * renderWidth).roundToDouble(),
        (normalizedRect.top * renderHeight).roundToDouble(),
        (normalizedRect.right * renderWidth).roundToDouble(),
        (normalizedRect.bottom * renderHeight).roundToDouble(),
      );

      final cropWidth = cropRect.width.round();
      final cropHeight = cropRect.height.round();

      if (cropWidth <= 0 || cropHeight <= 0) {
        throw ArgumentError(
            'Computed crop dimensions are zero; check normalizedRect values.');
      }

      // Paint the cropped region onto a new PictureRecorder.
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawImageRect(
        fullImage,
        cropRect,
        Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble()),
        Paint(),
      );
      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(cropWidth, cropHeight);

      try {
        // Encode the cropped image as PNG.
        final byteData = await croppedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData == null) {
          throw StateError('Failed to encode cropped image as PNG');
        }

        return byteData.buffer.asUint8List();
      } finally {
        croppedImage.dispose();
      }
    } finally {
      fullImage.dispose();
    }
  }
}
