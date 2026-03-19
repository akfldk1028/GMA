import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math_64.dart' as vector_math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../../utils/file_system_provider.dart';
import '../../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/note_scrap_provider.dart';
import '../../../scrapnote/providers/scrap_annotation_provider.dart';
import '../providers/workspace_provider.dart';

// ─── Constants ───────────────────────────────────
const _kDefaultCardHeight = 120.0;
const _kCardSpacingY = 40.0;
const _kStartX = 20.0;
const _kStartY = 20.0;

const _kAnnotationColors = <int>[
  0xFF000000, 0xFF1565C0, 0xFFD32F2F, 0xFF2E7D32, 0xFFE65100,
];
const _kAnnotationSizes = <double>[1.0, 2.0, 4.0];

/// draw.io-style infinite canvas for scrap cards.
///
/// - InteractiveViewer: zoom/pan
/// - Cards freely positioned on canvas, draggable
/// - Long-press to delete
/// - Annotate mode: full-canvas drawing layer
class WorkspaceCanvasPanel extends ConsumerStatefulWidget {
  const WorkspaceCanvasPanel({
    super.key,
    required this.noteId,
    required this.pdfPath,
    required this.onNavigateToPage,
    this.onOrderChanged,
  });

  final String? noteId;
  final String? pdfPath;
  final void Function(int pageNumber) onNavigateToPage;
  final void Function(List<String> orderedIds)? onOrderChanged;

  @override
  ConsumerState<WorkspaceCanvasPanel> createState() =>
      WorkspaceCanvasPanelState();
}

class WorkspaceCanvasPanelState extends ConsumerState<WorkspaceCanvasPanel> {
  bool _annotateMode = false;
  int _strokeColor = 0xFF1565C0;
  double _strokeSize = 2.0;

  // Canvas card positions: elementId → Rect(x, y, w, h)
  final Map<String, Rect> _layout = {};

  // Panel-level drawing strokes (absolute canvas coords)
  final List<DrawingStroke> _panelStrokes = [];
  List<Offset> _panelCurrentPoints = [];
  String? _draggedId; // Track which card is being dragged
  bool _orderSyncPending = false;

  final TransformationController _transformCtrl = TransformationController();

  /// Convert screen position to canvas coordinates using current transform.
  Offset _screenToCanvas(Offset screenPos) {
    final inv = Matrix4.inverted(_transformCtrl.value);
    // transform3 ignores translation — must use Vector4 with w=1
    final v = inv.transform(vector_math.Vector4(
        screenPos.dx, screenPos.dy, 0, 1));
    return Offset(v.x, v.y);
  }

  /// Scroll canvas to center the card with the given [elementId].
  void scrollToElement(String elementId) {
    final rect = _layout[elementId];
    if (rect == null) return;
    final viewSize = context.size;
    final halfW = (viewSize?.width ?? 400) / 2;
    final halfH = (viewSize?.height ?? 400) / 2;
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    // ignore: deprecated_member_use
    _transformCtrl.value = Matrix4.identity()..translate(-cx + halfW, -cy + halfH);
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  /// Ensure every element has a position. Auto-layout to fit panel width.
  void _ensureLayoutFit(List<ScrapElement> elements, double cardW) {
    double nextY = _kStartY;
    // Find max Y of existing cards
    for (final r in _layout.values) {
      if (r.bottom + _kCardSpacingY > nextY) {
        nextY = r.bottom + _kCardSpacingY;
      }
    }
    for (final el in elements) {
      if (!_layout.containsKey(el.id)) {
        _layout[el.id] = Rect.fromLTWH(
            _kStartX, nextY, cardW, _kDefaultCardHeight);
        nextY += _kDefaultCardHeight + _kCardSpacingY;
      }
    }
    // Remove stale entries
    final ids = elements.map((e) => e.id).toSet();
    _layout.removeWhere((k, _) => !ids.contains(k));
  }

  @override
  Widget build(BuildContext context) {
    final elements = widget.noteId != null
        ? ref.watch(noteScrapProvider(widget.noteId!))
        : <ScrapElement>[];
    final capturesDir =
        ref.watch(capturesDirectoryProvider).valueOrNull?.path;
    ref.watch(scrapAnnotationStoreProvider);

    final filtered = elements
        .where((e) =>
            e.type == ElementType.capture || e.type == ElementType.lasso)
        .toList();
    return Column(
      children: [
        _CanvasHeader(
          totalCount: filtered.length,
          annotateMode: _annotateMode,
          onAnnotateToggled: () =>
              setState(() => _annotateMode = !_annotateMode),
          onImportPressed: widget.noteId != null
              ? () => _ScrapImportDialog.show(
                    context: context,
                    ref: ref,
                    currentNoteId: widget.noteId!,
                  )
              : null,
          onSwapLayout: () =>
              ref.read(workspaceProviderProvider.notifier).swapLayout(),
          onFoldPanel: () =>
              ref.read(workspaceProviderProvider.notifier).toggleLiveScraps(),
        ),
        if (_annotateMode) _buildAnnotationToolbar(),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final panelW = constraints.maxWidth;
                    final panelH = constraints.maxHeight;
                    final cardW = (panelW * 0.4).clamp(140.0, 300.0);
                    _ensureLayoutFit(filtered, cardW);
                    // Canvas: at least viewport size, expand for cards
                    final maxBottom = _layout.values.fold(
                        panelH, (v, r) => max(v, r.bottom + 200));
                    final maxRight = _layout.values.fold(
                        panelW, (v, r) => max(v, r.right + 100));

                    final canvasContent = SizedBox(
                      width: max(panelW, maxRight),
                      height: max(panelH, maxBottom),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                                painter: _NotebookBgPainter()),
                          ),
                          for (final el in filtered)
                            _buildPositionedCard(
                                el, capturesDir, cardW, filtered),
                          // Drawing strokes always visible
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: true,
                              child: CustomPaint(
                                painter: _AbsoluteStrokePainter(
                                  strokes: _panelStrokes,
                                  liveStroke: _panelCurrentPoints.length >= 2
                                      ? DrawingStroke(
                                          id: 'live',
                                          pageNumber: 0,
                                          points: _panelCurrentPoints
                                              .map((o) => StrokePoint(
                                                  x: o.dx, y: o.dy))
                                              .toList(),
                                          toolId: 'pen',
                                          colorValue: _strokeColor,
                                          size: _strokeSize,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (_annotateMode) {
                      // Annotate mode: no InteractiveViewer,
                      // drawing layer on top captures gestures
                      return ClipRect(
                        child: Stack(
                        children: [
                          // Static canvas (current transform applied)
                          Transform(
                            transform: _transformCtrl.value,
                            child: canvasContent,
                          ),
                          // Drawing input layer (screen coords → canvas coords)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: (d) {
                                final canvasPos = _screenToCanvas(
                                    d.localPosition);
                                setState(() =>
                                    _panelCurrentPoints = [canvasPos]);
                              },
                              onPanUpdate: (d) {
                                final canvasPos = _screenToCanvas(
                                    d.localPosition);
                                setState(() => _panelCurrentPoints = [
                                      ..._panelCurrentPoints,
                                      canvasPos
                                    ]);
                              },
                              onPanEnd: (_) {
                                if (_panelCurrentPoints.length >= 2) {
                                  _panelStrokes.add(DrawingStroke(
                                    id: DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString(),
                                    pageNumber: 0,
                                    points: _panelCurrentPoints
                                        .map((o) => StrokePoint(
                                            x: o.dx, y: o.dy))
                                        .toList(),
                                    toolId: 'pen',
                                    colorValue: _strokeColor,
                                    size: _strokeSize,
                                  ));
                                }
                                setState(
                                    () => _panelCurrentPoints = []);
                              },
                            ),
                          ),
                        ],
                      ),
                      );
                    }

                    // Normal mode: InteractiveViewer with pan/zoom
                    return Listener(
                      onPointerUp: (_) {
                        if (_draggedId != null) {
                          _draggedId = null;
                          _syncOrderByPosition(filtered);
                        }
                      },
                      child: InteractiveViewer(
                      transformationController: _transformCtrl,
                      constrained: false,
                      boundaryMargin: EdgeInsets.zero,
                      minScale: 0.3,
                      maxScale: 3.0,
                      child: canvasContent,
                    ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPositionedCard(
      ScrapElement el, String? capturesDir, double cardW,
      List<ScrapElement> filtered) {
    final rect = _layout[el.id]!;
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: GestureDetector(
        onTap: _annotateMode
            ? null
            : () => widget.onNavigateToPage(el.pageNumber),
        onLongPress: _annotateMode
            ? null
            : () => _showCardMenu(context, el),
        onPanUpdate: _annotateMode
            ? null
            : (details) {
                setState(() {
                  final old = _layout[el.id]!;
                  _layout[el.id] = Rect.fromLTWH(
                    old.left + details.delta.dx,
                    old.top + details.delta.dy,
                    old.width,
                    old.height,
                  );
                  _draggedId = el.id;
                });
              },
        child: Stack(
          children: [
            Positioned.fill(
              child: _ScrapCard(
                element: el,
                capturesDir: capturesDir,
              ),
            ),
            // Resize handle (bottom-right corner)
            if (!_annotateMode)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      final old = _layout[el.id]!;
                      _layout[el.id] = Rect.fromLTWH(
                        old.left,
                        old.top,
                        (old.width + details.delta.dx).clamp(100.0, 800.0),
                        (old.height + details.delta.dy).clamp(80.0, 1000.0),
                      );
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.drag_handle,
                          size: 10, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// After card drag, sync markdown order to match canvas positions.
  /// Sort by y first, then x (top→bottom, left→right).
  void _syncOrderByPosition(List<ScrapElement> filtered) {
    if (widget.noteId == null) return;
    if (_orderSyncPending) {
      _orderSyncPending = false;
      return;
    }

    final withLayout = filtered
        .where((e) => _layout.containsKey(e.id))
        .toList();
    if (withLayout.isEmpty) return;

    // Sort: y ascending, then x ascending
    final sorted = List<ScrapElement>.from(withLayout)
      ..sort((a, b) {
        final ay = _layout[a.id]!.top;
        final by = _layout[b.id]!.top;
        final yCmp = ay.compareTo(by);
        if (yCmp != 0) return yCmp;
        return _layout[a.id]!.left.compareTo(_layout[b.id]!.left);
      });

    // Check if order changed
    bool changed = false;
    for (var i = 0; i < sorted.length && i < filtered.length; i++) {
      if (sorted[i].id != filtered[i].id) {
        changed = true;
        break;
      }
    }
    if (!changed) return;

    _orderSyncPending = true;
    final orderedIds = sorted.map((e) => e.id).toList();
    // Immediately notify sidebar (no async delay)
    widget.onOrderChanged?.call(orderedIds);
    // Also persist to markdown (background)
    ref.read(workspaceProviderProvider.notifier)
        .reorderAllScraps(widget.noteId!, orderedIds);
  }

  void _showCardMenu(BuildContext context, ScrapElement el) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('P${el.pageNumber} #${el.id.substring(0, 6)}',
            style: const TextStyle(fontSize: 14)),
        content: const Text('Delete this scrap?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.noteId != null) {
                ref
                    .read(workspaceProviderProvider.notifier)
                    .removeScrapElement(widget.noteId!, el.id);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationToolbar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          for (final c in _kAnnotationColors)
            GestureDetector(
              onTap: () => setState(() => _strokeColor = c),
              child: Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Color(c),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _strokeColor == c
                        ? Colors.blue.shade700
                        : Colors.grey.shade300,
                    width: _strokeColor == c ? 2 : 1,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Container(width: 1, height: 16, color: Colors.grey.shade300),
          const SizedBox(width: 8),
          for (final s in _kAnnotationSizes)
            GestureDetector(
              onTap: () => setState(() => _strokeSize = s),
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: _strokeSize == s
                      ? Colors.blue.shade50
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                  child: Container(
                    width: s * 3,
                    height: s * 3,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (_panelStrokes.isNotEmpty) {
                setState(() => _panelStrokes.removeLast());
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.undo, size: 16, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_add_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('ScrapNote',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text('Capture or lasso on the PDF\nto add scraps here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

/// Paints strokes using absolute canvas coordinates (not normalized).
class _AbsoluteStrokePainter extends CustomPainter {
  _AbsoluteStrokePainter({required this.strokes, this.liveStroke});
  final List<DrawingStroke> strokes;
  final DrawingStroke? liveStroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawAbsStroke(canvas, stroke);
    }
    if (liveStroke != null) {
      _drawAbsStroke(canvas, liveStroke!);
    }
  }

  void _drawAbsStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) return;
    final paint = Paint()
      ..color = Color(stroke.colorValue)
      ..strokeWidth = stroke.size
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(stroke.points[0].x, stroke.points[0].y);
    for (var i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].x, stroke.points[i].y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AbsoluteStrokePainter old) => true;
}

// ─── Scrap card ──────────────────────────────────

class _ScrapCard extends StatelessWidget {
  const _ScrapCard({
    required this.element,
    this.capturesDir,
  });

  final ScrapElement element;
  final String? capturesDir;

  String? get _resolvedImagePath {
    final img = element.imagePath;
    if (img == null || img.isEmpty || kIsWeb) return null;
    if (p.isAbsolute(img)) {
      if (File(img).existsSync()) return img;
      return null;
    }
    if (capturesDir != null) {
      final resolved = p.join(capturesDir!, img);
      if (File(resolved).existsSync()) return resolved;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imgPath = _resolvedImagePath;
    final isLasso = element.type == ElementType.lasso;

    return Container(
      decoration: BoxDecoration(
        color: isLasso ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: isLasso ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isLasso
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header — compact for lasso
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: isLasso
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.grey.shade50,
                border: isLasso
                    ? null
                    : Border(
                        bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(
                    isLasso ? Icons.gesture : Icons.crop,
                    size: 10,
                    color: isLasso ? Colors.white : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 3),
                  Text('P${element.pageNumber}',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isLasso
                              ? Colors.white
                              : Colors.grey.shade600)),
                ],
              ),
            ),
            // Image — fill remaining space
            Expanded(
              child: imgPath != null
                  ? Image.file(
                      File(imgPath),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 80,
      color: Colors.grey.shade50,
      child: Center(
        child: Icon(Icons.image, size: 24, color: Colors.grey.shade300),
      ),
    );
  }
}

// ─── Canvas header ───────────────────────────────

class _CanvasHeader extends StatelessWidget {
  const _CanvasHeader({
    required this.totalCount,
    required this.annotateMode,
    required this.onAnnotateToggled,
    this.onImportPressed,
    required this.onSwapLayout,
    required this.onFoldPanel,
  });

  final int totalCount;
  final bool annotateMode;
  final VoidCallback onAnnotateToggled;
  final VoidCallback? onImportPressed;
  final VoidCallback onSwapLayout;
  final VoidCallback onFoldPanel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Text('Scraps',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(width: 6),
          Text('$totalCount',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          _iconBtn(Icons.swap_horiz, 'Swap', onSwapLayout),
          _iconBtn(Icons.chevron_right, 'Fold', onFoldPanel),
          GestureDetector(
            onTap: onAnnotateToggled,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: annotateMode
                    ? Colors.blue.shade50
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.edit, size: 14,
                  color: annotateMode
                      ? Colors.blue.shade700
                      : Colors.grey.shade400),
            ),
          ),
          if (onImportPressed != null)
            _iconBtn(Icons.add, 'Import', onImportPressed!),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tip, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Icon(icon, size: 14, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

// ─── Notebook background ─────────────────────────

class _NotebookBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFFBFBFB));

    final linePaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.5;
    for (double y = 24; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Subtle dot grid
    final dotPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (double x = 24; x < size.width; x += 24) {
      for (double y = 24; y < min(size.height, 600); y += 24) {
        canvas.drawPoints(
            ui.PointMode.points, [Offset(x, y)], dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Import dialog ───────────────────────────────

class _ScrapImportDialog {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required String currentNoteId,
  }) async {
    final allElements = ref.read(elementStoreProvider.notifier).all();
    final importable = allElements
        .where((e) =>
            e.type == ElementType.capture || e.type == ElementType.lasso)
        .toList();
    final currentElements = ref.read(noteScrapProvider(currentNoteId));
    final currentIds = currentElements.map((e) => e.id).toSet();
    final available =
        importable.where((e) => !currentIds.contains(e.id)).toList();

    if (available.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No other scraps available to import')),
        );
      }
      return;
    }

    final grouped = <String, List<ScrapElement>>{};
    for (final el in available) {
      grouped.putIfAbsent(el.pdfId, () => []).add(el);
    }

    final capturesDir =
        ref.read(capturesDirectoryProvider).valueOrNull?.path;
    if (!context.mounted) return;

    final selected = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => _ImportDialogContent(
        grouped: grouped,
        capturesDir: capturesDir,
      ),
    );

    if (selected == null || selected.isEmpty) return;
    final wsNotifier = ref.read(workspaceProviderProvider.notifier);
    for (final id in selected) {
      await wsNotifier.appendElementToBlock(currentNoteId, id);
    }
  }
}

class _ImportDialogContent extends StatefulWidget {
  const _ImportDialogContent({required this.grouped, this.capturesDir});
  final Map<String, List<ScrapElement>> grouped;
  final String? capturesDir;

  @override
  State<_ImportDialogContent> createState() => _ImportDialogContentState();
}

class _ImportDialogContentState extends State<_ImportDialogContent> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Scraps', style: TextStyle(fontSize: 16)),
      content: SizedBox(
        width: 320,
        height: 400,
        child: ListView(
          children: widget.grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'PDF: ${entry.key.length > 8 ? '${entry.key.substring(0, 8)}...' : entry.key}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600),
                  ),
                ),
                ...entry.value.map((el) {
                  final sel = _selected.contains(el.id);
                  return GestureDetector(
                    onTap: () => setState(() {
                      sel ? _selected.remove(el.id) : _selected.add(el.id);
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            sel ? Colors.blue.shade50 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: sel
                                ? Colors.blue.shade300
                                : Colors.grey.shade200),
                      ),
                      child: Row(children: [
                        Icon(
                            sel
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 16,
                            color: sel
                                ? Colors.blue.shade700
                                : Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('P${el.pageNumber} ${el.type.name}',
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ]),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.pop(context, _selected.toList()),
            child: Text('Import (${_selected.length})')),
      ],
    );
  }
}
