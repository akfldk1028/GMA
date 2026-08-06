import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gma_app/features/scrapnote/models/element_model.dart';
import '../models/highlight_marker_data.dart';
import '../providers/highlight_provider.dart';

// @MX:NOTE: HighlightOverlay renders below the drawing layer (see PdfPageOverlay).
// It uses IgnorePointer so highlight rectangles never consume pointer events —
// all gestures pass through to the PDF viewer or the drawing canvas above.

/// Renders highlight annotations for a single PDF page as a [CustomPaint].
///
/// Reads [highlightMarkersProvider] to obtain markers for [pageNumber] and
/// passes them to [_HighlightPainter]. The widget is wrapped in [IgnorePointer]
/// so it never intercepts touch/pointer events.
class HighlightOverlay extends ConsumerWidget {
  const HighlightOverlay({
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
    final markersMap = ref.watch(highlightMarkersProvider(documentPath));
    final markers = markersMap[pageNumber] ?? const [];

    return IgnorePointer(
      child: CustomPaint(
        size: Size(pageWidth, pageHeight),
        painter: _HighlightPainter(
          markers: markers,
          pageWidth: pageWidth,
          pageHeight: pageHeight,
        ),
      ),
    );
  }
}

/// Paints highlight rectangles onto a PDF page canvas.
///
/// Each [HighlightMarkerData] may contain multiple [ElementRect] values
/// (for multi-line selections). Rectangles are drawn with [_kOpacity] applied
/// on top of the stored ARGB color to produce a translucent highlight effect.
class _HighlightPainter extends CustomPainter {
  const _HighlightPainter({
    required this.markers,
    required this.pageWidth,
    required this.pageHeight,
  });

  final List<HighlightMarkerData> markers;
  final double pageWidth;
  final double pageHeight;

  /// Opacity fraction applied to the stored color value (30–40 % per SPEC).
  static const double _kOpacity = 0.35;

  @override
  void paint(Canvas canvas, Size size) {
    for (final marker in markers) {
      final baseColor = Color(marker.colorValue);
      final paint = Paint()
        // ignore: deprecated_member_use
        ..color = baseColor.withOpacity(_kOpacity)
        ..style = PaintingStyle.fill;

      for (final rect in marker.normalizedRects) {
        final pixelRect = _toPixelRect(rect, size);
        canvas.drawRect(pixelRect, paint);
      }
    }
  }

  /// Converts a normalized [ElementRect] (0-1 range) to pixel coordinates
  /// using [size] (the canvas size provided by [CustomPaint]).
  Rect _toPixelRect(ElementRect normalized, Size size) {
    return Rect.fromLTRB(
      normalized.left * size.width,
      normalized.top * size.height,
      normalized.right * size.width,
      normalized.bottom * size.height,
    );
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) {
    return oldDelegate.markers != markers ||
        oldDelegate.pageWidth != pageWidth ||
        oldDelegate.pageHeight != pageHeight;
  }

  /// Highlights never participate in hit-testing — all events pass through.
  @override
  bool hitTest(Offset position) => false;
}
