import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/drawing_model.dart';
import 'stroke_painter.dart';

/// Drawing input canvas — captures pointer events and renders strokes.
///
/// Uses Listener (not GestureDetector) to get raw pointer data including
/// stylus pressure. Single-pointer only: multi-touch passes through to pdfrx
/// for pinch-zoom.
///
/// When [isActive] is false, wrapped in IgnorePointer so all events go to
/// the underlying PDF viewer (scroll, text selection).
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
  });

  final bool isActive;
  final List<DrawingStroke> strokes;
  final String toolId;
  final int colorValue;
  final double strokeSize;
  final int pageNumber;
  final void Function(DrawingStroke stroke) onStrokeCompleted;

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
    // Only track a single pointer (ignore second finger for pinch-zoom)
    if (_activePointerId != null) return;
    _activePointerId = event.pointer;

    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    setState(() {
      _currentStroke = DrawingStroke(
        id: _uuid.v4(),
        pageNumber: widget.pageNumber,
        toolId: widget.toolId,
        colorValue: widget.colorValue,
        size: widget.strokeSize,
        points: [
          StrokePoint(
            x: event.localPosition.dx / size.width,
            y: event.localPosition.dy / size.height,
            pressure: _getPressure(event),
          ),
        ],
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointerId || _currentStroke == null) return;

    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    setState(() {
      _currentStroke = _currentStroke!.copyWith(
        points: [
          ..._currentStroke!.points,
          StrokePoint(
            x: event.localPosition.dx / size.width,
            y: event.localPosition.dy / size.height,
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

  /// Extract pressure from pointer event.
  /// Returns null if device doesn't support pressure (will be simulated).
  double? _getPressure(PointerEvent event) {
    // pressureMin < 1 indicates the device supports pressure (e.g. stylus)
    if (event.pressureMin < 1.0) {
      return event.pressure;
    }
    return null;
  }
}
