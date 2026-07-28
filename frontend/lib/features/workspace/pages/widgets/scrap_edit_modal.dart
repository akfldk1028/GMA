import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../utils/file_system_provider.dart';
import '../../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/scrap_annotation_provider.dart';

/// Centered modal for editing a single scrap element.
///
/// Shows the scrap's content (image for capture/lasso, text for highlight)
/// as a static background, with an overlay canvas where the user can draw
/// freehand strokes that get persisted per-element via
/// [ScrapAnnotationStore]. The modal is intentionally small/focused so the
/// user can scribble notes/marks directly on top of a single scrap without
/// leaving the workspace.
class ScrapEditModal extends ConsumerStatefulWidget {
  const ScrapEditModal({
    super.key,
    required this.element,
    required this.onClose,
  });

  final ScrapElement element;
  final VoidCallback onClose;

  @override
  ConsumerState<ScrapEditModal> createState() => _ScrapEditModalState();
}

class _ScrapEditModalState extends ConsumerState<ScrapEditModal> {
  // Live-stroke buffer in normalized [0..1] coords. Drawn alongside the
  // persisted strokes for immediate visual feedback during a stroke.
  // Storing normalized lets the same stroke render at any size, so the
  // panel-side card preview can paint the same strokes scaled to its
  // smaller dimensions without separate "modal vs card" coords.
  List<Offset> _liveStrokePoints = [];
  Color _color = Colors.red;
  double _size = 3.0;
  bool _eraserMode = false;

  // Captured each frame from the drawing-area LayoutBuilder so onPan
  // handlers can normalize raw localPosition pixels.
  Size _drawSize = Size.zero;

  Offset _toNormalized(Offset px) {
    if (_drawSize.width <= 0 || _drawSize.height <= 0) return Offset.zero;
    return Offset(px.dx / _drawSize.width, px.dy / _drawSize.height);
  }

  void _commitLiveStroke() {
    if (_liveStrokePoints.length < 2) {
      setState(() => _liveStrokePoints = []);
      return;
    }
    final stroke = DrawingStroke(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      pageNumber: 0,
      toolId: _eraserMode ? 'eraser' : 'pen',
      colorValue: _color.toARGB32(),
      // Store the visible stroke width in *normalized-height units* so the
      // panel-side card painter can multiply by its own height to get a
      // proportionally similar look. Pick height because most cards are
      // taller than wide and width-scaling alone makes strokes look thin.
      size: _drawSize.height > 0 ? _size / _drawSize.height : _size,
      points: _liveStrokePoints
          .map((o) => StrokePoint(x: o.dx, y: o.dy))
          .toList(),
    );
    ref
        .read(scrapAnnotationStoreProvider.notifier)
        .addStroke(widget.element.id, stroke);
    setState(() => _liveStrokePoints = []);
  }

  void _undo() => ref
      .read(scrapAnnotationStoreProvider.notifier)
      .undoStroke(widget.element.id);

  void _clear() => ref
      .read(scrapAnnotationStoreProvider.notifier)
      .clearStrokes(widget.element.id);

  @override
  Widget build(BuildContext context) {
    // Watch the store so the canvas repaints when strokes change.
    ref.watch(scrapAnnotationStoreProvider);
    final strokes = ref
        .read(scrapAnnotationStoreProvider.notifier)
        .getStrokes(widget.element.id);
    final capturesDir =
        ref.watch(capturesDirectoryProvider).valueOrNull?.path;

    final size = MediaQuery.sizeOf(context);
    final modalW = size.width * 0.85;
    final modalH = size.height * 0.85;

    return Stack(
      children: [
        // Dimmed background
        GestureDetector(
          onTap: widget.onClose,
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        Center(
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: modalW,
              height: modalH,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _Toolbar(
                    color: _color,
                    size: _size,
                    eraserMode: _eraserMode,
                    onColor: (c) => setState(() {
                      _color = c;
                      _eraserMode = false;
                    }),
                    onSize: (s) => setState(() => _size = s),
                    onEraserToggle: () =>
                        setState(() => _eraserMode = !_eraserMode),
                    onUndo: _undo,
                    onClear: _clear,
                    onClose: widget.onClose,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        _drawSize = Size(constraints.maxWidth, constraints.maxHeight);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: (d) {
                                setState(() {
                                  _liveStrokePoints = [
                                    _toNormalized(d.localPosition)
                                  ];
                                });
                              },
                              onPanUpdate: (d) {
                                setState(() {
                                  _liveStrokePoints = [
                                    ..._liveStrokePoints,
                                    _toNormalized(d.localPosition),
                                  ];
                                });
                              },
                              onPanEnd: (_) => _commitLiveStroke(),
                              onPanCancel: _commitLiveStroke,
                              child: Stack(
                                children: [
                                  // Scrap content (background, can't intercept)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: _ScrapContent(
                                        element: widget.element,
                                        capturesDir: capturesDir,
                                      ),
                                    ),
                                  ),
                                  // Persisted + live strokes overlay
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: CustomPaint(
                                        painter: ScrapStrokeOverlayPainter(
                                          strokes: strokes,
                                          liveStroke: _liveStrokePoints,
                                          liveColor: _eraserMode
                                              ? Colors.white
                                              : _color,
                                          // Convert pixel size back to
                                          // normalized for live preview so
                                          // it matches the painter's *
                                          // size.height scaling.
                                          liveSizeNorm: _drawSize.height > 0
                                              ? (_eraserMode
                                                      ? _size * 3
                                                      : _size) /
                                                  _drawSize.height
                                              : 0.005,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.color,
    required this.size,
    required this.eraserMode,
    required this.onColor,
    required this.onSize,
    required this.onEraserToggle,
    required this.onUndo,
    required this.onClear,
    required this.onClose,
  });

  final Color color;
  final double size;
  final bool eraserMode;
  final ValueChanged<Color> onColor;
  final ValueChanged<double> onSize;
  final VoidCallback onEraserToggle;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onClose;

  static const _palette = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.black,
  ];

  static const _sizes = [2.0, 4.0, 7.0];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        // Color swatches
        for (final c in _palette)
          GestureDetector(
            onTap: () => onColor(c),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: !eraserMode && color == c
                      ? Colors.blue
                      : Colors.grey.shade400,
                  width: !eraserMode && color == c ? 3 : 1,
                ),
              ),
            ),
          ),
        const SizedBox(width: 4),
        // Stroke size buttons
        for (final s in _sizes)
          GestureDetector(
            onTap: () => onSize(s),
            child: Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: size == s ? Colors.blue.shade50 : Colors.transparent,
                border: Border.all(
                  color: size == s ? Colors.blue : Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Container(
                width: s * 1.6,
                height: s * 1.6,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Eraser',
          icon: Icon(
            Icons.cleaning_services,
            color: eraserMode ? Colors.blue : Colors.grey.shade700,
          ),
          onPressed: onEraserToggle,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          tooltip: 'Undo',
          icon: const Icon(Icons.undo),
          onPressed: onUndo,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        IconButton(
          tooltip: 'Clear all',
          icon: const Icon(Icons.delete_outline),
          onPressed: onClear,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: onClose,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

class _ScrapContent extends StatelessWidget {
  const _ScrapContent({required this.element, this.capturesDir});

  final ScrapElement element;
  final String? capturesDir;

  String? get _resolvedImagePath {
    final img = element.imagePath;
    if (img == null || img.isEmpty) return null;
    if (p.isAbsolute(img)) {
      return File(img).existsSync() ? img : null;
    }
    if (capturesDir != null) {
      final resolved = p.join(capturesDir!, img);
      if (File(resolved).existsSync()) return resolved;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (element.type == ElementType.highlight) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            element.selectedText ?? 'Highlight',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      );
    }
    final path = _resolvedImagePath;
    if (path == null) {
      return Center(
        child: Text(
          'Image not found',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }
}

/// Paints scrap-annotation strokes on top of a content canvas.
///
/// Both [strokes] and [liveStroke] use normalized [0..1] coordinates and
/// [liveSizeNorm] / `DrawingStroke.size` are normalized fractions of
/// height — multiply by the canvas dimensions to get pixels. This is
/// what lets the same persisted strokes render at modal size *and* at
/// the smaller scrap-card size in the right panel without double-storage.
class ScrapStrokeOverlayPainter extends CustomPainter {
  ScrapStrokeOverlayPainter({
    required this.strokes,
    this.liveStroke = const [],
    this.liveColor = Colors.transparent,
    this.liveSizeNorm = 0,
  });

  final List<DrawingStroke> strokes;
  final List<Offset> liveStroke;
  final Color liveColor;
  final double liveSizeNorm;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      _drawStroke(
        canvas,
        size,
        s.points.map((p) => Offset(p.x, p.y)).toList(),
        Color(s.colorValue),
        s.size,
        eraser: s.toolId == 'eraser',
      );
    }
    if (liveStroke.length >= 2) {
      _drawStroke(
        canvas,
        size,
        liveStroke,
        liveColor,
        liveSizeNorm,
        eraser: false,
      );
    }
  }

  void _drawStroke(
    Canvas canvas,
    Size size,
    List<Offset> normPts,
    Color color,
    double normW, {
    required bool eraser,
  }) {
    if (normPts.length < 2) return;
    final paint = Paint()
      ..color = eraser ? Colors.white : color
      ..strokeWidth = (normW * size.height).clamp(0.5, 200.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    if (eraser) {
      paint.blendMode = BlendMode.clear;
    }
    Offset toPx(Offset n) => Offset(n.dx * size.width, n.dy * size.height);
    final path = Path()..moveTo(toPx(normPts.first).dx, toPx(normPts.first).dy);
    for (var i = 1; i < normPts.length; i++) {
      final p = toPx(normPts[i]);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ScrapStrokeOverlayPainter old) =>
      old.strokes != strokes ||
      old.liveStroke != liveStroke ||
      old.liveColor != liveColor ||
      old.liveSizeNorm != liveSizeNorm;
}
