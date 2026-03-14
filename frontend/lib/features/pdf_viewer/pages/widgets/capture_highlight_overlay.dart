import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../scrapnote/models/scrapnote_canvas_model.dart';
import '../../../scrapnote/pages/providers/scrapnote_canvas_provider.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';

/// Creates paint callbacks for rendering capture-region highlights on PDF pages.
///
/// Draws semi-transparent cyan rectangles on the PDF at the [sourceRect]
/// of each capture-type [CanvasElement] that originated from the displayed page.
class CaptureHighlightOverlay {
  CaptureHighlightOverlay._();

  static const _highlightColor = Color(0xFF06B6D4); // cyan-500

  /// Creates a list of paint callbacks that render capture rectangles.
  ///
  /// Returns an empty list if no PDF or scrapnote is loaded.
  static List<PdfViewerPagePaintCallback> createPaintCallbacks(
    WidgetRef ref,
  ) {
    final workspaceState = ref.read(workspaceProviderProvider).valueOrNull;
    if (workspaceState?.currentPdfPath == null) return [];

    final scrapnoteId = ref
        .read(pdfRegistryProvProvider.notifier)
        .getIdByPath(workspaceState!.currentPdfPath!);
    if (scrapnoteId == null) return [];

    final canvasAsync = ref.read(scrapnoteCanvasStateProvider(scrapnoteId));
    final canvasData = canvasAsync.valueOrNull;
    if (canvasData == null) return [];

    // Collect capture elements that have a sourceRect
    final captureElements = canvasData.elements
        .where((e) =>
            e.type == CanvasElementType.capture &&
            e.sourceRect != null &&
            e.sourcePageNumber != null)
        .toList();

    if (captureElements.isEmpty) return [];

    return [
      (Canvas canvas, Rect pageRect, PdfPage page) {
        final pageElements = captureElements
            .where((e) => e.sourcePageNumber == page.pageNumber);

        for (final element in pageElements) {
          final pdfRect = element.sourceRect!;
          final screenRect = pdfRect.toRectInDocument(
            page: page,
            pageRect: pageRect,
          );

          // Semi-transparent fill
          canvas.drawRect(
            screenRect,
            Paint()
              ..color = _highlightColor.withValues(alpha: 0.15)
              ..style = PaintingStyle.fill,
          );

          // Dashed-look border (solid thin line)
          canvas.drawRect(
            screenRect,
            Paint()
              ..color = _highlightColor.withValues(alpha: 0.6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      },
    ];
  }
}
