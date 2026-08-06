import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../models/drawing_model.dart';
import '../providers/drawing_provider.dart';
import 'drawing_canvas.dart';

/// Provides a drawing overlay builder for pdfrx's pageOverlaysBuilder.
///
/// Returns a DrawingCanvas widget per visible page.
/// Each canvas connects to DrawingStrokesProvider via documentPath key.
class DrawingOverlay {
  /// Build the pageOverlaysBuilder function for PdfViewerParams.
  static PdfPageOverlaysBuilder createOverlaysBuilder({
    required String documentPath,
    required WidgetRef ref,
    void Function(int pageNumber, DrawingStroke stroke)? onStrokeAdded,
  }) {
    return (BuildContext context, Rect pageRectInViewer, PdfPage page) {
      return [
        _DrawingPageOverlay(
          documentPath: documentPath,
          pageNumber: page.pageNumber,
          onStrokeAdded: onStrokeAdded,
        ),
      ];
    };
  }
}

/// Per-page drawing overlay — ConsumerWidget for Riverpod integration.
class _DrawingPageOverlay extends ConsumerWidget {
  const _DrawingPageOverlay({
    required this.documentPath,
    required this.pageNumber,
    this.onStrokeAdded,
  });

  final String documentPath;
  final int pageNumber;
  final void Function(int pageNumber, DrawingStroke stroke)? onStrokeAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingMode = ref.watch(drawingModeProvider);
    final drawingData = ref.watch(drawingStrokesProvider(documentPath));

    final strokes =
        drawingData.valueOrNull?.pageStrokes[pageNumber] ?? const [];

    return Positioned.fill(
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
          onStrokeAdded?.call(pageNumber, stroke);
        },
        onStrokeErased: (pageNumber, strokeId) {
          ref
              .read(drawingStrokesProvider(documentPath).notifier)
              .removeStroke(pageNumber, strokeId);
        },
      ),
    );
  }
}
