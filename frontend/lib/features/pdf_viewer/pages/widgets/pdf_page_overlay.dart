import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../models/pdf_marker_model.dart' as marker_model;
import '../providers/pdf_marker_provider.dart';

/// Widget that creates paint callbacks for rendering markers on PDF pages.
///
/// Uses pdfrx's pagePaintCallbacks to draw colored rectangles over
/// selected text regions. Integrates with PdfMarkerProvider to fetch
/// markers for each page.
class PdfPageOverlay extends ConsumerWidget {
  const PdfPageOverlay({
    super.key,
    required this.pageNumber,
  });

  /// The PDF page number to render markers for (1-indexed).
  final int pageNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This widget doesn't render anything directly.
    // It's used to create paint callbacks.
    return const SizedBox.shrink();
  }

  /// Creates a paint callback function for pdfrx's pagePaintCallbacks.
  static void Function(Canvas, Rect, PdfPage) createPaintCallback(
    WidgetRef ref,
    int pageNumber,
  ) {
    return (Canvas canvas, Rect pageRect, PdfPage page) {
      // Get markers for this page
      final markers = ref.read(markersForPageProvider(pageNumber));

      if (markers.isEmpty) return;

      // Draw each marker as a colored rectangle
      for (final marker in markers) {
        if (marker.textRect == null) continue;

        // Convert PdfRect to Rect in page coordinates
        final markerRect = _convertPdfRectToPageRect(
          marker.textRect!,
          pageRect,
          page,
        );

        if (markerRect == null) continue;

        // Draw the marker with the color and transparency
        final paint = Paint()
          ..color = marker.color.color.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

        canvas.drawRect(markerRect, paint);

        // Draw border for better visibility
        final borderPaint = Paint()
          ..color = marker.color.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawRect(markerRect, borderPaint);
      }
    };
  }

  /// Converts a PdfRect to a Rect in page coordinate system.
  ///
  /// PDF coordinates have origin at bottom-left with Y-axis pointing up.
  /// Flutter Canvas coordinates have origin at top-left with Y-axis pointing down.
  static Rect? _convertPdfRectToPageRect(
    marker_model.PdfRect pdfRect,
    Rect pageRect,
    PdfPage page,
  ) {
    try {
      // Get page dimensions
      final pageWidth = page.width;
      final pageHeight = page.height;

      // Calculate scale factors
      final scaleX = pageRect.width / pageWidth;
      final scaleY = pageRect.height / pageHeight;

      // Convert PDF coordinates to Flutter coordinates
      final pdfLeft = pdfRect.x;
      final pdfTop = pdfRect.y;
      final pdfRight = pdfRect.x + pdfRect.width;
      final pdfBottom = pdfRect.y + pdfRect.height;

      // Convert Y coordinates (flip vertical axis)
      final flutterTop = pageHeight - pdfBottom;
      final flutterBottom = pageHeight - pdfTop;

      // Scale to page rect
      final left = pageRect.left + (pdfLeft * scaleX);
      final top = pageRect.top + (flutterTop * scaleY);
      final right = pageRect.left + (pdfRight * scaleX);
      final bottom = pageRect.top + (flutterBottom * scaleY);

      return Rect.fromLTRB(left, top, right, bottom);
    } catch (e) {
      // If conversion fails, return null to skip this marker
      return null;
    }
  }

  /// Static helper to create a list of paint callbacks for PdfViewer.
  static List<void Function(Canvas, Rect, PdfPage)> createPaintCallbacks(
    WidgetRef ref,
  ) {
    return [
      (Canvas canvas, Rect pageRect, PdfPage page) {
        // Get the page number (1-indexed)
        final pageNumber = page.pageNumber;

        // Use the paint callback for this page
        final paintCallback = createPaintCallback(ref, pageNumber);
        paintCallback(canvas, pageRect, page);
      },
    ];
  }
}
