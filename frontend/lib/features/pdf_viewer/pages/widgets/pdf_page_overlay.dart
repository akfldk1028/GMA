import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../providers/pdf_marker_provider.dart';

/// Creates paint callbacks for rendering marker highlights on PDF pages.
/// Uses pdfrx's pagePaintCallbacks and built-in coordinate conversion
/// to draw colored rectangles over selected text regions.
class PdfPageOverlay {
  PdfPageOverlay._();

  /// Static helper to create a list of paint callbacks for PdfViewer.
  /// Uses pdfrx's PdfRect.toRectInDocument() for proper coordinate conversion.
  static List<PdfViewerPagePaintCallback> createPaintCallbacks(
    WidgetRef ref,
  ) {
    return [
      (Canvas canvas, Rect pageRect, PdfPage page) {
        final markers = ref.read(markersForPageProvider(page.pageNumber));
        if (markers.isEmpty) return;

        for (final marker in markers) {
          if (marker.textRect == null) continue;

          // The local model stores: x=left, y=top, width, height
          // Reconstruct pdfrx PdfRect(left, top, right, bottom)
          // In PDF coords: top >= bottom, height = top - bottom
          // So: bottom = top - height = tr.y - tr.height
          final tr = marker.textRect!;
          final pdfRect = PdfRect(
            tr.x,
            tr.y,
            tr.x + tr.width,
            tr.y - tr.height,
          );

          // Use pdfrx built-in conversion (handles Y-flip + rotation + scale)
          final screenRect = pdfRect.toRectInDocument(
            page: page,
            pageRect: pageRect,
          );

          // Draw semi-transparent highlight fill
          canvas.drawRect(
            screenRect,
            Paint()
              ..color = marker.color.color.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill,
          );

          // Draw thin border
          canvas.drawRect(
            screenRect,
            Paint()
              ..color = marker.color.color.withValues(alpha: 0.7)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
        }
      },
    ];
  }
}
