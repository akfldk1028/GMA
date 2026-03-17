import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../drawing/models/drawing_model.dart';
import '../../../drawing/pages/providers/drawing_provider.dart';
import '../../../drawing/pages/widgets/drawing_canvas.dart';
import '../../../drawing/pages/widgets/stroke_painter.dart';
import '../../models/scrapnote_canvas_model.dart';
import '../providers/scrapnote_canvas_provider.dart';

/// Main canvas widget for a scrapnote linked to [pdfPath].
///
/// Renders freehand strokes via StrokePainter, positions CanvasElements as
/// absolute-coordinate widgets, and layers DrawingCanvas for pen input when
/// drawing mode is active.
class ScrapnoteCanvas extends ConsumerWidget {
  const ScrapnoteCanvas({super.key, required this.pdfPath});

  final String pdfPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasAsync = ref.watch(scrapnoteCanvasProvider(pdfPath));
    final drawingMode = ref.watch(drawingModeProvider);

    return canvasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (canvasData) => _CanvasContent(
        pdfPath: pdfPath,
        canvasData: canvasData,
        drawingMode: drawingMode,
      ),
    );
  }
}

class _CanvasContent extends ConsumerWidget {
  const _CanvasContent({
    required this.pdfPath,
    required this.canvasData,
    required this.drawingMode,
  });

  final String pdfPath;
  final ScrapnoteCanvasData canvasData;
  final DrawingToolState drawingMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Canvas height grows to fit all elements, minimum fills viewport
        final contentHeight = _calculateContentHeight(canvasData.elements);
        final canvasHeight =
            contentHeight > constraints.maxHeight
                ? contentHeight
                : constraints.maxHeight;

        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            height: canvasHeight,
            child: Stack(
              children: [
                // Background layer
                Positioned.fill(
                  child: ColoredBox(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  ),
                ),

                // Stroke rendering layer
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: StrokePainter(strokes: canvasData.strokes),
                    ),
                  ),
                ),

                // Canvas elements layer
                ...canvasData.elements.map(
                  (element) => Positioned(
                    left: element.x,
                    top: element.y,
                    width: element.width,
                    height: element.height,
                    child: _CanvasElementWidget(element: element),
                  ),
                ),

                // Drawing input layer — only active when drawing mode is on
                if (drawingMode.isActive)
                  Positioned.fill(
                    child: DrawingCanvas(
                      isActive: true,
                      strokes: canvasData.strokes,
                      toolId: drawingMode.currentToolId,
                      colorValue: drawingMode.colorValue,
                      strokeSize: drawingMode.strokeSize,
                      pageNumber: 1,
                      onStrokeCompleted: (stroke) {
                        ref
                            .read(scrapnoteCanvasProvider(pdfPath).notifier)
                            .addStroke(stroke);
                      },
                      onStrokeErased: (_, strokeId) {
                        ref
                            .read(scrapnoteCanvasProvider(pdfPath).notifier)
                            .removeStroke(strokeId);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateContentHeight(List<CanvasElement> elements) {
    if (elements.isEmpty) return 0;
    const padding = 40.0;
    return elements.fold<double>(
          0,
          (max, e) {
            final bottom = e.y + e.height;
            return bottom > max ? bottom : max;
          },
        ) +
        padding;
  }
}

/// Renders a single [CanvasElement] on the canvas.
class _CanvasElementWidget extends StatelessWidget {
  const _CanvasElementWidget({required this.element});

  final CanvasElement element;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (element.type == CanvasElementType.capture) {
      return _CaptureElementWidget(element: element, isDark: isDark);
    }
    return _HighlightElementWidget(element: element, isDark: isDark);
  }
}

/// Displays a capture element as an image with a border.
class _CaptureElementWidget extends StatelessWidget {
  const _CaptureElementWidget({
    required this.element,
    required this.isDark,
  });

  final CanvasElement element;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final imagePath = element.imagePath;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
        borderRadius: BorderRadius.circular(4),
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
      ),
      clipBehavior: Clip.hardEdge,
      child: imagePath != null && imagePath.isNotEmpty
          ? Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _ImageErrorPlaceholder(isDark: isDark),
            )
          : _ImageErrorPlaceholder(isDark: isDark),
    );
  }
}

/// Displays a highlight element as a card with a colored left border.
class _HighlightElementWidget extends StatelessWidget {
  const _HighlightElementWidget({
    required this.element,
    required this.isDark,
  });

  final CanvasElement element;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final highlightColor = Color(element.colorValue);
    final text = element.selectedText ?? '';
    final snippet = text.length > 120 ? '${text.substring(0, 120)}...' : text;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        border: Border(
          left: BorderSide(color: highlightColor, width: 4),
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          right: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        snippet.isNotEmpty ? snippet : '(empty)',
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white70 : Colors.black87,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Fallback displayed when a capture image cannot be loaded.
class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: isDark ? Colors.white38 : Colors.black26,
        size: 32,
      ),
    );
  }
}
