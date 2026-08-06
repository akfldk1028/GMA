import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:gma_app/features/pdf_viewer/capture/pages/providers/capture_provider.dart';
import 'package:gma_app/features/pdf_viewer/capture/utils/capture_service.dart';

/// Drag-to-select region overlay for a single PDF page.
///
/// When [CaptureNotifier.isCapturing] is true:
/// - Intercepts pointer events to build a drag rectangle.
/// - Renders a dashed-border rectangle with semi-transparent fill during drag.
/// - On drag end, renders the region via [CaptureService] and stores the
///   result in [CaptureNotifier] to trigger [ConfirmScrapPopup].
///
/// Per SPEC R6.2, no inline confirm/cancel buttons are shown here.
class CaptureOverlay extends ConsumerStatefulWidget {
  const CaptureOverlay({
    super.key,
    required this.page,
    required this.pageWidth,
    required this.pageHeight,
  });

  /// The pdfrx PdfPage used for rendering the selected region.
  final PdfPage page;

  /// Rendered width of the PDF page in logical pixels.
  final double pageWidth;

  /// Rendered height of the PDF page in logical pixels.
  final double pageHeight;

  @override
  ConsumerState<CaptureOverlay> createState() => _CaptureOverlayState();
}

class _CaptureOverlayState extends ConsumerState<CaptureOverlay> {
  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _isRendering = false;

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureNotifierProvider);

    // When not in capture mode, pass all events through.
    if (!captureState.isCapturing) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.pageWidth,
      height: widget.pageHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: _SelectionPainter(
            dragStart: _dragStart,
            dragCurrent: _dragCurrent,
            pageWidth: widget.pageWidth,
            pageHeight: widget.pageHeight,
          ),
          size: Size(widget.pageWidth, widget.pageHeight),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _dragStart = details.localPosition;
      _dragCurrent = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragCurrent = details.localPosition;
    });
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_dragStart == null || _dragCurrent == null) return;
    if (_isRendering) return;

    final start = _dragStart!;
    final end = _dragCurrent!;

    // Compute normalized rect (0-1) with clamping.
    final left = math.min(start.dx, end.dx) / widget.pageWidth;
    final top = math.min(start.dy, end.dy) / widget.pageHeight;
    final right = math.max(start.dx, end.dx) / widget.pageWidth;
    final bottom = math.max(start.dy, end.dy) / widget.pageHeight;

    final normalizedRect = Rect.fromLTRB(
      left.clamp(0.0, 1.0),
      top.clamp(0.0, 1.0),
      right.clamp(0.0, 1.0),
      bottom.clamp(0.0, 1.0),
    );

    // Ignore tiny accidental taps.
    if (normalizedRect.width < 0.01 || normalizedRect.height < 0.01) {
      setState(() {
        _dragStart = null;
        _dragCurrent = null;
      });
      return;
    }

    setState(() {
      _isRendering = true;
    });

    try {
      ref.read(captureNotifierProvider.notifier).setSelectedRect(normalizedRect);

      final bytes = await CaptureService.renderRegion(
        page: widget.page,
        normalizedRect: normalizedRect,
      );

      if (mounted) {
        ref.read(captureNotifierProvider.notifier).setPreview(bytes);
      }
    } catch (_) {
      // Render failed — cancel capture silently.
      if (mounted) {
        ref.read(captureNotifierProvider.notifier).cancelCapture();
      }
    } finally {
      if (mounted) {
        setState(() {
          _dragStart = null;
          _dragCurrent = null;
          _isRendering = false;
        });
      }
    }
  }
}

/// CustomPainter that draws the dashed-border selection rectangle.
class _SelectionPainter extends CustomPainter {
  const _SelectionPainter({
    required this.dragStart,
    required this.dragCurrent,
    required this.pageWidth,
    required this.pageHeight,
  });

  final Offset? dragStart;
  final Offset? dragCurrent;
  final double pageWidth;
  final double pageHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (dragStart == null || dragCurrent == null) return;

    final rect = Rect.fromPoints(dragStart!, dragCurrent!);

    // Semi-transparent fill.
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0x332196F3),
    );

    // Dashed border.
    _drawDashedRect(canvas, rect);
  }

  void _drawDashedRect(Canvas canvas, Rect rect) {
    const dashLength = 6.0;
    const gapLength = 4.0;
    const strokeWidth = 1.5;

    final borderPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw dashed lines for each side of the rectangle.
    _drawDashedLine(
        canvas, rect.topLeft, rect.topRight, dashLength, gapLength, borderPaint);
    _drawDashedLine(canvas, rect.topRight, rect.bottomRight, dashLength,
        gapLength, borderPaint);
    _drawDashedLine(canvas, rect.bottomRight, rect.bottomLeft, dashLength,
        gapLength, borderPaint);
    _drawDashedLine(canvas, rect.bottomLeft, rect.topLeft, dashLength,
        gapLength, borderPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    double dashLength,
    double gapLength,
    Paint paint,
  ) {
    final totalLength = (end - start).distance;
    final direction = (end - start) / totalLength;

    double traveled = 0.0;
    bool drawing = true;

    while (traveled < totalLength) {
      final segmentLength =
          math.min(drawing ? dashLength : gapLength, totalLength - traveled);

      if (drawing) {
        final segStart = start + direction * traveled;
        final segEnd = start + direction * (traveled + segmentLength);
        canvas.drawLine(segStart, segEnd, paint);
      }

      traveled += segmentLength;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_SelectionPainter oldDelegate) {
    return oldDelegate.dragStart != dragStart ||
        oldDelegate.dragCurrent != dragCurrent;
  }
}
