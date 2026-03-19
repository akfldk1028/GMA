import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/painting.dart' show Rect, Offset;
import 'package:path/path.dart' as path;
import 'package:pdfrx/pdfrx.dart';

import '../../drawing/models/drawing_model.dart';
import '../../drawing/pages/widgets/stroke_painter.dart';

/// Service for capturing a freehand lasso area of a PDF page as a masked PNG.
///
/// Supports compositing drawing strokes on top of the PDF render
/// so captures include user annotations.
class LassoCaptureService {
  /// Renders the lasso-selected area of a PDF page and saves it as a PNG file.
  ///
  /// [page] — the PdfPage to render from.
  /// [points] — normalized 0..1 lasso path points.
  /// [capturesDir] — directory path where the PNG will be saved.
  /// [pageNumber] — used for the output filename.
  /// [drawingStrokes] — optional drawing strokes on this page to composite.
  ///
  /// Returns the filename (not full path) of the saved PNG.
  /// Compute the bounding box of normalized lasso points.
  static Rect boundingBox(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;
    double minX = points[0].dx, maxX = points[0].dx;
    double minY = points[0].dy, maxY = points[0].dy;
    for (final pt in points) {
      if (pt.dx < minX) minX = pt.dx;
      if (pt.dx > maxX) maxX = pt.dx;
      if (pt.dy < minY) minY = pt.dy;
      if (pt.dy > maxY) maxY = pt.dy;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  static Future<String> captureArea({
    required PdfPage page,
    required List<Offset> points,
    required String capturesDir,
    required int pageNumber,
    List<DrawingStroke>? drawingStrokes,
  }) async {
    if (points.length < 3) {
      throw ArgumentError('Lasso requires at least 3 points');
    }

    // Compute bounding box of the lasso path
    double minX = points[0].dx, maxX = points[0].dx;
    double minY = points[0].dy, maxY = points[0].dy;
    for (final pt in points) {
      if (pt.dx < minX) minX = pt.dx;
      if (pt.dx > maxX) maxX = pt.dx;
      if (pt.dy < minY) minY = pt.dy;
      if (pt.dy > maxY) maxY = pt.dy;
    }

    final normalizedRect = Rect.fromLTRB(minX, minY, maxX, maxY);

    // Render at 2x scale for quality
    const renderScale = 2.0;
    final fullW = (page.width * renderScale).toInt();
    final fullH = (page.height * renderScale).toInt();

    // Convert normalized bbox to pixel coords
    final x = (normalizedRect.left * fullW).toInt();
    final y = (normalizedRect.top * fullH).toInt();
    final w = (normalizedRect.width * fullW).toInt();
    final h = (normalizedRect.height * fullH).toInt();

    if (w <= 0 || h <= 0) {
      throw ArgumentError('Selection area is too small');
    }

    // Render the bounding box region
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

    ui.Image? sourceImage;
    try {
      sourceImage = await pdfImage.createImage();
    } finally {
      pdfImage.dispose();
    }

    // Apply lasso mask + composite drawing strokes
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // Build lasso path relative to the bounding box
    final lassoPath = ui.Path();
    for (var i = 0; i < points.length; i++) {
      final px = (points[i].dx - minX) / normalizedRect.width * w;
      final py = (points[i].dy - minY) / normalizedRect.height * h;
      if (i == 0) {
        lassoPath.moveTo(px, py);
      } else {
        lassoPath.lineTo(px, py);
      }
    }
    lassoPath.close();

    canvas.clipPath(lassoPath);

    // Draw PDF as background
    canvas.drawImage(sourceImage, Offset.zero, ui.Paint());

    // Composite drawing strokes if available
    if (drawingStrokes != null && drawingStrokes.isNotEmpty) {
      final outputSize = ui.Size(w.toDouble(), h.toDouble());
      final remapped = drawingStrokes.map((stroke) {
        final newPoints = stroke.points.map((p) {
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

      final painter = StrokePainter(strokes: remapped);
      painter.paint(canvas, outputSize);
    }

    final picture = recorder.endRecording();
    final maskedImage = await picture.toImage(w, h);
    sourceImage.dispose();

    ByteData? byteData;
    try {
      byteData = await maskedImage.toByteData(format: ui.ImageByteFormat.png);
    } finally {
      maskedImage.dispose();
    }

    if (byteData == null) {
      throw Exception('Failed to encode lasso image as PNG');
    }

    final filename =
        'lasso_p${pageNumber}_${DateTime.now().millisecondsSinceEpoch}.png';

    if (kIsWeb) return filename;

    final filePath = path.join(capturesDir, filename);
    await File(filePath).writeAsBytes(byteData.buffer.asUint8List());

    return filename;
  }
}
