import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../pdf_structure/widgets/structure_overlay.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../providers/pdf_marker_provider.dart';
import 'capture_highlight_overlay.dart';

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
      // Structure overlay (element bounding boxes — toggled via workspace state)
      ...() {
        final ws = ref.read(workspaceProviderProvider).valueOrNull;
        if (ws?.isStructureOverlayVisible == true) {
          return StructureOverlay.createPaintCallbacks(ref);
        }
        return <PdfViewerPagePaintCallback>[];
      }(),
      // Capture-region highlights (cyan rectangles for captured areas)
      ...CaptureHighlightOverlay.createPaintCallbacks(ref),
      // Marker highlights (per-line rectangles for text selections)
      (Canvas canvas, Rect pageRect, PdfPage page) {
        final markers = ref.read(markersForPageProvider(page.pageNumber));
        if (markers.isEmpty) return;

        for (final marker in markers) {
          // Prefer per-line rects; fall back to single bounding box
          final rects = marker.lineRects ??
              (marker.textRect != null ? [marker.textRect!] : null);
          if (rects == null || rects.isEmpty) continue;

          final fillPaint = Paint()
            ..color = marker.color.color.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;

          for (final pdfRect in rects) {
            final screenRect = pdfRect.toRectInDocument(
              page: page,
              pageRect: pageRect,
            );
            canvas.drawRect(screenRect, fillPaint);
          }
        }
      },
    ];
  }
}
