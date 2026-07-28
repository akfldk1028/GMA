import 'dart:math';

import 'package:vector_math/vector_math_64.dart' as vector_math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../../pdf_viewer/drawing/pages/providers/drawing_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/note_scrap_provider.dart';
import '../../../scrapnote/providers/scrap_annotation_provider.dart';
import '../providers/workspace_provider.dart';
import '../../services/workspace_persistence.dart';

import 'canvas/canvas_card.dart';
import 'canvas/canvas_handles.dart';
import 'canvas/canvas_header.dart';
import 'canvas/canvas_painters.dart';
import 'canvas/group_edit_dialog.dart';
import 'canvas/scrap_import_dialog.dart';

// ─── Constants ───────────────────────────────────
// Layout ratios (relative to panel width)
const _kCardHeightRatio = 0.25;   // card height = 25% of panel width
const _kCardSpacingRatio = 0.06;  // spacing = 6% of panel width
const _kPaddingRatio = 0.04;      // start padding = 4% of panel width

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

  /// Whether drawing mode is active (reads from main toolbar DrawingMode provider).
  bool get _annotateMode => ref.read(drawingModeProvider).isActive;
  int get _strokeColor => ref.read(drawingModeProvider).colorValue;
  double get _strokeSize => ref.read(drawingModeProvider).strokeSize;

  // Canvas card positions: elementId → Rect(x, y, w, h)
  final Map<String, Rect> _layout = {};

  // Panel-level drawing strokes (absolute canvas coords)
  final List<DrawingStroke> _panelStrokes = [];
  List<Offset> _panelCurrentPoints = [];
  String? _draggedId; // Track which card is being dragged
  bool _orderSyncPending = false;
  final Set<String> _selectedCardIds = {}; // Multi-select support
  final Map<String, double> _rotations = {}; // elementId → angle in radians
  bool _isRotating = false; // Prevent card move during rotation

  final TransformationController _transformCtrl = TransformationController();

  /// Reset zoom/pan to fit all cards in the viewport.
  void _fitAllCards() {
    if (_layout.isEmpty) {
      setState(() => _transformCtrl.value = Matrix4.identity());
      return;
    }
    final viewSize = context.size;
    if (viewSize == null) return;

    // Compute bounding box of all cards
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final r in _layout.values) {
      if (r.left < minX) minX = r.left;
      if (r.top < minY) minY = r.top;
      if (r.right > maxX) maxX = r.right;
      if (r.bottom > maxY) maxY = r.bottom;
    }
    final contentW = maxX - minX;
    final contentH = maxY - minY;
    if (contentW <= 0 || contentH <= 0) {
      setState(() => _transformCtrl.value = Matrix4.identity());
      return;
    }

    // Scale to fit with padding
    const padding = 40.0;
    final availW = viewSize.width - padding * 2;
    final availH = viewSize.height - 36 - padding * 2; // subtract header
    final scale = (min(availW / contentW, availH / contentH)).clamp(0.3, 1.0);
    final tx = padding - minX * scale + (availW - contentW * scale) / 2;
    final ty = padding - minY * scale + (availH - contentH * scale) / 2;

    setState(() {
      // ignore: deprecated_member_use
      _transformCtrl.value = Matrix4.identity()..translate(tx, ty)..scale(scale, scale);
    });
  }

  /// Zoom canvas by [factor] centered on viewport.
  void _zoom(double factor) {
    final m = _transformCtrl.value.clone();
    // Current scale
    final currentScale = m.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.3, 3.0);
    final scaleDelta = newScale / currentScale;
    // Scale around center of viewport
    m.scale(scaleDelta, scaleDelta);
    setState(() => _transformCtrl.value = m);
  }

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
  void initState() {
    super.initState();
    _loadGroupEditsFromHive();
    _loadCanvasLayout();
    _loadCanvasStrokes();
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  /// Ensure every element has a position. Auto-layout to fit panel width.
  /// Capture cards use their PdfRect aspect ratio for height;
  /// highlight cards use a compact fixed height.
  void _ensureLayoutFit(List<ScrapElement> elements, double cardW, double panelW) {
    final startX = panelW * _kPaddingRatio;
    final startY = panelW * _kPaddingRatio;
    final defaultCardH = panelW * _kCardHeightRatio;
    final spacing = panelW * _kCardSpacingRatio;

    double nextY = startY;
    for (final r in _layout.values) {
      if (r.bottom + spacing > nextY) {
        nextY = r.bottom + spacing;
      }
    }
    for (final el in elements) {
      if (!_layout.containsKey(el.id)) {
        double cardH = defaultCardH;
        // For capture/lasso: compute height from source rect aspect ratio
        if ((el.type == ElementType.capture || el.type == ElementType.lasso) &&
            el.rect != null) {
          final rectW = (el.rect!.right - el.rect!.left).abs();
          final rectH = (el.rect!.top - el.rect!.bottom).abs();
          if (rectW > 0 && rectH > 0) {
            cardH = cardW * rectH / rectW;
            cardH = cardH.clamp(60.0, panelW * 1.5);
          }
        }
        _layout[el.id] = Rect.fromLTWH(startX, nextY, cardW, cardH);
        nextY += cardH + spacing;
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
    // Watch drawing mode so canvas rebuilds when toolbar changes
    ref.watch(drawingModeProvider);

    final filtered = elements
        .where((e) =>
            e.type == ElementType.capture ||
            e.type == ElementType.lasso ||
            e.type == ElementType.highlight)
        .toList();
    return Column(
      children: [
        CanvasHeader(
          totalCount: filtered.length,
          onImportPressed: widget.noteId != null
              ? () => ScrapImportDialog.show(
                    context: context,
                    ref: ref,
                    currentNoteId: widget.noteId!,
                  )
              : null,
          onZoomIn: () => _zoom(1.3),
          onZoomOut: () => _zoom(0.7),
          onZoomReset: () => _fitAllCards(),
          onSwapLayout: () =>
              ref.read(workspaceProviderProvider.notifier).swapLayout(),
          onFoldPanel: () =>
              ref.read(workspaceProviderProvider.notifier).toggleLiveScraps(),
        ),
        Expanded(
          child: LayoutBuilder(
                  builder: (context, constraints) {
                    final panelW = constraints.maxWidth;
                    final panelH = constraints.maxHeight;
                    final cardW = (panelW * 0.85).clamp(200.0, panelW - 20);
                    _ensureLayoutFit(filtered, cardW, panelW);
                    // Infinite canvas: wide enough for free panning
                    const minCanvasH = 5000.0;
                    const minCanvasW = 3000.0;
                    final maxBottom = _layout.values.fold(
                        minCanvasH, (v, r) => max(v, r.bottom + panelH));
                    final maxRight = _layout.values.fold(
                        minCanvasW, (v, r) => max(v, r.right + panelW));

                    final canvasContent = SizedBox(
                      width: max(panelW, maxRight),
                      height: max(panelH, maxBottom),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                if (_selectedCardIds.isNotEmpty) {
                                  setState(() {
                                    _selectedCardIds.clear();
                                    _syncSelectionToWorkspace();
                                  });
                                }
                              },
                              child: CustomPaint(
                                  painter: NotebookBgPainter()),
                            ),
                          ),
                          // Drawing strokes behind cards (notebook writing layer)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: true,
                              child: CustomPaint(
                                painter: AbsoluteStrokePainter(
                                  strokes: _panelStrokes,
                                  liveStroke: _panelCurrentPoints.length >= 2
                                      ? DrawingStroke(
                                          id: 'live',
                                          pageNumber: 0,
                                          points: _panelCurrentPoints
                                              .map((o) => StrokePoint(
                                                  x: o.dx, y: o.dy))
                                              .toList(),
                                          toolId: ref.read(drawingModeProvider).currentToolId,
                                          colorValue: ref.read(drawingModeProvider).currentToolId == 'eraser'
                                              ? 0x40FF0000  // 반투명 빨강
                                              : _strokeColor,
                                          size: ref.read(drawingModeProvider).currentToolId == 'eraser'
                                              ? _strokeSize * 2
                                              : _strokeSize,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          for (final el in filtered)
                            _buildPositionedCard(
                                el, capturesDir, cardW, filtered, panelW),
                          // Group bounding box handles (multi-select OR grouped card selected)
                          if (_selectedCardIds.isNotEmpty && !_annotateMode &&
                              (_selectedCardIds.length > 1 || _isAnySelectedInGroup()))
                            ..._buildGroupHandlesWidgets(),
                          // Rotation handle
                          if (_selectedCardIds.isNotEmpty && !_annotateMode)
                            _buildRotationHandleForSelection(),
                          // Group edit strokes (rendered per group)
                          ..._buildGroupEditStrokes(filtered),
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
                                  final toolId = ref.read(drawingModeProvider).currentToolId;
                                  if (toolId == 'eraser') {
                                    _handleCanvasErase(_panelCurrentPoints);
                                  } else {
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
                                  _persistCanvasStrokes();
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
                      boundaryMargin: const EdgeInsets.all(1000),
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
      List<ScrapElement> filtered, double canvasW) {
    final rect = _layout[el.id]!;
    final isSelected = _selectedCardIds.contains(el.id);
    final isInGroup = ref.read(workspaceProviderProvider.notifier)
        .findGroupOf(el.id) != null;
    // Show individual handles only for ungrouped single selection
    final showIndividualHandles = isSelected &&
        _selectedCardIds.length == 1 && !isInGroup;

    final rotation = _rotations[el.id] ?? 0.0;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
        onTap: _annotateMode
            ? null
            : () {
                // Single tap → toggle selection (multi-select friendly)
                final wasSelected = isSelected;
                setState(() {
                  if (wasSelected) {
                    _selectedCardIds.remove(el.id);
                  } else {
                    final group = ref.read(workspaceProviderProvider.notifier)
                        .findGroupOf(el.id);
                    if (group != null) {
                      _selectedCardIds.addAll(group);
                    } else {
                      _selectedCardIds.add(el.id);
                    }
                  }
                  _syncSelectionToWorkspace();
                });
                // Navigate to PDF page only when selecting, not deselecting
                if (!wasSelected && el.pageNumber > 0) {
                  widget.onNavigateToPage(el.pageNumber);
                }
              },
        onLongPress: _annotateMode
            ? null
            : () {
                // Long press → toggle selection (for multi-select/group)
                setState(() {
                  if (isSelected) {
                    _selectedCardIds.remove(el.id);
                  } else {
                    _selectedCardIds.add(el.id);
                  }
                  _syncSelectionToWorkspace();
                });
              },
        onPanUpdate: _annotateMode
            ? null
            : (details) {
                if (_isRotating) return;
                setState(() {
                  if (!_selectedCardIds.contains(el.id)) {
                    _selectedCardIds.clear();
                    _selectedCardIds.add(el.id);
                    _syncSelectionToWorkspace();
                  }
                  // Move ALL selected + grouped cards together
                  final movable = _getMovableIds(el.id);
                  for (final id in movable) {
                    final old = _layout[id];
                    if (old == null) continue;
                    final newLeft = max(0.0, old.left + details.delta.dx);
                    final newTop = max(0.0, old.top + details.delta.dy);
                    _layout[id] = Rect.fromLTWH(
                      newLeft,
                      newTop,
                      old.width,
                      old.height,
                    );
                  }
                  _draggedId = el.id;
                });
              },
        onPanEnd: _annotateMode
            ? null
            : (_) {
                if (_draggedId != null) {
                  _draggedId = null;
                  _syncOrderByPosition(filtered);
                  _persistCanvasLayout();
                }
              },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card content
            Positioned.fill(
              child: Container(
                decoration: isSelected
                    ? BoxDecoration(
                        border: Border.all(
                          color: Colors.blue.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                child: CanvasScrapCard(
                  element: el,
                  capturesDir: capturesDir,
                ),
              ),
            ),
            // Individual handles (ungrouped single selection only)
            if (showIndividualHandles && !_annotateMode) ...[
              buildHandle(elId: el.id, pos: HandlePos.topLeft, onResize: _onHandleResize),
              buildHandle(elId: el.id, pos: HandlePos.bottomLeft, onResize: _onHandleResize),
              buildHandle(elId: el.id, pos: HandlePos.bottomRight, onResize: _onHandleResize),
              buildHandle(elId: el.id, pos: HandlePos.bottomCenter, onResize: _onHandleResize),
              // X button (top-right, replaces topRight resize handle)
              Positioned(
                right: -16,
                top: -16,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedCardIds.remove(el.id);
                      _syncSelectionToWorkspace();
                    });
                    _showCardMenu(context, el);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  // ─── Handle resize callback ───────────────────────

  void _onHandleResize(String elId, HandlePos pos, Offset delta) {
    setState(() {
      final old = _layout[elId]!;
      double l = old.left, t = old.top, w = old.width, h = old.height;
      final dx = delta.dx;
      final dy = delta.dy;
      switch (pos) {
        case HandlePos.topLeft:
          l += dx; t += dy; w -= dx; h -= dy;
        case HandlePos.topRight:
          t += dy; w += dx; h -= dy;
        case HandlePos.bottomLeft:
          l += dx; w -= dx; h += dy;
        case HandlePos.bottomRight:
          w += dx; h += dy;
        case HandlePos.topCenter:
          t += dy; h -= dy;
        case HandlePos.bottomCenter:
          h += dy;
      }
      _layout[elId] = Rect.fromLTWH(
        l, t, w.clamp(80.0, 800.0), h.clamp(60.0, 1000.0),
      );
    });
  }

  // ─── Group edit persistence ────────────────────────

  Future<void> _saveGroupEditToHive(String key, GroupEditResult result) async {
    await WorkspacePersistence.saveGroupEdit(key, result.toJson());
  }

  Future<void> _loadGroupEditsFromHive() async {
    final all = await WorkspacePersistence.loadAllGroupEdits();
    for (final entry in all.entries) {
      _groupEditResults[entry.key] = GroupEditResult.fromJson(entry.value);
    }
  }

  /// Render saved group edit strokes on the main canvas.
  List<Widget> _buildGroupEditStrokes(List<ScrapElement> filtered) {
    final widgets = <Widget>[];
    final ws = ref.read(workspaceProviderProvider).valueOrNull;
    if (ws == null) return widgets;

    for (final group in ws.scrapGroups) {
      final key = _groupKey(group.toSet());
      final result = _groupEditResults[key];
      if (result == null || result.strokes.isEmpty) continue;

      // Current bounding box on main canvas
      double curMinX = double.infinity, curMinY = double.infinity;
      double curMaxX = -double.infinity, curMaxY = -double.infinity;
      for (final id in group) {
        final rect = _layout[id];
        if (rect == null) continue;
        if (rect.left < curMinX) curMinX = rect.left;
        if (rect.top < curMinY) curMinY = rect.top;
        if (rect.right > curMaxX) curMaxX = rect.right;
        if (rect.bottom > curMaxY) curMaxY = rect.bottom;
      }
      if (curMinX == double.infinity) continue;

      // Edit-time bounding box (from saved card states)
      double editMinX = double.infinity, editMinY = double.infinity;
      double editMaxX = -double.infinity, editMaxY = -double.infinity;
      for (final id in group) {
        final cs = result.cardStates[id];
        if (cs == null) continue;
        if (cs.layout.left < editMinX) editMinX = cs.layout.left;
        if (cs.layout.top < editMinY) editMinY = cs.layout.top;
        if (cs.layout.right > editMaxX) editMaxX = cs.layout.right;
        if (cs.layout.bottom > editMaxY) editMaxY = cs.layout.bottom;
      }
      if (editMinX == double.infinity) continue;

      // Scale factor: current size / edit-time size
      final editW = editMaxX - editMinX;
      final editH = editMaxY - editMinY;
      final curW = curMaxX - curMinX;
      final curH = curMaxY - curMinY;
      final scaleX = editW > 0 ? curW / editW : 1.0;
      final scaleY = editH > 0 ? curH / editH : 1.0;

      // Compute average rotation of group members
      double avgRotation = 0.0;
      int rotCount = 0;
      for (final id in group) {
        final r = _rotations[id];
        if (r != null && r != 0.0) {
          avgRotation += r;
          rotCount++;
        }
      }
      if (rotCount > 0) avgRotation /= rotCount;

      widgets.add(Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: GroupStrokePainter(
              strokes: result.strokes,
              editOriginX: editMinX,
              editOriginY: editMinY,
              canvasOriginX: curMinX,
              canvasOriginY: curMinY,
              scaleX: scaleX,
              scaleY: scaleY,
              rotation: avgRotation,
              centerX: (curMinX + curMaxX) / 2,
              centerY: (curMinY + curMaxY) / 2,
            ),
          ),
        ),
      ));
    }
    return widgets;
  }

  /// Save canvas layout to persistence (call after drag/resize).
  Future<void> _persistCanvasLayout() async {
    if (widget.noteId == null) return;
    final data = <String, Map<String, double>>{};
    for (final entry in _layout.entries) {
      data[entry.key] = {
        'l': entry.value.left, 't': entry.value.top,
        'w': entry.value.width, 'h': entry.value.height,
      };
    }
    await WorkspacePersistence.saveCanvasLayout(widget.noteId!, data);
  }

  /// Save rotations to persistence.
  Future<void> _persistCanvasRotations() async {
    if (widget.noteId == null) return;
    await WorkspacePersistence.saveCanvasRotations(widget.noteId!, _rotations);
  }

  /// Load saved canvas layout on init, then auto-fit.
  Future<void> _loadCanvasLayout() async {
    if (widget.noteId == null) return;
    final saved = await WorkspacePersistence.loadCanvasLayout(widget.noteId!);
    for (final entry in saved.entries) {
      _layout[entry.key] = Rect.fromLTWH(
        entry.value['l'] ?? 0, entry.value['t'] ?? 0,
        entry.value['w'] ?? 200, entry.value['h'] ?? 120,
      );
    }
    final rotations = await WorkspacePersistence.loadCanvasRotations(widget.noteId!);
    _rotations.addAll(rotations);
    if (mounted) {
      setState(() {});
      // Auto-fit after layout is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _layout.isNotEmpty) _fitAllCards();
      });
    }
  }

  /// Eraser hit-test: remove panel strokes and scrap cards hit by eraser path.
  /// Called once on panEnd (same pattern as DrawingOverlay._handleEraserHit).
  void _handleCanvasErase(List<Offset> eraserPoints) {
    const hitRadius = 14.0;
    final hitRadiusSq = hitRadius * hitRadius;

    // 1. Remove drawn strokes that intersect the eraser path
    _panelStrokes.removeWhere((stroke) {
      for (final sp in stroke.points) {
        for (final ep in eraserPoints) {
          final dx = sp.x - ep.dx;
          final dy = sp.y - ep.dy;
          if (dx * dx + dy * dy < hitRadiusSq) return true;
        }
      }
      return false;
    });

    // 2. Remove scrap cards that intersect the eraser path
    if (widget.noteId != null) {
      final hitIds = <String>[];
      for (final entry in _layout.entries) {
        final rect = entry.value;
        for (final ep in eraserPoints) {
          if (rect.contains(ep)) {
            hitIds.add(entry.key);
            break;
          }
        }
      }
      for (final id in hitIds) {
        ref.read(workspaceProviderProvider.notifier)
            .removeScrapElement(widget.noteId!, id);
      }
    }
  }

  /// Save canvas strokes to persistence.
  Future<void> _persistCanvasStrokes() async {
    if (widget.noteId == null) return;
    final data = _panelStrokes.map((s) => s.toJson()).toList();
    await WorkspacePersistence.saveCanvasStrokes(widget.noteId!, data);
  }

  /// Load saved canvas strokes on init.
  Future<void> _loadCanvasStrokes() async {
    if (widget.noteId == null) return;
    final saved = await WorkspacePersistence.loadCanvasStrokes(widget.noteId!);
    if (saved.isNotEmpty && mounted) {
      setState(() {
        for (final json in saved) {
          try {
            _panelStrokes.add(DrawingStroke.fromJson(json));
          } catch (_) {}
        }
      });
    }
  }

  // ─── Group / Delete actions ────────────────────────

  void _groupSelectedCards() {
    ref.read(workspaceProviderProvider.notifier).groupSelectedScraps();
  }

  void _ungroupSelectedCards() {
    // Migrate group edit strokes to panel strokes before dissolving
    _migrateGroupStrokesToPanel(_selectedCardIds);
    ref.read(workspaceProviderProvider.notifier)
        .ungroupScraps(_selectedCardIds);
  }

  /// Convert group edit strokes to absolute panel strokes.
  void _migrateGroupStrokesToPanel(Set<String> ids) {
    final key = _groupKey(ids);
    final result = _groupEditResults[key];
    if (result == null || result.strokes.isEmpty) return;

    // Compute current group bounding box
    double curMinX = double.infinity, curMinY = double.infinity;
    double curMaxX = -double.infinity, curMaxY = -double.infinity;
    for (final id in ids) {
      final rect = _layout[id];
      if (rect == null) continue;
      if (rect.left < curMinX) curMinX = rect.left;
      if (rect.top < curMinY) curMinY = rect.top;
      if (rect.right > curMaxX) curMaxX = rect.right;
      if (rect.bottom > curMaxY) curMaxY = rect.bottom;
    }
    if (curMinX == double.infinity) return;

    // Edit-time bounding box
    double editMinX = double.infinity, editMinY = double.infinity;
    double editMaxX = -double.infinity, editMaxY = -double.infinity;
    for (final id in ids) {
      final cs = result.cardStates[id];
      if (cs == null) continue;
      if (cs.layout.left < editMinX) editMinX = cs.layout.left;
      if (cs.layout.top < editMinY) editMinY = cs.layout.top;
      if (cs.layout.right > editMaxX) editMaxX = cs.layout.right;
      if (cs.layout.bottom > editMaxY) editMaxY = cs.layout.bottom;
    }
    if (editMinX == double.infinity) return;

    final editW = editMaxX - editMinX;
    final editH = editMaxY - editMinY;
    final curW = curMaxX - curMinX;
    final curH = curMaxY - curMinY;
    final scaleX = editW > 0 ? curW / editW : 1.0;
    final scaleY = editH > 0 ? curH / editH : 1.0;

    // Convert each group stroke to a DrawingStroke in canvas coords
    for (final s in result.strokes) {
      final points = s.points.map((p) {
        final cx = curMinX + (p.dx - editMinX) * scaleX;
        final cy = curMinY + (p.dy - editMinY) * scaleY;
        return StrokePoint(x: cx, y: cy);
      }).toList();
      _panelStrokes.add(DrawingStroke(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        pageNumber: 0,
        points: points,
        toolId: 'pen',
        colorValue: s.color,
        size: s.size,
      ));
    }

    // Remove from group edit results and persist
    _groupEditResults.remove(key);
    _persistCanvasStrokes();
  }

  void _deleteSelectedCards() {
    if (_selectedCardIds.isEmpty || widget.noteId == null) return;
    final idsToDelete = _selectedCardIds.toList();
    for (final id in idsToDelete) {
      ref.read(workspaceProviderProvider.notifier)
          .removeScrapElement(widget.noteId!, id);
    }
    setState(() {
      _selectedCardIds.clear();
      _syncSelectionToWorkspace();
    });
  }

  /// When dragging a selected card, also move its group members.
  Set<String> _getMovableIds(String dragId) {
    final ids = Set<String>.from(_selectedCardIds);
    final notifier = ref.read(workspaceProviderProvider.notifier);
    final group = notifier.findGroupOf(dragId);
    if (group != null) ids.addAll(group);
    return ids;
  }

  bool _isAnySelectedInGroup() {
    for (final id in _selectedCardIds) {
      if (ref.read(workspaceProviderProvider.notifier).findGroupOf(id) != null) {
        return true;
      }
    }
    return false;
  }

  bool get _isSelectionGrouped =>
      ref.read(workspaceProviderProvider.notifier).isSelectionGrouped();

  // Store group edit results keyed by sorted element IDs
  final Map<String, GroupEditResult> _groupEditResults = {};

  String _groupKey(Set<String> ids) {
    final sorted = ids.toList()..sort();
    return sorted.join('|');
  }

  void _showGroupEditModal(BuildContext context) {
    final elements = <ScrapElement>[];
    final allElements = widget.noteId != null
        ? ref.read(noteScrapProvider(widget.noteId!))
        : <ScrapElement>[];
    for (final el in allElements) {
      if (_selectedCardIds.contains(el.id)) {
        elements.add(el);
      }
    }
    final capturesDir =
        ref.watch(capturesDirectoryProvider).valueOrNull?.path;
    final key = _groupKey(_selectedCardIds);
    final previousState = _groupEditResults[key];

    showDialog(
      context: context,
      builder: (ctx) => GroupEditDialog(
        elements: elements,
        capturesDir: capturesDir,
        previousState: previousState,
        onConfirm: (result) {
          setState(() {
            // Apply card layout/rotation
            for (final entry in result.cardStates.entries) {
              _layout[entry.key] = entry.value.layout;
              if (entry.value.rotation != 0.0) {
                _rotations[entry.key] = entry.value.rotation;
              }
            }
            // Save full result for next open
            _groupEditResults[key] = result;
          });
          // Persist to Hive
          _saveGroupEditToHive(key, result);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  /// Compute bounding box of all selected cards.
  Rect? _groupBounds() {
    if (_selectedCardIds.isEmpty) return null;
    double minL = double.infinity, minT = double.infinity;
    double maxR = double.negativeInfinity, maxB = double.negativeInfinity;
    for (final id in _selectedCardIds) {
      final r = _layout[id];
      if (r == null) continue;
      if (r.left < minL) minL = r.left;
      if (r.top < minT) minT = r.top;
      if (r.right > maxR) maxR = r.right;
      if (r.bottom > maxB) maxB = r.bottom;
    }
    if (minL == double.infinity) return null;

    // Expand bounds to include group edit strokes (with scale)
    final key = _groupKey(_selectedCardIds);
    final result = _groupEditResults[key];
    if (result != null && result.strokes.isNotEmpty) {
      // Calculate edit-time bounding box
      double editMinX = double.infinity, editMinY = double.infinity;
      double editMaxX = -double.infinity, editMaxY = -double.infinity;
      for (final id in _selectedCardIds) {
        final cs = result.cardStates[id];
        if (cs == null) continue;
        if (cs.layout.left < editMinX) editMinX = cs.layout.left;
        if (cs.layout.top < editMinY) editMinY = cs.layout.top;
        if (cs.layout.right > editMaxX) editMaxX = cs.layout.right;
        if (cs.layout.bottom > editMaxY) editMaxY = cs.layout.bottom;
      }
      if (editMinX != double.infinity) {
        final editW = editMaxX - editMinX;
        final editH = editMaxY - editMinY;
        final curW = maxR - minL;
        final curH = maxB - minT;
        final sx = editW > 0 ? curW / editW : 1.0;
        final sy = editH > 0 ? curH / editH : 1.0;
        for (final s in result.strokes) {
          for (final p in s.points) {
            final px = minL + (p.dx - editMinX) * sx;
            final py = minT + (p.dy - editMinY) * sy;
            if (px < minL) minL = px;
            if (py < minT) minT = py;
            if (px > maxR) maxR = px;
            if (py > maxB) maxB = py;
          }
        }
      }
    }

    return Rect.fromLTRB(minL, minT, maxR, maxB);
  }

  /// Build group bounding box outline + corner handles for multi-select.
  List<Widget> _buildGroupHandlesWidgets() {
    final bounds = _groupBounds();
    if (bounds == null) return [];
    return buildGroupHandles(
      bounds: bounds,
      isGrouped: _isSelectionGrouped,
      onGroup: _groupSelectedCards,
      onUngroup: _ungroupSelectedCards,
      onDelete: _deleteSelectedCards,
      onEdit: () => _showGroupEditModal(context),
      onResize: (sx, sy, anchor) {
        setState(() {
          for (final id in _selectedCardIds) {
            final old = _layout[id];
            if (old == null) continue;
            // Scale position relative to anchor + scale size
            final newLeft = anchor.dx + (old.left - anchor.dx) * sx;
            final newTop = anchor.dy + (old.top - anchor.dy) * sy;
            final newW = (old.width * sx).clamp(60.0, 800.0);
            final newH = (old.height * sy).clamp(40.0, 1000.0);
            _layout[id] = Rect.fromLTWH(newLeft, newTop, newW, newH);
          }
        });
      },
    );
  }

  /// Rotation handle for current selection (single card or group).
  Widget _buildRotationHandleForSelection() {
    if (_selectedCardIds.length == 1) {
      final id = _selectedCardIds.first;
      if (!_layout.containsKey(id)) return const SizedBox.shrink();
      return _buildRotationHandleOverlay(id);
    }
    // Multi-select: use group bounds
    final bounds = _groupBounds();
    if (bounds == null) return const SizedBox.shrink();
    final cx = bounds.left + bounds.width / 2;
    final handleTop = bounds.top - 42;
    return buildRotationHandleAt(
      cx: cx,
      handleTop: handleTop,
      onRotateStart: () => _isRotating = true,
      onRotate: (delta) {
        setState(() {
          for (final id in _selectedCardIds) {
            _rotations[id] = (_rotations[id] ?? 0.0) + delta;
          }
        });
      },
      onRotateEnd: () {
        _isRotating = false;
        _persistCanvasRotations();
      },
    );
  }

  Widget _buildRotationHandleOverlay(String elId) {
    final rect = _layout[elId]!;
    final cx = rect.left + rect.width / 2;
    final handleTop = rect.top - 34;
    return buildRotationHandleAt(
      cx: cx,
      handleTop: handleTop,
      onRotateStart: () => _isRotating = true,
      onRotate: (delta) {
        setState(() {
          _rotations[elId] = (_rotations[elId] ?? 0.0) + delta;
        });
      },
      onRotateEnd: () {
        _isRotating = false;
        _persistCanvasRotations();
      },
    );
  }

  /// Sync local selection to WorkspaceState so left sidebar reflects it.
  void _syncSelectionToWorkspace() {
    ref.read(workspaceProviderProvider.notifier)
        .setScrapSelection(Set<String>.from(_selectedCardIds));
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
    // Persist canvas layout
    _persistCanvasLayout();
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

}

