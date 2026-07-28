import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../../pdf_viewer/drawing/pages/providers/drawing_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/note_scrap_provider.dart';
import '../../../scrapnote/providers/scrap_annotation_provider.dart';
import '../providers/workspace_provider.dart';
import '../../services/workspace_persistence.dart';

import 'canvas/canvas_card.dart';
import 'canvas/canvas_header.dart';
import 'canvas/canvas_painters.dart';
import 'canvas/scrap_import_dialog.dart';
import 'notebook/notebook_card_props.dart';
import 'notebook/notebook_handles.dart';
import 'notebook/notebook_stroke_painter.dart';
import 'scrap_edit_modal.dart';

/// Draw.io-style scrap canvas with sequential default placement.
///
/// - Cards have absolute (x, y, w, h, rotation); freely draggable to any position
/// - New cards get a sequential default position (below the last card)
/// - Tap card to select → 4 corner handles + rotation stem appear
/// - Long-press + drag = move card (avoids vertical-scroll conflict)
/// - Drawing layer covers entire canvas (panel-absolute coords)
/// - Eraser removes only strokes; cards deleted via X button
/// - Cross-PDF scrap import via header button
class NotebookScrapPanel extends ConsumerStatefulWidget {
  const NotebookScrapPanel({
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
  ConsumerState<NotebookScrapPanel> createState() => NotebookScrapPanelState();
}

class NotebookScrapPanelState extends ConsumerState<NotebookScrapPanel> {
  // Pan + zoom + scroll all delegated to InteractiveViewer. We read the
  // current scale from this controller for layout decisions (e.g. centering
  // newly-added cards into view).
  final TransformationController _transformCtrl = TransformationController();
  static const double _zoomMin = 0.4;
  static const double _zoomMax = 3.0;

  // Stroke layer (canvas-absolute coords)
  final List<DrawingStroke> _strokes = [];
  List<Offset> _liveStrokePoints = [];
  int? _activePointer;

  // Per-card props
  final Map<String, NotebookCardProps> _props = {};

  // Currently being dragged or resized; while non-null, InteractiveViewer
  // pan is disabled so the card gesture wins arena.
  String? _draggingId;
  // ID of a newly-added card pending an auto-scroll on the next frame.
  String? _pendingScrollTo;

  // Canvas-coord origin of the inner Stack. Computed each build to include
  // any cards that were dragged into negative absX/absY space. Stack
  // hit-test is bounded by its own rect (clipBehavior.none renders but
  // doesn't extend hit area), so cards at negative coords would be
  // unclickable without this offset.
  double _canvasOriginX = 0;
  double _canvasOriginY = 0;

  bool get _annotateMode => ref.watch(drawingModeProvider).isActive;
  String get _toolId => ref.watch(drawingModeProvider).currentToolId;
  int get _strokeColor => ref.watch(drawingModeProvider).colorValue;
  double get _strokeSize => ref.watch(drawingModeProvider).strokeSize;

  /// Current zoom from the InteractiveViewer transformation matrix.
  double get _zoom => _transformCtrl.value.getMaxScaleOnAxis();

  @override
  void initState() {
    super.initState();
    _loadStrokes();
    _loadCardProps();
    _transformCtrl.addListener(() {
      // Trigger rebuild so layout responds to zoom/pan changes that other
      // widgets read (e.g. selection-handle proportional sizing).
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  // ─── Persistence ──────────────────────────────────────────────────

  Future<void> _loadStrokes() async {
    if (widget.noteId == null) return;
    final saved = await WorkspacePersistence.loadCanvasStrokes(widget.noteId!);
    if (!mounted || saved.isEmpty) return;
    setState(() {
      for (final json in saved) {
        try {
          _strokes.add(DrawingStroke.fromJson(json));
        } catch (_) {}
      }
    });
  }

  Future<void> _persistStrokes() async {
    if (widget.noteId == null) return;
    final data = _strokes.map((s) => s.toJson()).toList();
    await WorkspacePersistence.saveCanvasStrokes(widget.noteId!, data);
  }

  Future<void> _loadCardProps() async {
    if (widget.noteId == null) return;
    final saved = await WorkspacePersistence.loadNotebookCardProps(
      widget.noteId!,
    );
    debugPrint(
      '[NotebookScrapPanel] loaded ${saved.length} saved card props for note=${widget.noteId}: '
      '${saved.entries.map((e) => "${e.key.substring(0, 6)}=${e.value}").join(", ")}',
    );
    if (!mounted || saved.isEmpty) return;
    setState(() {
      for (final entry in saved.entries) {
        try {
          _props[entry.key] = NotebookCardProps.fromJson(entry.value);
        } catch (_) {}
      }
    });
  }

  Future<void> _persistCardProps() async {
    if (widget.noteId == null) return;
    final data = _props.map((k, v) => MapEntry(k, v.toJson()));
    await WorkspacePersistence.saveNotebookCardProps(widget.noteId!, data);
  }

  /// Measure the height of a highlight card so it fits the text content.
  /// Mirrors the layout in `CanvasScrapCard._buildHighlightCard`:
  /// - 3px left accent bar (no horizontal contribution to text width)
  /// - 12px horizontal padding on each side
  /// - 10px vertical padding on each side
  /// - TextStyle(fontSize: 13, height: 1.45)
  double _measureHighlightHeight(String text, double cardWidth) {
    const accentW = 3.0;
    const hPad = 12.0;
    const vPad = 10.0;
    final textWidth = (cardWidth - accentW - hPad * 2).clamp(40.0, 4000.0);
    final tp = TextPainter(
      text: TextSpan(
        text: text.isEmpty ? 'Highlight' : text,
        style: const TextStyle(fontSize: 13, height: 1.45, letterSpacing: 0.1),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: textWidth);
    final h = tp.height + vPad * 2;
    return h.clamp(NotebookConst.minHeight, NotebookConst.maxHeight);
  }

  /// Ensure every element has a [NotebookCardProps]. New elements get a sequential
  /// position below the lowest existing card. Returns IDs that were just
  /// added so the caller can trigger an auto-scroll / persist.
  List<String> _ensurePropsFor(List<ScrapElement> cards, double panelW) {
    final innerW = math.max(80.0, panelW - 2 * NotebookConst.pad);

    // Compute next-Y for new cards (max bottom of existing + spacing).
    // Only consider on-screen cards; off-screen ones get clamped below.
    double nextY = NotebookConst.pad;
    for (final p in _props.values) {
      final bot = p.absY + p.height;
      if (bot + NotebookConst.cardSpacing > nextY) {
        nextY = bot + NotebookConst.cardSpacing;
      }
    }

    // (No off-screen clamp — InteractiveViewer lets cards live anywhere
    // on the canvas. The user can pan/zoom to find a card no matter
    // where they dropped it.)

    final added = <String>[];
    // Default card width: fills most of the panel so cards read like
    // notebook lines instead of floating tiles. Capped at 720 so it
    // doesn't get absurdly wide on desktop.
    final defaultCardW = math.min(innerW * 0.92, 720.0);

    for (final el in cards) {
      if (_props.containsKey(el.id)) continue;
      double w = math.min(defaultCardW, innerW);
      double h = NotebookConst.defaultHeight;
      if (el.type == ElementType.highlight) {
        // Auto-fit height to the highlight text.
        h = _measureHighlightHeight(el.selectedText ?? 'Highlight', w);
      } else if ((el.type == ElementType.capture ||
              el.type == ElementType.lasso) &&
          el.rect != null) {
        final rectW = (el.rect!.right - el.rect!.left).abs();
        final rectH = (el.rect!.top - el.rect!.bottom).abs();
        if (rectW > 0 && rectH > 0) {
          h = (w * rectH / rectW).clamp(
            NotebookConst.minHeight,
            NotebookConst.maxHeight,
          );
        }
      }
      // Centered horizontally inside the panel
      final x = NotebookConst.pad + (innerW - w) / 2;
      _props[el.id] = NotebookCardProps(
        absX: x,
        absY: nextY,
        width: w,
        height: h,
      );
      added.add(el.id);
      nextY += h + NotebookConst.cardSpacing;
    }

    // Drop props for elements no longer in the note
    final ids = cards.map((e) => e.id).toSet();
    _props.removeWhere((k, _) => !ids.contains(k));

    return added;
  }

  /// Scroll/pan the canvas so the given card is roughly centered in view.
  void scrollToElement(String elementId) {
    final p = _props[elementId];
    if (p == null) return;
    final viewportSize = context.size;
    if (viewportSize == null) return;
    final z = _zoom;
    // Card center in canvas coords. The InteractiveViewer transforms
    // SizedBox-local coords (canvas - origin) to panel coords, so the
    // translate must subtract the canvas origin too.
    final cardCx = p.absX + p.width / 2;
    final cardCy = p.absY + p.height / 2;
    final tx = viewportSize.width / 2 - (cardCx - _canvasOriginX) * z;
    final ty = viewportSize.height / 2 - (cardCy - _canvasOriginY) * z;
    final m = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(z, z);
    _transformCtrl.value = m;
  }

  // ─── Drawing input ────────────────────────────────────────────────
  // (Pinch-to-zoom and pan are handled by InteractiveViewer; pointer
  // listener below is only used to capture pen/finger drawing strokes
  // when annotateMode is on.)

  void _onPointerDown(PointerDownEvent event) {
    if (!_annotateMode) return;
    if (_activePointer != null) return;
    _activePointer = event.pointer;
    setState(() {
      _liveStrokePoints = [_toCanvasCoords(event.localPosition)];
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer) return;
    setState(() {
      _liveStrokePoints = [
        ..._liveStrokePoints,
        _toCanvasCoords(event.localPosition),
      ];
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) return;
    _finishStroke();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;
    _finishStroke();
  }

  /// Convert pointer position (Listener-local, in InteractiveViewer's outer
  /// coords) to canvas coords by inverting the transformation matrix and
  /// then adding the canvas origin (so the result is in absX/absY space,
  /// not Stack-local space).
  Offset _toCanvasCoords(Offset screenLocal) {
    final inv = Matrix4.inverted(_transformCtrl.value);
    final localX =
        inv.storage[0] * screenLocal.dx +
        inv.storage[4] * screenLocal.dy +
        inv.storage[12];
    final localY =
        inv.storage[1] * screenLocal.dx +
        inv.storage[5] * screenLocal.dy +
        inv.storage[13];
    return Offset(localX + _canvasOriginX, localY + _canvasOriginY);
  }

  void _finishStroke() {
    _activePointer = null;
    if (_liveStrokePoints.length >= 2) {
      if (_toolId == 'eraser') {
        _eraseAt(_liveStrokePoints);
      } else {
        _strokes.add(
          DrawingStroke(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            pageNumber: 0,
            toolId: _toolId,
            colorValue: _strokeColor,
            size: _strokeSize,
            points: _liveStrokePoints
                .map((p) => StrokePoint(x: p.dx, y: p.dy))
                .toList(),
          ),
        );
      }
      _persistStrokes();
    }
    setState(() => _liveStrokePoints = []);
  }

  void _eraseAt(List<Offset> path) {
    const hitR = 14.0;
    const hitR2 = hitR * hitR;
    setState(() {
      _strokes.removeWhere((s) {
        for (final sp in s.points) {
          for (final ep in path) {
            final dx = sp.x - ep.dx;
            final dy = sp.y - ep.dy;
            if (dx * dx + dy * dy < hitR2) return true;
          }
        }
        return false;
      });
    });
  }

  // ─── Card interactions ────────────────────────────────────────────

  /// Tap on a card. Single tap toggles selection. If the tapped card belongs
  /// to a saved group, the entire group toggles together.
  void _onCardTap(ScrapElement el) {
    final notifier = ref.read(workspaceProviderProvider.notifier);
    final selected =
        ref.read(workspaceProviderProvider).valueOrNull?.selectedScrapIds ??
        const <String>{};
    final group = notifier.findGroupOf(el.id);
    final wasSelected = selected.contains(el.id);
    final next = Set<String>.from(selected);
    if (wasSelected) {
      // Deselect: remove this card AND any group members.
      next.remove(el.id);
      if (group != null) next.removeAll(group);
    } else {
      // Select: add this card AND any group members.
      next.add(el.id);
      if (group != null) next.addAll(group);
    }
    notifier.setScrapSelection(next);
  }

  /// Compute what the canvas origin would be from the current props and,
  /// if it differs from `_canvasOriginX/Y`, pre-translate the InteractiveViewer
  /// matrix by the same delta so cards don't visually jump when the next
  /// build adopts the new origin.
  ///
  /// Math: SizedBox-local px_new = absX - newOrigin = px_old - dOrigin.
  /// To keep `screen = px*z + tx` constant, tx_new = tx_old + dOrigin*z,
  /// which is exactly what `Matrix4.translate(dOrigin, ...)` does (since
  /// the existing matrix is `T(tx, ty) * S(z, z)` and right-multiplying
  /// by `T(dOrigin, ...)` adds `dOrigin*z` to tx).
  void _settleOriginAfterDrag() {
    double minL = 0, minT = 0;
    for (final p in _props.values) {
      if (p.absX < minL) minL = p.absX;
      if (p.absY < minT) minT = p.absY;
    }
    const negPad = 400.0;
    final newOriginX = minL < 0 ? minL - negPad : 0.0;
    final newOriginY = minT < 0 ? minT - negPad : 0.0;
    final dx = newOriginX - _canvasOriginX;
    final dy = newOriginY - _canvasOriginY;
    if (dx == 0 && dy == 0) return;
    final m = _transformCtrl.value.clone();
    m.translate(dx, dy);
    _transformCtrl.value = m;
    // _canvasOriginX/Y will be picked up by the next build's recompute
    // (since _draggingId is about to be cleared in the same frame).
  }

  /// Drag the dragged card and any cards that move with it (other selected
  /// cards + members of the dragged card's saved group).
  ///
  /// Cards may go to negative coords — InteractiveViewer's
  /// `boundaryMargin: infinity` lets the user pan anywhere, so the canvas
  /// has no left/top edge.
  void _onMultiCardDrag(ScrapElement el, Offset delta) {
    final notifier = ref.read(workspaceProviderProvider.notifier);
    final selected =
        ref.read(workspaceProviderProvider).valueOrNull?.selectedScrapIds ??
        const <String>{};
    final group = notifier.findGroupOf(el.id);
    final movableIds = <String>{el.id};
    if (selected.contains(el.id)) movableIds.addAll(selected);
    if (group != null) movableIds.addAll(group);
    setState(() {
      for (final id in movableIds) {
        final cp = _props[id];
        if (cp == null) continue;
        cp.absX += delta.dx;
        cp.absY += delta.dy;
      }
    });
  }

  /// After a drag ends, sort cards by visual position (Y then X) and push
  /// the new order back to markdown @el list. This keeps the left sidebar
  /// thumbnail order in sync with the canvas arrangement.
  void _syncOrderByPosition() {
    if (widget.noteId == null) return;
    final elements = ref.read(noteScrapProvider(widget.noteId!));
    // Scrap card types: capture, lasso, and highlight.
    // - capture/lasso → image card with PDF region
    // - highlight → text card with selected text
    // - drawing is excluded (lives on PDF)
    // Matches the original WorkspaceCanvasPanel behavior and PROJECT_DESIGN
    // section 11.1 (scrapnote = highlights + 필기 collected into one note).
    final cards = elements
        .where(
          (e) =>
              e.type == ElementType.capture ||
              e.type == ElementType.lasso ||
              e.type == ElementType.highlight,
        )
        .toList();
    final withProps = cards.where((e) => _props.containsKey(e.id)).toList();
    if (withProps.isEmpty) return;
    withProps.sort((a, b) {
      final pa = _props[a.id]!;
      final pb = _props[b.id]!;
      final yCmp = pa.absY.compareTo(pb.absY);
      if (yCmp != 0) return yCmp;
      return pa.absX.compareTo(pb.absX);
    });
    // No-op if already sorted
    bool changed = false;
    for (var i = 0; i < withProps.length && i < cards.length; i++) {
      if (withProps[i].id != cards[i].id) {
        changed = true;
        break;
      }
    }
    if (!changed) return;
    final orderedIds = withProps.map((e) => e.id).toList();
    ref
        .read(workspaceProviderProvider.notifier)
        .reorderAllScraps(widget.noteId!, orderedIds);
    widget.onOrderChanged?.call(orderedIds);
  }

  /// Aspect-locked corner resize.
  void _onResize(NotebookCardProps p, Offset delta, NotebookCorner c) {
    if (p.width <= 0 || p.height <= 0) return;
    final aspect = p.height / p.width;
    if (aspect <= 0) return;
    final sx = (c == NotebookCorner.tl || c == NotebookCorner.bl) ? -1.0 : 1.0;
    final sy = (c == NotebookCorner.tl || c == NotebookCorner.tr) ? -1.0 : 1.0;
    final diagLen = math.sqrt(1 + aspect * aspect);
    final projection = (delta.dx * sx + delta.dy * aspect * sy) / diagLen;
    // Wider clamp range so users can shrink cards down to thumbnails or
    // blow them up across the canvas if they want.
    final newW = (p.width + projection).clamp(40.0, 4000.0);
    final newH = (newW * aspect).clamp(
      NotebookConst.minHeight,
      NotebookConst.maxHeight,
    );
    final widthFromH = newH / aspect;
    final finalW = math.min(newW, widthFromH);
    final finalH = finalW * aspect;
    setState(() {
      // Anchor opposite corner: shift absX/absY so the corner-being-dragged
      // moves while the opposite corner stays.
      switch (c) {
        case NotebookCorner.br:
          // anchor top-left: position unchanged, size grows
          break;
        case NotebookCorner.bl:
          p.absX += p.width - finalW;
          break;
        case NotebookCorner.tr:
          p.absY += p.height - finalH;
          break;
        case NotebookCorner.tl:
          p.absX += p.width - finalW;
          p.absY += p.height - finalH;
          break;
      }
      p.width = finalW;
      p.height = finalH;
    });
  }

  void _onRotate(NotebookCardProps p, double deltaRad) {
    setState(() {
      p.rotation = (p.rotation + deltaRad) % (2 * math.pi);
    });
  }

  /// Aspect-locked corner resize for the whole group / multi-selection.
  ///
  /// Treats every selected card as part of one rigid figure: the diagonal
  /// projection of the drag determines a uniform scale factor, then each
  /// card's width/height/position is scaled around the corner opposite the
  /// dragged corner (the "anchor"), so the anchor-corner of the group bbox
  /// stays fixed while the dragged corner follows the user.
  void _onGroupResize(
    List<ScrapElement> allCards,
    Set<String> selectedIds,
    Offset delta,
    NotebookCorner c,
    double gx,
    double gy,
    double gw,
    double gh,
  ) {
    if (gw <= 0 || gh <= 0) return;
    final aspect = gh / gw;
    final sx = (c == NotebookCorner.tl || c == NotebookCorner.bl) ? -1.0 : 1.0;
    final sy = (c == NotebookCorner.tl || c == NotebookCorner.tr) ? -1.0 : 1.0;
    final diagLen = math.sqrt(1 + aspect * aspect);
    final projection = (delta.dx * sx + delta.dy * aspect * sy) / diagLen;
    final newW = (gw + projection).clamp(40.0, 8000.0);
    final scale = newW / gw;
    if (scale <= 0 || (scale - 1.0).abs() < 1e-6) return;

    // Anchor = the corner opposite the dragged one (stays put).
    double anchorX, anchorY;
    switch (c) {
      case NotebookCorner.br:
        anchorX = gx;
        anchorY = gy;
        break;
      case NotebookCorner.bl:
        anchorX = gx + gw;
        anchorY = gy;
        break;
      case NotebookCorner.tr:
        anchorX = gx;
        anchorY = gy + gh;
        break;
      case NotebookCorner.tl:
        anchorX = gx + gw;
        anchorY = gy + gh;
        break;
    }
    setState(() {
      for (final el in allCards) {
        if (!selectedIds.contains(el.id)) continue;
        final p = _props[el.id];
        if (p == null) continue;
        p.absX = anchorX + (p.absX - anchorX) * scale;
        p.absY = anchorY + (p.absY - anchorY) * scale;
        p.width = (p.width * scale).clamp(40.0, 4000.0);
        p.height = (p.height * scale).clamp(
          NotebookConst.minHeight,
          NotebookConst.maxHeight,
        );
      }
    });
  }

  /// Rotate every selected card around the group's center.
  ///
  /// Each card's center orbits the group center by [deltaRad]; each card's
  /// own rotation also advances by [deltaRad] so the visual orientation
  /// matches the orbit. (Card width/height are unchanged — the bounding
  /// box used to position handles is axis-aligned over unrotated bounds,
  /// so it doesn't track rotation; acceptable for v1.)
  void _onGroupRotate(
    List<ScrapElement> allCards,
    Set<String> selectedIds,
    double deltaRad,
    Offset center,
  ) {
    final cosD = math.cos(deltaRad);
    final sinD = math.sin(deltaRad);
    setState(() {
      for (final el in allCards) {
        if (!selectedIds.contains(el.id)) continue;
        final p = _props[el.id];
        if (p == null) continue;
        final cx = p.absX + p.width / 2;
        final cy = p.absY + p.height / 2;
        final dx = cx - center.dx;
        final dy = cy - center.dy;
        final newCx = center.dx + dx * cosD - dy * sinD;
        final newCy = center.dy + dx * sinD + dy * cosD;
        p.absX = newCx - p.width / 2;
        p.absY = newCy - p.height / 2;
        p.rotation = (p.rotation + deltaRad) % (2 * math.pi);
      }
    });
  }

  /// Open the per-scrap edit modal where the user can draw freehand
  /// strokes on top of a single scrap's content. Strokes are persisted
  /// per-element via [ScrapAnnotationStore] (Hive box `scrap_annotations`).
  void _openScrapEditModal(ScrapElement el) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent, // ScrapEditModal handles its own dim
      builder: (ctx) =>
          ScrapEditModal(element: el, onClose: () => Navigator.of(ctx).pop()),
    );
  }

  void _confirmDelete(ScrapElement el) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'P${el.pageNumber} #${el.id.substring(0, 6)}',
          style: const TextStyle(fontSize: 14),
        ),
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
                _props.remove(el.id);
                _persistCardProps();
                final notifier = ref.read(workspaceProviderProvider.notifier);
                notifier.removeScrapElement(widget.noteId!, el.id);
                final selected =
                    ref
                        .read(workspaceProviderProvider)
                        .valueOrNull
                        ?.selectedScrapIds ??
                    const <String>{};
                if (selected.contains(el.id)) {
                  final next = Set<String>.from(selected)..remove(el.id);
                  notifier.setScrapSelection(next);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final elements = widget.noteId != null
        ? ref.watch(noteScrapProvider(widget.noteId!))
        : <ScrapElement>[];
    final capturesDir = ref.watch(capturesDirectoryProvider).valueOrNull?.path;
    ref.watch(drawingModeProvider);
    // Watch the per-scrap annotation store so card stroke overlays
    // refresh whenever the user commits a stroke / undoes / clears
    // inside ScrapEditModal.
    ref.watch(scrapAnnotationStoreProvider);

    // Scrap card types: capture, lasso, and highlight.
    // - capture/lasso → image card with PDF region
    // - highlight → text card with selected text
    // - drawing is excluded (lives on PDF)
    // Matches the original WorkspaceCanvasPanel behavior and PROJECT_DESIGN
    // section 11.1 (scrapnote = highlights + 필기 collected into one note).
    final cards = elements
        .where(
          (e) =>
              e.type == ElementType.capture ||
              e.type == ElementType.lasso ||
              e.type == ElementType.highlight,
        )
        .toList();
    // (build log removed; was firing every frame and cluttering logcat)

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          CanvasHeader(
            totalCount: cards.length,
            onImportPressed: widget.noteId != null
                ? () => ScrapImportDialog.show(
                    context: context,
                    ref: ref,
                    currentNoteId: widget.noteId!,
                  )
                : null,
            onZoomIn: null,
            onZoomOut: null,
            onZoomReset: null,
            onSwapLayout: () =>
                ref.read(workspaceProviderProvider.notifier).swapLayout(),
            onFoldPanel: () =>
                ref.read(workspaceProviderProvider.notifier).toggleLiveScraps(),
          ),
          Expanded(
            child: ClipRect(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final panelW = constraints.maxWidth;
                  final selectedIds =
                      ref
                          .watch(workspaceProviderProvider)
                          .valueOrNull
                          ?.selectedScrapIds ??
                      const <String>{};
                  final multiSelected = selectedIds.length >= 2;
                  // Skip the prop-cleanup loop while a drag/resize is in
                  // flight. setState fires per pointer-move (50+ Hz) and
                  // ensure-props is a non-trivial loop over every card —
                  // letting it run during a drag turns smooth motion into
                  // a stutter on Galaxy Tab.
                  if (_draggingId == null) {
                    final added = _ensurePropsFor(cards, panelW);
                    if (added.isNotEmpty) {
                      debugPrint(
                        '[NotebookScrapPanel] new cards: ${added.length} ids=$added',
                      );
                      _pendingScrollTo = added.last;
                      Future.microtask(_persistCardProps);
                    }
                    if (_pendingScrollTo != null) {
                      final id = _pendingScrollTo!;
                      _pendingScrollTo = null;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) scrollToElement(id);
                      });
                    }
                  }

                  // Canvas content size — driven by card bounding box.
                  // Includes negative-coord cards so the Stack rect stays
                  // a hittable container around every card. Without this,
                  // cards dragged into negative absX/absY render via
                  // clipBehavior.none but become unselectable (Stack
                  // hit-test rejects positions outside its size).
                  double maxBottom = constraints.maxHeight;
                  double maxRight = panelW;
                  double minLeft = 0;
                  double minTop = 0;
                  for (final p in _props.values) {
                    final bot = p.absY + p.height;
                    final rgt = p.absX + p.width;
                    if (bot > maxBottom) maxBottom = bot;
                    if (rgt > maxRight) maxRight = rgt;
                    if (p.absX < minLeft) minLeft = p.absX;
                    if (p.absY < minTop) minTop = p.absY;
                  }
                  // Origin shifts negative only when a card has gone
                  // left/up of zero — extra 400px pad on the negative
                  // side gives room to keep dragging further. With no
                  // negative cards origin stays at 0 so the Stack rect
                  // hugs the natural canvas.
                  //
                  // Frozen during an active drag: the origin is recomputed
                  // each build, and if it shifted while the user is mid-
                  // drag the card's stack-local position would jump
                  // discontinuously (looks like the card "disappears" off
                  // to the side). On drag-end we settle the origin and
                  // compensate the InteractiveViewer transform in one
                  // step so the visual position stays put.
                  const negPad = 400.0;
                  if (_draggingId == null) {
                    _canvasOriginX = minLeft < 0 ? minLeft - negPad : 0.0;
                    _canvasOriginY = minTop < 0 ? minTop - negPad : 0.0;
                  }
                  final canvasW = math.max(
                    panelW,
                    maxRight - _canvasOriginX + 200.0,
                  );
                  final canvasH =
                      maxBottom - _canvasOriginY + NotebookConst.footerSpace;

                  // Drawing input layer (only intercepts when annotateMode):
                  //   Transparent layer over the canvas catching pointer
                  //   events for stroke recording.
                  final drawingOverlay = _annotateMode
                      ? Positioned.fill(
                          child: Listener(
                            onPointerDown: _onPointerDown,
                            onPointerMove: _onPointerMove,
                            onPointerUp: _onPointerUp,
                            onPointerCancel: _onPointerCancel,
                            behavior: HitTestBehavior.opaque,
                            child: const SizedBox.shrink(),
                          ),
                        )
                      : null;

                  return Stack(
                    children: [
                      // Panel-level ruled paper background. Fills the
                      // entire panel regardless of zoom/scroll, so when
                      // the user zooms out the lines still cover the
                      // viewport (effectively "infinite paper").
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: true,
                          child: CustomPaint(painter: NotebookBgPainter()),
                        ),
                      ),
                      if (cards.isEmpty)
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: Text(
                                'PDF에서 스크랩한 내용을 이곳에서 정리하세요',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.sokDisabled,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Single InteractiveViewer handles pan + pinch zoom
                      // for the entire canvas. Cards inside use plain
                      // GestureDetector and win the gesture arena over
                      // InteractiveViewer's pan when touched directly.
                      InteractiveViewer(
                        transformationController: _transformCtrl,
                        constrained: false,
                        minScale: _zoomMin,
                        maxScale: _zoomMax,
                        panEnabled: !_annotateMode && _draggingId == null,
                        scaleEnabled: !_annotateMode,
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        // Default Clip.hardEdge clips its child SizedBox.
                        // During a card drag the card's stack-local left
                        // can go negative (origin frozen, card moving
                        // outside the SizedBox bounds), which would clip
                        // it out and look like the card disappeared. The
                        // outer panel ClipRect still contains overflow.
                        clipBehavior: Clip.none,
                        child: SizedBox(
                          width: canvasW,
                          height: canvasH,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Empty area tap → deselect all.
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    final n = ref.read(
                                      workspaceProviderProvider.notifier,
                                    );
                                    n.clearScrapSelection();
                                  },
                                ),
                              ),
                              // Strokes — under cards, in canvas coords.
                              Positioned.fill(
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: CustomPaint(
                                    painter: NotebookStrokePainter(
                                      strokes: _strokes,
                                      originX: _canvasOriginX,
                                      originY: _canvasOriginY,
                                      liveStroke: _liveStrokePoints.length >= 2
                                          ? DrawingStroke(
                                              id: 'live',
                                              pageNumber: 0,
                                              toolId: _toolId,
                                              colorValue: _toolId == 'eraser'
                                                  ? 0x40FF0000
                                                  : _strokeColor,
                                              size: _toolId == 'eraser'
                                                  ? _strokeSize * 2
                                                  : _strokeSize,
                                              points: _liveStrokePoints
                                                  .map(
                                                    (p) => StrokePoint(
                                                      x: p.dx,
                                                      y: p.dy,
                                                    ),
                                                  )
                                                  .toList(),
                                            )
                                          : null,
                                    ),
                                    size: Size.infinite,
                                  ),
                                ),
                              ),
                              for (final el in cards)
                                _buildCard(el, capturesDir),
                              if (multiSelected)
                                ..._buildGroupHandles(cards, selectedIds),
                            ],
                          ),
                        ),
                      ),
                      if (drawingOverlay != null) drawingOverlay,
                      // Multi-select action bar — only when 2+ cards selected.
                      if (multiSelected)
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _SelectionActionBar(
                              count: selectedIds.length,
                              isGrouped: ref
                                  .read(workspaceProviderProvider.notifier)
                                  .isSelectionGrouped(),
                              onGroup: () {
                                ref
                                    .read(workspaceProviderProvider.notifier)
                                    .groupSelectedScraps();
                              },
                              onUngroup: () {
                                ref
                                    .read(workspaceProviderProvider.notifier)
                                    .ungroupScraps(selectedIds);
                              },
                              onDeselect: () {
                                ref
                                    .read(workspaceProviderProvider.notifier)
                                    .clearScrapSelection();
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(ScrapElement el, String? capturesDir) {
    final p = _props[el.id];
    if (p == null) return const SizedBox.shrink();
    final ws = ref.watch(workspaceProviderProvider).valueOrNull;
    final selectedIds = ws?.selectedScrapIds ?? const <String>{};
    final isSelected = selectedIds.contains(el.id);
    // Single-card selection (1 card) → show resize/rotation/delete handles.
    // Multi-card selection (2+) → just highlight; group ops on header.
    final isLoneSelection = isSelected && selectedIds.length == 1;

    // Slot Stack has handle margin around card; corner handles + rotation
    // handle (with stem above) all live within these bounds (hittable).
    const m = 10.0; // handle margin around card
    const topExtra = NotebookConst.rotationStem;
    final stackW = p.width + 2 * m;
    final stackH = p.height + 2 * m + topExtra;
    // Subtract canvas origin: cards live in absX/absY canvas coords (which
    // can be negative); the Stack origin shifts to encompass them, so we
    // translate by -origin when positioning inside the Stack.
    final stackLeft = p.absX - _canvasOriginX - m;
    final stackTop = p.absY - _canvasOriginY - m - topExtra;

    const cardLeft = m;
    const cardTop = m + topExtra;

    return Positioned(
      left: stackLeft,
      top: stackTop,
      width: stackW,
      height: stackH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card body — drag to move (immediate pan), tap to select.
          // Wrapped in a Listener that records down/up positions so we can
          // synthesize a tap for stylus events that Flutter's gesture arena
          // sometimes drops (Galaxy S Pen → 2 pointerDown events → tap
          // recognizer never fires onTapUp).
          Positioned(
            left: cardLeft,
            top: cardTop,
            width: p.width,
            height: p.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _annotateMode ? null : () => _onCardTap(el),
              onPanStart: _annotateMode
                  ? null
                  : (_) {
                      setState(() => _draggingId = el.id);
                    },
              onPanUpdate: _annotateMode
                  ? null
                  : (d) {
                      if (_draggingId != el.id) return;
                      // If this card is part of the active selection or a
                      // saved group, drag every grouped/selected card by
                      // the same delta so they move as one.
                      _onMultiCardDrag(el, d.delta);
                    },
              onPanEnd: _annotateMode
                  ? null
                  : (_) {
                      if (_draggingId != el.id) return;
                      // Settle origin BEFORE clearing _draggingId so the
                      // transform is compensated in the same frame the
                      // origin shifts — otherwise the next build runs the
                      // origin recompute (now unfrozen) and the card
                      // visually snaps to its new stack-local position.
                      _settleOriginAfterDrag();
                      setState(() => _draggingId = null);
                      _persistCardProps();
                      _syncOrderByPosition();
                    },
              onPanCancel: _annotateMode
                  ? null
                  : () {
                      if (_draggingId == el.id) {
                        setState(() => _draggingId = null);
                      }
                    },
              child: Transform.rotate(
                angle: p.rotation,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CanvasScrapCard(element: el, capturesDir: capturesDir),
                    // Per-scrap annotations (drawn in ScrapEditModal,
                    // rendered here scaled to the card size). The main
                    // build() above watches scrapAnnotationStoreProvider
                    // so any addStroke/clear inside the modal triggers
                    // a rebuild and these strokes refresh.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: ScrapStrokeOverlayPainter(
                            strokes: ref
                                .read(scrapAnnotationStoreProvider.notifier)
                                .getStrokes(el.id),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Selection border
          if (isSelected)
            Positioned(
              left: cardLeft,
              top: cardTop,
              width: p.width,
              height: p.height,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.10),
                    // Border scales with zoom (it's inside Transform.scale),
                    // so make it thick enough that even at min zoom (0.4x)
                    // it's still ~2px on screen.
                    border: Border.all(color: Colors.blue.shade600, width: 4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          // Selection handles — only on a single-card selection. Multi-select
          // shows just the highlight; group/ungroup happens via header.
          if (isLoneSelection && !_annotateMode) ...[
            _cornerHandle(
              centerX: cardLeft,
              centerY: cardTop,
              c: NotebookCorner.tl,
              p: p,
            ),
            _cornerHandle(
              centerX: cardLeft + p.width,
              centerY: cardTop,
              c: NotebookCorner.tr,
              p: p,
            ),
            _cornerHandle(
              centerX: cardLeft,
              centerY: cardTop + p.height,
              c: NotebookCorner.bl,
              p: p,
            ),
            _cornerHandle(
              centerX: cardLeft + p.width,
              centerY: cardTop + p.height,
              c: NotebookCorner.br,
              p: p,
            ),
            // Rotation stem
            Positioned(
              left: cardLeft + p.width / 2 - 0.5,
              top: cardTop - topExtra + 4,
              width: 1,
              height: topExtra - 4,
              child: IgnorePointer(
                child: Container(color: Colors.green.shade500),
              ),
            ),
            // Rotation handle (44px hit area around the small green dot
            // so it's grabbable even at low zoom)
            Positioned(
              left: cardLeft + p.width / 2 - 22,
              top: -8,
              width: 44,
              height: 44,
              child: NotebookRotationHandle(
                onRotate: (d) => _onRotate(p, d),
                onEnd: _persistCardProps,
              ),
            ),
            // Delete (top-right slightly outside corner)
            Positioned(
              left: cardLeft + p.width - NotebookConst.iconButtonSize / 2,
              top: cardTop - NotebookConst.iconButtonSize / 2,
              child: NotebookIconButton(
                icon: Icons.close,
                bg: Colors.red.shade500,
                onTap: () => _confirmDelete(el),
              ),
            ),
            // Page jump (top-left slightly outside corner)
            if (el.pageNumber > 0)
              Positioned(
                left: cardLeft - NotebookConst.iconButtonSize / 2,
                top: cardTop - NotebookConst.iconButtonSize / 2,
                child: NotebookIconButton(
                  icon: Icons.open_in_new,
                  bg: Colors.blue.shade500,
                  onTap: () => widget.onNavigateToPage(el.pageNumber),
                ),
              ),
            // Edit (bottom-right slightly outside corner) — opens the
            // ScrapEditModal so the user can scribble notes/marks on top
            // of this single scrap, persisted via ScrapAnnotationStore.
            Positioned(
              left: cardLeft + p.width - NotebookConst.iconButtonSize / 2,
              top: cardTop + p.height - NotebookConst.iconButtonSize / 2,
              child: NotebookIconButton(
                icon: Icons.edit_outlined,
                bg: Colors.purple.shade500,
                onTap: () => _openScrapEditModal(el),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Reserved for future long-press features (e.g. context menu, multi-select).
  /// Currently the primary card move uses onPan (immediate drag); long-press
  /// stubs are kept so behavior can be extended without re-plumbing callbacks.
  // ignore: unused_field
  final Map<String, Offset> _lastLongPressOffset = {};

  /// Build the bounding-box overlay (border + corner handles + rotation
  /// handle) for a multi-card / group selection. Returns a list of
  /// `Positioned` widgets to be spread directly into the canvas Stack.
  ///
  /// The bbox is axis-aligned over each card's unrotated rect (absX/absY/
  /// width/height); after rotation the bbox no longer hugs the visual
  /// shape — acceptable for v1, simpler than tracking rotated bounds.
  List<Widget> _buildGroupHandles(
    List<ScrapElement> allCards,
    Set<String> selectedIds,
  ) {
    double minL = double.infinity, minT = double.infinity;
    double maxR = double.negativeInfinity, maxB = double.negativeInfinity;
    int count = 0;
    for (final el in allCards) {
      if (!selectedIds.contains(el.id)) continue;
      final p = _props[el.id];
      if (p == null) continue;
      if (p.absX < minL) minL = p.absX;
      if (p.absY < minT) minT = p.absY;
      if (p.absX + p.width > maxR) maxR = p.absX + p.width;
      if (p.absY + p.height > maxB) maxB = p.absY + p.height;
      count++;
    }
    if (count < 2 || !minL.isFinite) return const [];

    final gx = minL;
    final gy = minT;
    final gw = maxR - minL;
    final gh = maxB - minT;
    final boxLeft = gx - _canvasOriginX;
    final boxTop = gy - _canvasOriginY;
    final groupCenter = Offset(gx + gw / 2, gy + gh / 2);

    const hit = 32.0;
    Widget cornerHandle(double x, double y, NotebookCorner c) => Positioned(
      left: x - hit / 2,
      top: y - hit / 2,
      width: hit,
      height: hit,
      child: NotebookCornerHandle(
        onDrag: (delta) =>
            _onGroupResize(allCards, selectedIds, delta, c, gx, gy, gw, gh),
        onEnd: _persistCardProps,
      ),
    );

    return [
      // Bounding box outline (purple to distinguish from per-card blue).
      Positioned(
        left: boxLeft,
        top: boxTop,
        width: gw,
        height: gh,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.05),
              border: Border.all(color: Colors.deepPurple.shade400, width: 2),
            ),
          ),
        ),
      ),
      // 4 corner handles for aspect-locked group resize.
      cornerHandle(boxLeft, boxTop, NotebookCorner.tl),
      cornerHandle(boxLeft + gw, boxTop, NotebookCorner.tr),
      cornerHandle(boxLeft, boxTop + gh, NotebookCorner.bl),
      cornerHandle(boxLeft + gw, boxTop + gh, NotebookCorner.br),
      // Rotation stem (visual line above the bbox top).
      Positioned(
        left: boxLeft + gw / 2 - 0.5,
        top: boxTop - NotebookConst.rotationStem + 4,
        width: 1,
        height: NotebookConst.rotationStem - 8,
        child: IgnorePointer(child: Container(color: Colors.green.shade500)),
      ),
      // Rotation handle (44px hit area centered on the green dot above bbox).
      Positioned(
        left: boxLeft + gw / 2 - 22,
        top: boxTop - NotebookConst.rotationStem - 22,
        width: 44,
        height: 44,
        child: NotebookRotationHandle(
          onRotate: (d) =>
              _onGroupRotate(allCards, selectedIds, d, groupCenter),
          onEnd: _persistCardProps,
        ),
      ),
    ];
  }

  Widget _cornerHandle({
    required double centerX,
    required double centerY,
    required NotebookCorner c,
    required NotebookCardProps p,
  }) {
    // 32px hit target: bigger than the 14px visible dot for finger/pen
    // accessibility, but small enough that it doesn't intrude far into
    // the card body and steal "move card" gestures.
    const hit = 32.0;
    return Positioned(
      left: centerX - hit / 2,
      top: centerY - hit / 2,
      width: hit,
      height: hit,
      child: NotebookCornerHandle(
        onDrag: (delta) => _onResize(p, delta, c),
        onEnd: _persistCardProps,
      ),
    );
  }
}

/// Floating action bar shown when 2+ cards are selected. Lets the user
/// turn the selection into a saved group (so they always move together)
/// or break an existing group apart.
class _SelectionActionBar extends StatelessWidget {
  const _SelectionActionBar({
    required this.count,
    required this.isGrouped,
    required this.onGroup,
    required this.onUngroup,
    required this.onDeselect,
  });

  final int count;
  final bool isGrouped;
  final VoidCallback onGroup;
  final VoidCallback onUngroup;
  final VoidCallback onDeselect;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '$count selected',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (!isGrouped)
              _BarButton(
                icon: Icons.link,
                label: 'Group',
                color: Colors.blue.shade600,
                onTap: onGroup,
              ),
            if (isGrouped)
              _BarButton(
                icon: Icons.link_off,
                label: 'Ungroup',
                color: Colors.orange.shade700,
                onTap: onUngroup,
              ),
            _BarButton(
              icon: Icons.close,
              label: 'Deselect',
              color: Colors.grey.shade600,
              onTap: onDeselect,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
