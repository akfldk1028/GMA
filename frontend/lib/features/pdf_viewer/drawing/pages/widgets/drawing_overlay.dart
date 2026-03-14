import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

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
    void Function(int pageNumber, DrawingStroke stroke)? onStrokeAdded,
  }) {
    return (BuildContext context, Rect pageRectInViewer, PdfPage page) {
      return [
        _DrawingPageOverlay(
          noteId: noteId,
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
    required this.noteId,
    required this.pageNumber,
    this.onStrokeAdded,
  });

  final String noteId;
  final int pageNumber;
  final void Function(int pageNumber, DrawingStroke stroke)? onStrokeAdded;

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
          onStrokeAdded?.call(pageNumber, stroke);
        },
      ),
    );
  }
}
