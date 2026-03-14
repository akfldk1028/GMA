import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' hide StrokePoint;
import 'package:uuid/uuid.dart';

import '../../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../../pdf_viewer/drawing/tools/tool_registry.dart';
import '../../models/scrapnote_canvas_model.dart';
import 'capture_element_widget.dart';
import 'highlight_card_widget.dart';

/// CustomPainter for scrapnote strokes that uses ABSOLUTE pixel coordinates.
///
/// Unlike StrokePainter (normalized 0-1 coords), this painter uses points
/// directly in canvas pixel space (1080px-wide canvas).
// @MX:ANCHOR: [AUTO] Scrapnote-specific stroke renderer — uses absolute coords, not normalized.
// @MX:REASON: High fan_in — ScrapnoteCanvas widget depends on this; coordinate contract differs from StrokePainter.
class ScrapnoteStrokePainter extends CustomPainter {
  ScrapnoteStrokePainter({
    required this.strokes,
    this.currentStroke,
  });

  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final hasEraserStroke = strokes.any((s) => s.toolId == 'eraser') ||
        (currentStroke?.toolId == 'eraser');

    if (hasEraserStroke) {
      canvas.saveLayer(Offset.zero & size, Paint());
    }

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }

    if (hasEraserStroke) {
      canvas.restore();
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final tool = getToolById(stroke.toolId);
    final options = tool.getStrokeOptions(size: stroke.size);
    final paint = tool.getPaint(color: Color(stroke.colorValue));

    // Absolute coordinates: no normalization, use x/y directly.
    final points = stroke.points
        .map((p) => PointVector(
              p.x,
              p.y,
              p.pressure ?? 0.5,
            ))
        .toList();

    final outlinePoints = getStroke(points, options: options);
    if (outlinePoints.isEmpty) return;

    final path = Path();
    if (outlinePoints.length == 1) {
      path.addOval(Rect.fromCircle(
        center: outlinePoints.first,
        radius: options.size / 2,
      ));
    } else {
      path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
      for (int i = 1; i < outlinePoints.length - 1; i++) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ScrapnoteStrokePainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.currentStroke != currentStroke;
}

/// Scrapnote drawing canvas with infinite vertical scroll via InteractiveViewer.
///
/// Renders [strokes] using [ScrapnoteStrokePainter] (absolute pixel coords).
/// Overlays [elements] as positioned widgets.
/// Captures pointer input via [Listener] for pen/highlighter/eraser tools.
///
/// Canvas logical width is fixed at [canvasWidth] (default 1080px).
/// Height is unbounded (infinite scroll).
// @MX:NOTE: [AUTO] Uses absolute pixel coords for strokes (1080-wide canvas). Do not mix with normalized PDF stroke coords.
class ScrapnoteCanvas extends StatefulWidget {
  const ScrapnoteCanvas({
    super.key,
    required this.strokes,
    required this.elements,
    required this.isActive,
    required this.onStrokeCompleted,
    this.toolId = 'pen',
    this.colorValue = 0xFF000000,
    this.strokeSize = 3.0,
    this.canvasWidth = 1080.0,
  });

  final List<DrawingStroke> strokes;
  final List<CanvasElement> elements;
  final bool isActive;
  final void Function(DrawingStroke stroke) onStrokeCompleted;
  final String toolId;
  final int colorValue;
  final double strokeSize;
  final double canvasWidth;

  @override
  State<ScrapnoteCanvas> createState() => _ScrapnoteCanvasState();
}

class _ScrapnoteCanvasState extends State<ScrapnoteCanvas> {
  static const _uuid = Uuid();

  DrawingStroke? _currentStroke;
  int? _activePointerId;

  @override
  Widget build(BuildContext context) {
    final paintArea = SizedBox(
      width: widget.canvasWidth,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: ScrapnoteStrokePainter(
            strokes: widget.strokes,
            currentStroke: _currentStroke,
          ),
          child: _buildElementOverlay(),
        ),
      ),
    );

    final interactiveCanvas = InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.5,
      maxScale: 4.0,
      child: paintArea,
    );

    if (!widget.isActive) {
      return IgnorePointer(child: interactiveCanvas);
    }

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.opaque,
      child: interactiveCanvas,
    );
  }

  Widget _buildElementOverlay() {
    if (widget.elements.isEmpty) {
      return const SizedBox.expand();
    }

    return Stack(
      children: widget.elements.map((element) {
        return Positioned(
          left: element.x,
          top: element.y,
          width: element.width,
          height: element.height,
          child: _buildElementWidget(element),
        );
      }).toList(),
    );
  }

  Widget _buildElementWidget(CanvasElement element) {
    switch (element.type) {
      case CanvasElementType.capture:
        return CaptureElementWidget(element: element);
      case CanvasElementType.highlight:
        return HighlightCardWidget(element: element);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_activePointerId != null) return;
    _activePointerId = event.pointer;

    setState(() {
      _currentStroke = DrawingStroke(
        id: _uuid.v4(),
        pageNumber: 0,
        toolId: widget.toolId,
        colorValue: widget.colorValue,
        size: widget.strokeSize,
        points: [
          StrokePoint(
            x: event.localPosition.dx,
            y: event.localPosition.dy,
            pressure: _getPressure(event),
          ),
        ],
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointerId || _currentStroke == null) return;

    setState(() {
      _currentStroke = _currentStroke!.copyWith(
        points: [
          ..._currentStroke!.points,
          StrokePoint(
            x: event.localPosition.dx,
            y: event.localPosition.dy,
            pressure: _getPressure(event),
          ),
        ],
      );
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointerId) return;
    _finishStroke();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointerId) return;
    _finishStroke();
  }

  void _finishStroke() {
    _activePointerId = null;
    if (_currentStroke != null && _currentStroke!.points.length >= 2) {
      widget.onStrokeCompleted(_currentStroke!);
    }
    setState(() {
      _currentStroke = null;
    });
  }

  double? _getPressure(PointerEvent event) {
    if (event.pressureMin < 1.0) {
      return event.pressure;
    }
    return null;
  }
}
