import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../providers/pdf_structure_provider.dart';

/// Paints semi-transparent bounding boxes over detected PDF structure elements.
///
/// Each element type gets a distinct color:
/// - heading: blue, table: green, image: orange,
/// - paragraph: gray (subtle), list: teal, formula: purple
///
/// Uses the same pagePaintCallbacks pattern as PdfPageOverlay/CaptureHighlightOverlay.
class StructureOverlay {
  StructureOverlay._();

  static List<PdfViewerPagePaintCallback> createPaintCallbacks(
    WidgetRef ref,
  ) {
    return [
      (Canvas canvas, Rect pageRect, PdfPage page) {
        final structureState = ref.read(pdfStructureProvider);
        if (structureState.result == null) return;

        final elements =
            structureState.result!.elementsForPage(page.pageNumber);
        if (elements.isEmpty) return;

        for (final element in elements) {
          // Skip paragraphs to reduce visual noise (optional: make configurable)
          if (element.type == 'paragraph') continue;

          final pdfRect = element.toPdfRect();

          // Use pdfrx built-in conversion (handles Y-flip + rotation + scale)
          final screenRect = pdfRect.toRectInDocument(
            page: page,
            pageRect: pageRect,
          );

          final color = _colorForType(element.type);

          // Semi-transparent fill
          canvas.drawRect(
            screenRect,
            Paint()
              ..color = color.withValues(alpha: 0.08)
              ..style = PaintingStyle.fill,
          );

          // Border
          canvas.drawRect(
            screenRect,
            Paint()
              ..color = color.withValues(alpha: 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );

          // Type label (top-left corner, tiny text)
          _drawTypeLabel(canvas, screenRect, element.type, color);
        }
      },
    ];
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'heading':
        return const Color(0xFF3B82F6); // blue
      case 'table':
        return const Color(0xFF10B981); // green
      case 'image':
        return const Color(0xFFF59E0B); // amber
      case 'list':
        return const Color(0xFF14B8A6); // teal
      case 'formula':
        return const Color(0xFF8B5CF6); // purple
      case 'caption':
        return const Color(0xFFEC4899); // pink
      default:
        return const Color(0xFF6B7280); // gray
    }
  }

  static void _drawTypeLabel(
    Canvas canvas,
    Rect rect,
    String type,
    Color color,
  ) {
    // Only draw label if rect is big enough
    if (rect.width < 30 || rect.height < 10) return;

    final label = _shortLabel(type);
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color.withValues(alpha: 0.7),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Background for readability
    final bgRect = Rect.fromLTWH(
      rect.left,
      rect.top - textPainter.height - 2,
      textPainter.width + 4,
      textPainter.height + 2,
    );
    canvas.drawRect(
      bgRect,
      Paint()..color = color.withValues(alpha: 0.1),
    );

    textPainter.paint(canvas, Offset(rect.left + 2, rect.top - textPainter.height - 1));
  }

  static String _shortLabel(String type) {
    switch (type) {
      case 'heading':
        return 'H';
      case 'table':
        return 'T';
      case 'image':
        return 'IMG';
      case 'list':
        return 'L';
      case 'formula':
        return 'F';
      case 'caption':
        return 'CAP';
      default:
        return type.substring(0, 1).toUpperCase();
    }
  }
}
