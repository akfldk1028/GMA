import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/drawing_model.dart';
import '../../tools/eraser_tool.dart';
import '../../tools/tool_registry.dart';
import 'stroke_painter.dart';

/// Drawing input canvas — captures pointer events and renders strokes.
///
/// Uses Listener (not GestureDetector) to get raw pointer data including
/// stylus pressure. Single-pointer only: multi-touch passes through to pdfrx
/// for pinch-zoom.
///
/// When [isActive] is false, wrapped in IgnorePointer so all events go to
/// the underlying PDF viewer (scroll, text selection).
///
/// For eraser tool: uses hit-test to remove intersected strokes (AC-09).
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    super.key,
    required this.isActive,
    required this.strokes,
    required this.toolId,
    required this.colorValue,
    required this.strokeSize,
    required this.pageNumber,
    required this.onStrokeCompleted,
    this.onStrokeErased,
  });

  final bool isActive;
  final List<DrawingStroke> strokes;
  final String toolId;
  final int colorValue;
  final double strokeSize;
  final int pageNumber;
  final void Function(DrawingStroke stroke) onStrokeCompleted;

  /// Called when eraser removes a stroke. Passes (pageNumber, strokeId).
  final void Function(int pageNumber, String strokeId)? onStrokeErased;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  static const _uuid = Uuid();

  DrawingStroke? _currentStroke;
  int? _activePointerId;

  @override
  Widget build(BuildContext context) {
    final child = RepaintBoundary(
      child: CustomPaint(
        painter: StrokePainter(
          strokes: widget.strokes,
          currentStroke: _currentStroke,
        ),
        size: Size.infinite,
      ),
    );

    if (!widget.isActive) {
      return IgnorePointer(child: child);
    }

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_activePointerId != null) return;
    _activePointerId = event.pointer;

    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    final nx = event.localPosition.dx / size.width;
    final ny = event.localPosition.dy / size.height;

    // Eraser hit-test on pointer down
    if (widget.toolId == 'eraser') {
      _applyEraserHitTest(nx, ny, size);
      return;
    }

    setState(() {
      _currentStroke = DrawingStroke(
        id: _uuid.v4(),
        pageNumber: widget.pageNumber,
        toolId: widget.toolId,
        colorValue: widget.colorValue,
        size: widget.strokeSize,
        points: [
          StrokePoint(
            x: nx,
            y: ny,
            pressure: _getPressure(event),
          ),
        ],
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointerId) return;

    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    final nx = event.localPosition.dx / size.width;
    final ny = event.localPosition.dy / size.height;

    // Eraser continues hit-testing on move
    if (widget.toolId == 'eraser') {
      _applyEraserHitTest(nx, ny, size);
      return;
    }

    if (_currentStroke == null) return;

    setState(() {
      _currentStroke = _currentStroke!.copyWith(
        points: [
          ..._currentStroke!.points,
          StrokePoint(
            x: nx,
            y: ny,
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

  void _applyEraserHitTest(double nx, double ny, Size size) {
    final tool = getToolById('eraser');
    if (tool is! EraserTool) return;

    // Eraser proximity radius in normalized coordinates
    final eraserRadius = widget.strokeSize * 2 / size.width;

    for (final stroke in widget.strokes) {
      // AABB pre-filter: skip strokes whose bounding box does not overlap the
      // eraser area. This is a cheap O(1) rejection before the expensive
      // per-point hit-test inside isStrokeHit.
      if (stroke.points.isNotEmpty) {
        var minX = stroke.points.first.x;
        var maxX = minX;
        var minY = stroke.points.first.y;
        var maxY = minY;
        for (final p in stroke.points) {
          if (p.x < minX) minX = p.x;
          if (p.x > maxX) maxX = p.x;
          if (p.y < minY) minY = p.y;
          if (p.y > maxY) maxY = p.y;
        }
        // Expand bounding box by stroke half-width in normalized coords
        final halfWidth = stroke.size / 2 / size.width;
        minX -= halfWidth;
        maxX += halfWidth;
        minY -= halfWidth;
        maxY += halfWidth;

        // Reject if eraser circle does not overlap the expanded bounding box
        if (nx + eraserRadius < minX ||
            nx - eraserRadius > maxX ||
            ny + eraserRadius < minY ||
            ny - eraserRadius > maxY) {
          continue;
        }
      }

      if (tool.isStrokeHit(
        stroke: stroke,
        pointerX: nx,
        pointerY: ny,
        eraserSize: eraserRadius,
      )) {
        widget.onStrokeErased?.call(widget.pageNumber, stroke.id);
      }
    }
  }

  double? _getPressure(PointerEvent event) {
    if (event.pressureMin < 1.0) {
      return event.pressure;
    }
    return null;
  }
}
