import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../../workspace/pages/providers/workspace_provider.dart';
import '../../../pages/providers/pdf_marker_provider.dart';
import '../../models/drawing_model.dart';
import '../providers/drawing_provider.dart';
import 'drawing_canvas.dart';

/// Provides a drawing overlay builder for pdfrx's pageOverlaysBuilder.
///
/// Returns a list of DrawingCanvas widgets — one per visible page.
/// Each canvas gets its page-specific strokes from DrawingStrokesProvider.
class DrawingOverlay {
  /// Build the pageOverlaysBuilder function for PdfViewerParams.
  static PdfPageOverlaysBuilder createOverlaysBuilder({
    required String noteId,
    required WidgetRef ref,
  }) {
    return (BuildContext context, Rect pageRectInViewer, PdfPage page) {
      return [
        _DrawingPageOverlay(
          noteId: noteId,
          pageNumber: page.pageNumber,
          pdfPageWidth: page.width,
          pdfPageHeight: page.height,
        ),
      ];
    };
  }
}

/// Per-page drawing overlay — ConsumerWidget for Riverpod integration.
class _DrawingPageOverlay extends ConsumerWidget {
  const _DrawingPageOverlay({
    required this.noteId,
    required this.pageNumber,
    required this.pdfPageWidth,
    required this.pdfPageHeight,
  });

  final String noteId;
  final int pageNumber;
  final double pdfPageWidth;
  final double pdfPageHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingMode = ref.watch(drawingModeProvider);
    final drawingData = ref.watch(drawingStrokesProvider(noteId));

    final strokes = drawingData.valueOrNull?.pageStrokes[pageNumber] ?? [];

    return Positioned.fill(
      child: DrawingCanvas(
        isActive: drawingMode.isActive,
        strokes: strokes,
        toolId: drawingMode.currentToolId,
        colorValue: drawingMode.colorValue,
        strokeSize: drawingMode.strokeSize,
        pageNumber: pageNumber,
        onStrokeCompleted: (stroke) {
          ref.read(drawingStrokesProvider(noteId).notifier).addStroke(stroke);
        },
        onEraserStroke: drawingMode.currentToolId == 'eraser'
            ? (stroke) => _handleEraserHit(stroke, ref)
            : null,
      ),
    );
  }

  /// Check if eraser stroke hit any highlight markers and delete them.
  void _handleEraserHit(DrawingStroke stroke, WidgetRef ref) {
    final markers = ref.read(markersForPageProvider(pageNumber));
    if (markers.isEmpty) return;

    final ws = ref.read(workspaceProviderProvider).valueOrNull;
    final currentNoteId = ws?.currentNoteId;
    if (currentNoteId == null) return;

    for (final marker in markers) {
      final rects = marker.lineRects ??
          (marker.textRect != null ? [marker.textRect!] : null);
      if (rects == null || rects.isEmpty) continue;

      bool hit = false;
      for (final pdfRect in rects) {
        // Convert PdfRect (origin bottom-left, Y-up) to normalized widget coords (0..1, Y-down)
        final normLeft = pdfRect.left / pdfPageWidth;
        final normRight = pdfRect.right / pdfPageWidth;
        final normTop = 1.0 - pdfRect.top / pdfPageHeight;
        final normBottom = 1.0 - pdfRect.bottom / pdfPageHeight;

        for (final point in stroke.points) {
          if (point.x >= normLeft && point.x <= normRight &&
              point.y >= normTop && point.y <= normBottom) {
            hit = true;
            break;
          }
        }
        if (hit) break;
      }

      if (hit) {
        ref
            .read(workspaceProviderProvider.notifier)
            .removeScrapElement(currentNoteId, marker.id);
      }
    }
  }
}
