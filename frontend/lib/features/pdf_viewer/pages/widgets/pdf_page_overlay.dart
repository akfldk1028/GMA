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

          // textRect is already a PdfRect(left, top, right, bottom) from pdfrx
          final pdfRect = marker.textRect!;

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
