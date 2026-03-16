import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gma_app/features/drawing/models/drawing_model.dart';
import 'package:gma_app/features/drawing/pages/providers/drawing_provider.dart';
import 'package:gma_app/features/drawing/pages/widgets/drawing_canvas.dart';

// @MX:NOTE: PdfPageOverlay composes the drawing canvas layer onto a single
// PDF page. It is used standalone (not via pdfrx's pageOverlaysBuilder) to
// allow direct testing and embedding in custom page-level widgets.
// For pdfrx integration, see DrawingOverlay.createOverlaysBuilder().

/// A composable overlay widget for a single PDF page.
///
/// Stacks a [DrawingCanvas] on top of the page area. Both the drawing layer
/// and future text-selection highlight layer are children of a [Stack].
///
/// [pageWidth] and [pageHeight] define the rendered size of the PDF page,
/// used to size the overlay correctly.
class PdfPageOverlay extends ConsumerWidget {
  const PdfPageOverlay({
    super.key,
    required this.documentPath,
    required this.pageNumber,
    required this.pageWidth,
    required this.pageHeight,
  });

  final String documentPath;
  final int pageNumber;
  final double pageWidth;
  final double pageHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingMode = ref.watch(drawingModeProvider);
    final drawingData = ref.watch(drawingStrokesProvider(documentPath));

    final strokes =
        drawingData.valueOrNull?.pageStrokes[pageNumber] ?? const [];

    return SizedBox(
      width: pageWidth,
      height: pageHeight,
      child: Stack(
        children: [
          // Drawing layer
          Positioned.fill(
            child: DrawingCanvas(
              isActive: drawingMode.isActive,
              strokes: strokes,
              toolId: drawingMode.currentToolId,
              colorValue: drawingMode.colorValue,
              strokeSize: drawingMode.strokeSize,
              pageNumber: pageNumber,
              onStrokeCompleted: (stroke) {
                ref
                    .read(drawingStrokesProvider(documentPath).notifier)
                    .addStroke(stroke);
              },
              onStrokeErased: (pageNum, strokeId) {
                ref
                    .read(drawingStrokesProvider(documentPath).notifier)
                    .removeStroke(pageNum, strokeId);
              },
            ),
          ),
          // Future: text selection highlight layer goes here
        ],
      ),
    );
  }
}
