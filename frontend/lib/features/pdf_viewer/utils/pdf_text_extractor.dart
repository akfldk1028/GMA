import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

import '../drawing/models/drawing_model.dart';

/// Extracts text from a PDF page at a given area.
///
/// Shared utility used by all marker types (text selection, capture, pen stroke)
/// to get contextual text from the PDF at the annotation location.
///
/// Usage:
/// ```dart
/// final text = await PdfTextExtractor.fromStroke(controller, pageNumber, stroke);
/// final text = await PdfTextExtractor.fromRect(controller, pageNumber, pdfRect);
/// ```
class PdfTextExtractor {
  PdfTextExtractor._();

  /// Extract text near a drawing stroke's bounding box.
  ///
  /// Calculates the stroke bbox from normalized [0,1] points,
  /// converts to PDF coordinates, and returns overlapping text.
  static Future<String?> fromStroke(
    PdfViewerController controller,
    int pageNumber,
    DrawingStroke stroke, {
    double margin = 0.05,
  }) async {
    if (stroke.points.length < 2) return null;

    // Calculate stroke bounding box in normalized [0,1] coords
    double minX = stroke.points[0].x, maxX = stroke.points[0].x;
    double minY = stroke.points[0].y, maxY = stroke.points[0].y;
    for (final pt in stroke.points.skip(1)) {
      if (pt.x < minX) minX = pt.x;
      if (pt.x > maxX) maxX = pt.x;
      if (pt.y < minY) minY = pt.y;
      if (pt.y > maxY) maxY = pt.y;
    }

    return fromNormalizedRect(
      controller,
      pageNumber,
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
      margin: margin,
    );
  }

  /// Extract text from a normalized [0,1] rectangle area on a PDF page.
  ///
  /// Coordinates use Flutter convention: (0,0) = top-left, Y-axis down.
  /// The [margin] adds padding (as fraction of page) to catch nearby text.
  static Future<String?> fromNormalizedRect(
    PdfViewerController controller,
    int pageNumber, {
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
    double margin = 0.05,
  }) async {
    if (!controller.isReady) {
      debugPrint('[PdfTextExtractor] controller not ready');
      return null;
    }

    // Apply margin and clamp
    minX = (minX - margin).clamp(0.0, 1.0);
    maxX = (maxX + margin).clamp(0.0, 1.0);
    minY = (minY - margin).clamp(0.0, 1.0);
    maxY = (maxY + margin).clamp(0.0, 1.0);

    return await controller.useDocument<String?>((document) async {
      if (pageNumber < 1 || pageNumber > document.pages.length) {
        debugPrint('[PdfTextExtractor] invalid page $pageNumber');
        return null;
      }

      final page = document.pages[pageNumber - 1];

      // Convert normalized → PDF coordinates
      // PDF: origin at bottom-left, Y-axis up (top >= bottom)
      final pdfRect = PdfRect(
        minX * page.width, // left
        (1 - minY) * page.height, // top
        maxX * page.width, // right
        (1 - maxY) * page.height, // bottom
      );

      debugPrint(
        '[PdfTextExtractor] P$pageNumber | '
        'norm: ($minX,$minY)-($maxX,$maxY) | '
        'pdf: L=${pdfRect.left.toStringAsFixed(1)} '
        'T=${pdfRect.top.toStringAsFixed(1)} '
        'R=${pdfRect.right.toStringAsFixed(1)} '
        'B=${pdfRect.bottom.toStringAsFixed(1)} | '
        'page: ${page.width.toStringAsFixed(0)}x${page.height.toStringAsFixed(0)}',
      );

      // Load structured text
      final pageText = await page.loadStructuredText();
      debugPrint(
        '[PdfTextExtractor] ${pageText.fragments.length} fragments, '
        '${pageText.fullText.length} chars',
      );

      // Find overlapping fragments
      final buffer = StringBuffer();
      for (final fragment in pageText.fragments) {
        if (fragment.bounds.overlaps(pdfRect)) {
          if (buffer.isNotEmpty) buffer.write(' ');
          buffer.write(fragment.text.trim());
        }
      }

      final result = buffer.toString().trim();
      debugPrint(
        '[PdfTextExtractor] result: '
        '"${result.length > 80 ? '${result.substring(0, 80)}...' : result}"',
      );
      return result.isEmpty ? null : result;
    });
  }

  /// Extract text from a pdfrx PdfRect (already in PDF coordinates).
  ///
  /// Useful when you already have PDF-space coordinates (e.g., from
  /// text selection bounds).
  static Future<String?> fromPdfRect(
    PdfViewerController controller,
    int pageNumber,
    PdfRect pdfRect, {
    double marginPoints = 10.0,
  }) async {
    if (!controller.isReady) return null;

    // Expand rect by margin
    final expandedRect = PdfRect(
      pdfRect.left - marginPoints,
      pdfRect.top + marginPoints,
      pdfRect.right + marginPoints,
      pdfRect.bottom - marginPoints,
    );

    return await controller.useDocument<String?>((document) async {
      if (pageNumber < 1 || pageNumber > document.pages.length) return null;

      final page = document.pages[pageNumber - 1];
      final pageText = await page.loadStructuredText();

      final buffer = StringBuffer();
      for (final fragment in pageText.fragments) {
        if (fragment.bounds.overlaps(expandedRect)) {
          if (buffer.isNotEmpty) buffer.write(' ');
          buffer.write(fragment.text.trim());
        }
      }

      final result = buffer.toString().trim();
      return result.isEmpty ? null : result;
    });
  }
}
