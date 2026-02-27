import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Rect;
import 'package:path/path.dart' as path;
import 'package:pdfrx/pdfrx.dart';

/// Service for capturing a rectangular area of a PDF page as a PNG image.
class CaptureService {
  /// Renders the selected area of a PDF page and saves it as a PNG file.
  ///
  /// [page] — the PdfPage to render from.
  /// [normalizedRect] — selection rectangle in 0..1 normalized coordinates.
  /// [capturesDir] — directory path where the PNG will be saved.
  /// [pageNumber] — used for the output filename.
  ///
  /// Returns the filename (not full path) of the saved PNG.
  static Future<String> captureArea({
    required PdfPage page,
    required Rect normalizedRect,
    required String capturesDir,
    required int pageNumber,
  }) async {
    // Render at 2× scale for high quality
    const renderScale = 2.0;
    final fullW = (page.width * renderScale).toInt();
    final fullH = (page.height * renderScale).toInt();

    // Convert normalized 0..1 coords to pixel coords
    final x = (normalizedRect.left * fullW).toInt();
    final y = (normalizedRect.top * fullH).toInt();
    final w = (normalizedRect.width * fullW).toInt();
    final h = (normalizedRect.height * fullH).toInt();

    if (w <= 0 || h <= 0) {
      throw ArgumentError('Selection area is too small');
    }

    // Render the selected region
    final pdfImage = await page.render(
      x: x,
      y: y,
      width: w,
      height: h,
      fullWidth: fullW.toDouble(),
      fullHeight: fullH.toDouble(),
    );
    if (pdfImage == null) {
      throw Exception('Failed to render PDF page region');
    }

    // Convert PdfImage → dart:ui Image → PNG bytes
    final uiImage = await pdfImage.createImage();
    try {
      pdfImage.dispose();
    } catch (e) {
      // Log but don't block processing
      debugPrint('Failed to dispose pdfImage: $e');
    }

    final byteData = await uiImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    try {
      uiImage.dispose();
    } catch (e) {
      debugPrint('Failed to dispose uiImage: $e');
    }

    if (byteData == null) {
      throw Exception('Failed to encode image as PNG');
    }

    // Save to file
    final filename =
        'p${pageNumber}_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = path.join(capturesDir, filename);
    await File(filePath).writeAsBytes(byteData.buffer.asUint8List());

    return filename;
  }
}
