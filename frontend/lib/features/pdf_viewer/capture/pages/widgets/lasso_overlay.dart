import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../utils/file_system_provider.dart';
import '../../../drawing/models/drawing_model.dart';
import '../../../drawing/pages/providers/drawing_provider.dart';
import '../providers/lasso_provider.dart';
import '../../utils/lasso_capture_service.dart';

/// Callback when a lasso capture is completed successfully.
typedef OnLassoCaptureCompleted = Future<void> Function({
  required int pageNumber,
  required String filename,
  required Rect normalizedRect,
  required List<Offset> lassoPoints,
});

/// Provides a lasso overlay builder for pdfrx's pageOverlaysBuilder.
///
/// When lasso mode is active, shows a freehand path on each page.
/// When selection is confirmed, renders the masked area as PNG.
class LassoOverlay {
  static PdfPageOverlaysBuilder createOverlaysBuilder({
    required WidgetRef ref,
    required OnLassoCaptureCompleted onLassoCaptureCompleted,
    String? noteId,
  }) {
    return (BuildContext context, Rect pageRectInViewer, PdfPage page) {
      return [
        _LassoPageOverlay(
          page: page,
          pageNumber: page.pageNumber,
          onLassoCaptureCompleted: onLassoCaptureCompleted,
          noteId: noteId,
        ),
      ];
    };
  }
}

class _LassoPageOverlay extends ConsumerStatefulWidget {
  const _LassoPageOverlay({
    required this.page,
    required this.pageNumber,
    required this.onLassoCaptureCompleted,
    this.noteId,
  });

  final PdfPage page;
  final int pageNumber;
  final OnLassoCaptureCompleted onLassoCaptureCompleted;
  final String? noteId;

  @override
  ConsumerState<_LassoPageOverlay> createState() => _LassoPageOverlayState();
}

class _LassoPageOverlayState extends ConsumerState<_LassoPageOverlay> {
  List<Offset> _points = [];
  bool _selectionConfirmed = false;
  bool _isCapturing = false;

  void _resetSelection() {
    setState(() {
      _points = [];
      _selectionConfirmed = false;
      _isCapturing = false;
    });
  }

  Offset _toNormalized(Offset local, Size size) {
    return Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    );
  }

  Future<void> _handleCapture() async {
    if (_points.length < 3) return;

    setState(() => _isCapturing = true);

    try {
      final capturesDir = await ref.read(capturesDirectoryProvider.future);
      if (!mounted) return;

      // Get drawing strokes for this page to composite into capture
      List<DrawingStroke>? pageStrokes;
      if (widget.noteId != null) {
        final drawingData =
            ref.read(drawingStrokesProvider(widget.noteId!)).valueOrNull;
        pageStrokes = drawingData?.pageStrokes[widget.pageNumber];
      }

      final filename = await LassoCaptureService.captureArea(
        page: widget.page,
        points: _points,
        capturesDir: capturesDir.path,
        pageNumber: widget.pageNumber,
        drawingStrokes: pageStrokes,
      );
      if (!mounted) return;

      final bbox = LassoCaptureService.boundingBox(_points);

      await widget.onLassoCaptureCompleted(
        pageNumber: widget.pageNumber,
        filename: filename,
        normalizedRect: bbox,
        lassoPoints: List.from(_points),
      );

      if (mounted) {
        ref.read(lassoModeProvider.notifier).setActive(false);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Lasso Capture Failed'),
            description: Text(e.toString()),
          ),
        );
      }
    }

    if (mounted) {
      _resetSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = ref.watch(lassoModeProvider);

    if (!isActive) {
      if (_points.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _resetSelection();
        });
      }
      return const Positioned.fill(child: SizedBox.shrink());
    }

    final theme = ShadTheme.of(context);

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _selectionConfirmed
                ? null
                : (details) {
                    setState(() {
                      _points = [_toNormalized(details.localPosition, size)];
                      _selectionConfirmed = false;
                    });
                  },
            onPanUpdate: _selectionConfirmed
                ? null
                : (details) {
                    final newPoint =
                        _toNormalized(details.localPosition, size);
                    // Downsample: only add if moved > 3px equivalent
                    if (_points.isNotEmpty) {
                      final last = _points.last;
                      final dx = (newPoint.dx - last.dx) * size.width;
                      final dy = (newPoint.dy - last.dy) * size.height;
                      if (dx * dx + dy * dy < 9) return; // < 3px
                    }
                    setState(() {
                      _points = [..._points, newPoint];
                    });
                  },
            onPanEnd: _selectionConfirmed
                ? null
                : (details) {
                    if (_points.length >= 3) {
                      setState(() => _selectionConfirmed = true);
                    } else {
                      _resetSelection();
                    }
                  },
            child: CustomPaint(
              painter: _LassoPainter(
                points: _points,
                color: theme.colorScheme.primary,
                confirmed: _selectionConfirmed,
              ),
              child: _selectionConfirmed
                  ? _buildConfirmButtons(theme, size)
                  : const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfirmButtons(ShadThemeData theme, Size viewSize) {
    if (_points.isEmpty) return const SizedBox.expand();

    final bbox = LassoCaptureService.boundingBox(_points);
    const buttonBarWidth = 100.0;
    const buttonBarHeight = 40.0;
    final bottom = bbox.bottom * viewSize.height;
    final centerX = bbox.center.dx * viewSize.width;

    final spaceBelow = viewSize.height - bottom;
    final top = spaceBelow > buttonBarHeight + 16
        ? bottom + 8
        : (bbox.top * viewSize.height) - buttonBarHeight - 8;
    final left = (centerX - buttonBarWidth / 2)
        .clamp(4.0, viewSize.width - buttonBarWidth - 4);

    return Stack(
      children: [
        const SizedBox.expand(),
        Positioned(
          top: top.clamp(4.0, viewSize.height - buttonBarHeight - 4),
          left: left,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.border),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.foreground.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Capture',
                  child: InkWell(
                    onTap: _isCapturing ? null : _handleCapture,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _isCapturing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : Icon(Icons.check,
                              size: 18, color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Cancel',
                  child: InkWell(
                    onTap: _isCapturing ? null : _resetSelection,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.close,
                          size: 18, color: theme.colorScheme.mutedForeground),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints the lasso path overlay.
class _LassoPainter extends CustomPainter {
  _LassoPainter({
    required this.points,
    required this.color,
    required this.confirmed,
  });

  final List<Offset> points;
  final Color color;
  final bool confirmed;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = ui.Path();
    for (var i = 0; i < points.length; i++) {
      final px = points[i].dx * size.width;
      final py = points[i].dy * size.height;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }

    if (confirmed) {
      path.close();

      // Semi-transparent fill
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // Solid border
      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, borderPaint);
    } else {
      // Dashed stroke while drawing
      final dashPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw as solid line (true dashing requires path_drawing package)
      canvas.drawPath(path, dashPaint);

      // Draw dots at each point for visual feedback
      final dotPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      for (final pt in points) {
        canvas.drawCircle(
          Offset(pt.dx * size.width, pt.dy * size.height),
          2,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LassoPainter oldDelegate) {
    return points.length != oldDelegate.points.length ||
        confirmed != oldDelegate.confirmed;
  }
}
