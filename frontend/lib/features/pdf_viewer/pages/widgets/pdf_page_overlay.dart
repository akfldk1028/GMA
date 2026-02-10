import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../providers/pdf_marker_provider.dart';

/// Creates paint callbacks for rendering marker highlights on PDF pages.
/// Uses pdfrx's pagePaintCallbacks to draw colored rectangles over
/// selected text regions.
class PdfPageOverlay {
  PdfPageOverlay._();

  /// Static helper to create a list of paint callbacks for PdfViewer.
  static List<void Function(Canvas, Rect, PdfPage)> createPaintCallbacks(
    WidgetRef ref,
  ) {
    return [
      (Canvas canvas, Rect pageRect, PdfPage page) {
        final markers = ref.read(markersForPageProvider(page.pageNumber));
        if (markers.isEmpty) return;

        for (final marker in markers) {
          if (marker.textRect == null) continue;

          // Local PdfRect has x, y, width, height
          final tr = marker.textRect!;

          // Scale PDF coordinates to widget page rect
          final scaleX = pageRect.width / page.width;
          final scaleY = pageRect.height / page.height;

          // Convert: x,y is top-left in PDF space (y increases upward)
          // Flutter space: origin top-left, Y increases downward
          final left = pageRect.left + (tr.x * scaleX);
          final top = pageRect.top + ((page.height - tr.y) * scaleY);
          final right = pageRect.left + ((tr.x + tr.width) * scaleX);
          final bottom = pageRect.top + ((page.height - (tr.y - tr.height)) * scaleY);

          final markerRect = Rect.fromLTRB(left, top, right, bottom);

          // Draw semi-transparent fill
          canvas.drawRect(
            markerRect,
            Paint()
              ..color = marker.color.color.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill,
          );

          // Draw border
          canvas.drawRect(
            markerRect,
            Paint()
              ..color = marker.color.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
        }
      },
    ];
  }
}
