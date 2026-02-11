import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../utils/file_system_provider.dart';
import '../providers/capture_provider.dart';
import '../../utils/capture_service.dart';

/// Callback when a capture is completed successfully.
typedef OnCaptureCompleted = Future<void> Function({
  required int pageNumber,
  required String filename,
  required Rect normalizedRect,
});

/// Provides a capture overlay builder for pdfrx's pageOverlaysBuilder.
///
/// When capture mode is active, shows a drag-to-select rectangle on each page.
/// When selection is confirmed, renders the area as PNG via [CaptureService].
class CaptureOverlay {
  /// Build the pageOverlaysBuilder function for PdfViewerParams.
  static PdfPageOverlaysBuilder createOverlaysBuilder({
    required WidgetRef ref,
    required OnCaptureCompleted onCaptureCompleted,
  }) {
    return (BuildContext context, Rect pageRectInViewer, PdfPage page) {
      return [
        _CapturePageOverlay(
          page: page,
          pageNumber: page.pageNumber,
          onCaptureCompleted: onCaptureCompleted,
        ),
      ];
    };
  }
}

/// Per-page capture overlay with drag selection.
class _CapturePageOverlay extends ConsumerStatefulWidget {
  const _CapturePageOverlay({
    required this.page,
    required this.pageNumber,
    required this.onCaptureCompleted,
  });

  final PdfPage page;
  final int pageNumber;
  final OnCaptureCompleted onCaptureCompleted;

  @override
  ConsumerState<_CapturePageOverlay> createState() =>
      _CapturePageOverlayState();
}

class _CapturePageOverlayState extends ConsumerState<_CapturePageOverlay> {
  // Drag state (in widget-local coordinates, normalized 0..1)
  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _selectionConfirmed = false;
  bool _isCapturing = false;

  Rect? get _selectionRect {
    if (_dragStart == null || _dragCurrent == null) return null;
    return Rect.fromPoints(_dragStart!, _dragCurrent!);
  }

  void _resetSelection() {
    setState(() {
      _dragStart = null;
      _dragCurrent = null;
      _selectionConfirmed = false;
      _isCapturing = false;
    });
  }

  /// Convert local pixel offset to normalized 0..1 coordinates.
  Offset _toNormalized(Offset local, Size size) {
    return Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    );
  }

  Future<void> _handleCapture() async {
    final rect = _selectionRect;
    if (rect == null) return;

    setState(() => _isCapturing = true);

    try {
      final capturesDir = await ref.read(capturesDirectoryProvider.future);
      if (!mounted) return;

      final filename = await CaptureService.captureArea(
        page: widget.page,
        normalizedRect: rect,
        capturesDir: capturesDir.path,
        pageNumber: widget.pageNumber,
      );
      if (!mounted) return;

      await widget.onCaptureCompleted(
        pageNumber: widget.pageNumber,
        filename: filename,
        normalizedRect: rect,
      );

      // Turn off capture mode after successful capture
      if (mounted) {
        ref.read(captureModeProvider.notifier).setActive(false);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Capture Failed'),
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
    final isActive = ref.watch(captureModeProvider);

    // When capture mode is OFF, render nothing and ignore pointer
    if (!isActive) {
      // Reset local state when mode is turned off externally
      if (_dragStart != null) {
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
                      _dragStart = _toNormalized(details.localPosition, size);
                      _dragCurrent = _dragStart;
                      _selectionConfirmed = false;
                    });
                  },
            onPanUpdate: _selectionConfirmed
                ? null
                : (details) {
                    setState(() {
                      _dragCurrent =
                          _toNormalized(details.localPosition, size);
                    });
                  },
            onPanEnd: _selectionConfirmed
                ? null
                : (details) {
                    final rect = _selectionRect;
                    if (rect != null &&
                        rect.width > 0.01 &&
                        rect.height > 0.01) {
                      setState(() => _selectionConfirmed = true);
                    } else {
                      _resetSelection();
                    }
                  },
            child: CustomPaint(
              painter: _SelectionPainter(
                rect: _selectionRect,
                color: theme.colorScheme.primary,
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
    final rect = _selectionRect;
    if (rect == null) return const SizedBox.expand();

    // Position buttons below the selection rect (in pixel coords)
    // Clamp to keep buttons visible within the overlay bounds
    const buttonBarWidth = 100.0;
    const buttonBarHeight = 40.0;
    final bottom = rect.bottom * viewSize.height;
    final centerX = rect.center.dx * viewSize.width;

    // If buttons would overflow below, show above the selection instead
    final spaceBelow = viewSize.height - bottom;
    final top = spaceBelow > buttonBarHeight + 16
        ? bottom + 8
        : (rect.top * viewSize.height) - buttonBarHeight - 8;
    final left = (centerX - buttonBarWidth / 2)
        .clamp(4.0, viewSize.width - buttonBarWidth - 4);

    return Stack(
      children: [
        // Transparent full area to keep gesture detector active
        const SizedBox.expand(),
        // Confirm/Cancel buttons
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
                          : Icon(Icons.check, size: 18,
                              color: theme.colorScheme.primary),
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
                      child: Icon(Icons.close, size: 18,
                          color: theme.colorScheme.mutedForeground),
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

/// Paints the selection rectangle overlay.
class _SelectionPainter extends CustomPainter {
  _SelectionPainter({
    required this.rect,
    required this.color,
  });

  final Rect? rect;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (rect == null) return;

    // Convert normalized rect to pixel rect
    final pixelRect = Rect.fromLTRB(
      rect!.left * size.width,
      rect!.top * size.height,
      rect!.right * size.width,
      rect!.bottom * size.height,
    );

    // Semi-transparent fill
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(pixelRect, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(pixelRect, borderPaint);

    // Corner handles
    const handleSize = 8.0;
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final corner in [
      pixelRect.topLeft,
      pixelRect.topRight,
      pixelRect.bottomLeft,
      pixelRect.bottomRight,
    ]) {
      canvas.drawCircle(corner, handleSize / 2, handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SelectionPainter oldDelegate) {
    return rect != oldDelegate.rect;
  }
}
