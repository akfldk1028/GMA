import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../pdf_viewer/drawing/models/drawing_model.dart';
import '../pdf_viewer/drawing/tools/tool_registry.dart';

/// Renders drawing strokes to a PNG file.
///
/// Mirrors StrokePainter._drawStroke logic for pixel-perfect output.
/// Follows CaptureService pattern: static methods, returns filename.
class StrokeRenderService {
  /// Render [strokes] to a PNG image and save to [capturesDir].
  ///
  /// Crops to bounding box with padding, renders at 2x scale.
  /// Returns the filename (not full path) of the saved PNG.
  static Future<String> renderStrokes({
    required List<DrawingStroke> strokes,
    required String capturesDir,
    required int pageNumber,
    Size pageSize = const Size(800, 1132),
  }) async {
    if (strokes.isEmpty) {
      throw ArgumentError('No strokes to render');
    }

    // 1. Compute bounding box of all stroke points (normalized 0-1)
    double minX = 1.0, minY = 1.0, maxX = 0.0, maxY = 0.0;
    for (final stroke in strokes) {
      for (final pt in stroke.points) {
        if (pt.x < minX) minX = pt.x;
        if (pt.y < minY) minY = pt.y;
        if (pt.x > maxX) maxX = pt.x;
        if (pt.y > maxY) maxY = pt.y;
      }
    }

    // 2. Add 15% padding (minimum 0.02)
    final padX = max((maxX - minX) * 0.15, 0.02);
    final padY = max((maxY - minY) * 0.15, 0.02);
    minX = (minX - padX).clamp(0.0, 1.0);
    minY = (minY - padY).clamp(0.0, 1.0);
    maxX = (maxX + padX).clamp(0.0, 1.0);
    maxY = (maxY + padY).clamp(0.0, 1.0);

    // 3. Compute crop dimensions at 2x scale
    const scale = 2.0;
    final cropW = ((maxX - minX) * pageSize.width * scale).ceil();
    final cropH = ((maxY - minY) * pageSize.height * scale).ceil();

    if (cropW <= 0 || cropH <= 0) {
      throw ArgumentError('Stroke area too small to render');
    }

    // 4. Record picture
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, cropW.toDouble(), cropH.toDouble()),
    );

    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cropW.toDouble(), cropH.toDouble()),
      Paint()..color = Colors.white,
    );

    // saveLayer for eraser BlendMode.clear support
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, cropW.toDouble(), cropH.toDouble()),
      Paint(),
    );

    // 5. Draw each stroke (mirrors StrokePainter._drawStroke)
    for (final stroke in strokes) {
      _drawStroke(
        canvas,
        stroke,
        minX: minX,
        minY: minY,
        scaleX: pageSize.width * scale,
        scaleY: pageSize.height * scale,
      );
    }

    canvas.restore();

    // 6. Convert to image → PNG bytes
    final picture = recorder.endRecording();
    final image = await picture.toImage(cropW, cropH);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      throw Exception('Failed to encode stroke image as PNG');
    }

    // 7. Save file
    final filename =
        'p${pageNumber}_stroke_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '$capturesDir/$filename';
    await File(filePath).writeAsBytes(byteData.buffer.asUint8List());

    return filename;
  }

  /// Draw a single stroke onto the canvas, offset by the crop origin.
  static void _drawStroke(
    Canvas canvas,
    DrawingStroke stroke, {
    required double minX,
    required double minY,
    required double scaleX,
    required double scaleY,
  }) {
    if (stroke.points.isEmpty) return;

    final tool = getToolById(stroke.toolId);
    final options = tool.getStrokeOptions(size: stroke.size);
    final paint = tool.getPaint(color: Color(stroke.colorValue));

    // Convert normalized points to canvas coordinates (offset by crop origin)
    final points = stroke.points
        .map((p) => PointVector(
              (p.x - minX) * scaleX,
              (p.y - minY) * scaleY,
              p.pressure ?? 0.5,
            ))
        .toList();

    final outlinePoints = getStroke(points, options: options);
    if (outlinePoints.isEmpty) return;

    final path = Path();
    if (outlinePoints.length == 1) {
      path.addOval(Rect.fromCircle(
        center: outlinePoints.first,
        radius: options.size / 2,
      ));
    } else {
      path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
      for (int i = 1; i < outlinePoints.length - 1; i++) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }
    }

    canvas.drawPath(path, paint);
  }
}
