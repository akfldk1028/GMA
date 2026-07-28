import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pdfrx/pdfrx.dart';

import '../../drawing/models/drawing_model.dart';
import '../../drawing/pages/widgets/stroke_painter.dart';

/// Service for capturing a rectangular area of a PDF page as a PNG image.
///
/// Supports compositing drawing strokes on top of the PDF render
/// so captures include user annotations ("what you see is what you get").
class CaptureService {
  /// Renders the selected area of a PDF page and saves it as a PNG file.
  ///
  /// [page] — the PdfPage to render from.
  /// [normalizedRect] — selection rectangle in 0..1 normalized coordinates.
  /// [capturesDir] — directory path where the PNG will be saved.
  /// [pageNumber] — used for the output filename.
  /// [drawingStrokes] — optional drawing strokes on this page to composite.
  ///
  /// Returns the filename (not full path) of the saved PNG.
  static Future<String> captureArea({
    required PdfPage page,
    required Rect normalizedRect,
    required String capturesDir,
    required int pageNumber,
    List<DrawingStroke>? drawingStrokes,
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

    // Render the selected region from PDF
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

    // Convert PdfImage → dart:ui Image
    ui.Image? pdfUiImage;
    try {
      pdfUiImage = await pdfImage.createImage();
    } finally {
      pdfImage.dispose();
    }

    // If there are drawing strokes, composite them on top
    ui.Image finalImage;
    if (drawingStrokes != null && drawingStrokes.isNotEmpty) {
      finalImage = await _compositeWithStrokes(
        pdfUiImage,
        drawingStrokes,
        normalizedRect,
        Size(w.toDouble(), h.toDouble()),
      );
      pdfUiImage.dispose();
    } else {
      finalImage = pdfUiImage;
    }

    // Encode to PNG
    ByteData? byteData;
    try {
      byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
    } finally {
      finalImage.dispose();
    }

    if (byteData == null) {
      throw Exception('Failed to encode image as PNG');
    }

    // Generate filename
    final filename =
        'p${pageNumber}_${DateTime.now().millisecondsSinceEpoch}.png';

    // On web, skip file I/O
    if (kIsWeb) {
      return filename;
    }

    // Save to file (native platforms only)
    final filePath = path.join(capturesDir, filename);
    await File(filePath).writeAsBytes(byteData.buffer.asUint8List());

    return filename;
  }

  /// Composite drawing strokes on top of the PDF image.
  ///
  /// Strokes use normalized (0-1) coordinates for the full page.
  /// We need to remap them to the capture region.
  static Future<ui.Image> _compositeWithStrokes(
    ui.Image pdfImage,
    List<DrawingStroke> strokes,
    Rect normalizedRect,
    Size outputSize,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw PDF image as background
    canvas.drawImage(pdfImage, Offset.zero, Paint());

    // Remap strokes: full-page normalized coords → capture-region pixel coords
    final remapped = strokes.map((stroke) {
      final newPoints = stroke.points.map((p) {
        // Remap from page-space to capture-region-space
        final nx = (p.x - normalizedRect.left) / normalizedRect.width;
        final ny = (p.y - normalizedRect.top) / normalizedRect.height;
        return StrokePoint(
          x: nx.clamp(0.0, 1.0),
          y: ny.clamp(0.0, 1.0),
          pressure: p.pressure,
        );
      }).toList();
      return DrawingStroke(
        id: stroke.id,
        pageNumber: stroke.pageNumber,
        points: newPoints,
        toolId: stroke.toolId,
        colorValue: stroke.colorValue,
        size: stroke.size,
      );
    }).toList();

    // Paint strokes using StrokePainter
    final painter = StrokePainter(strokes: remapped);
    painter.paint(canvas, outputSize);

    final picture = recorder.endRecording();
    return picture.toImage(outputSize.width.toInt(), outputSize.height.toInt());
  }
}
