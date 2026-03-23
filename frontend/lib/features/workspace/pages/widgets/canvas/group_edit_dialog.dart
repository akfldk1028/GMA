import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../scrapnote/models/element_model.dart';

/// Stores card layout state from group edit modal.
class GroupCardState {
  final Rect layout;
  final double rotation;
  GroupCardState({required this.layout, this.rotation = 0.0});
}

/// Full-screen canvas board for editing a group of scraps.
/// Cards are freely positioned, and users can draw/write on the canvas.
class GroupEditDialog extends StatefulWidget {
  const GroupEditDialog({
    super.key,
    required this.elements,
    required this.onConfirm,
    this.capturesDir,
  });

  final List<ScrapElement> elements;
  final String? capturesDir;
  /// Called with element ID → (Rect layout, double rotation) map
  final void Function(Map<String, GroupCardState> cardStates) onConfirm;

  @override
  State<GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends State<GroupEditDialog> {
  // Card layout
  final Map<int, Rect> _cardLayout = {};
  // Drawing strokes
  final List<_Stroke> _strokes = [];
  List<Offset> _currentPoints = [];
  // Text notes added on canvas
  final List<_CanvasNote> _notes = [];
  // Mode
  bool _isDrawing = false;
  int _penColor = 0xFF1565C0;
  double _penSize = 2.0;
  // Selection & transform
  int? _selectedCard;
  final Map<int, double> _cardRotations = {};
  bool _isResizing = false;

  final TransformationController _transformCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    _initLayout();
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _initLayout() {
    const cardW = 280.0;
    const cardH = 160.0;
    const spacing = 24.0;
    double y = 20;
    for (var i = 0; i < widget.elements.length; i++) {
      _cardLayout[i] = Rect.fromLTWH(20, y, cardW, cardH);
      y += cardH + spacing;
    }
  }

  String? _resolveImage(ScrapElement el) {
    final img = el.imagePath;
    if (img == null || img.isEmpty) return null;
    if (p.isAbsolute(img) && File(img).existsSync()) return img;
    if (widget.capturesDir != null) {
      final resolved = p.join(widget.capturesDir!, img);
      if (File(resolved).existsSync()) return resolved;
    }
    return null;
  }

  void _addTextNote(Offset position) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('메모 추가', style: TextStyle(fontSize: 14)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '내용 입력...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _notes.add(_CanvasNote(
                    position: position,
                    text: controller.text,
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
    controller.dispose;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // ─── Header ───
            _buildHeader(),
            // ─── Toolbar ───
            _buildToolbar(),
            // ─── Canvas ───
            Expanded(child: _buildCanvas()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.layers, size: 16, color: Colors.blue.shade500),
          const SizedBox(width: 8),
          Text(
            'Group (${widget.elements.length})',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // Collect all card states and pass back
              final states = <String, GroupCardState>{};
              for (var i = 0; i < widget.elements.length; i++) {
                states[widget.elements[i].id] = GroupCardState(
                  layout: _cardLayout[i]!,
                  rotation: _cardRotations[i] ?? 0.0,
                );
              }
              widget.onConfirm(states);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('확인',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    const colors = [0xFF000000, 0xFF1565C0, 0xFFD32F2F, 0xFF2E7D32, 0xFFE65100];
    const sizes = [1.0, 2.0, 4.0];

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Draw mode toggle
          GestureDetector(
            onTap: () => setState(() => _isDrawing = !_isDrawing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isDrawing ? Colors.blue.shade50 : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.edit, size: 16,
                  color: _isDrawing ? Colors.blue.shade700 : Colors.grey.shade500),
            ),
          ),
          const SizedBox(width: 8),
          // Colors
          for (final c in colors)
            GestureDetector(
              onTap: () => setState(() {
                _penColor = c;
                _isDrawing = true;
              }),
              child: Container(
                width: 16, height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Color(c),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _penColor == c ? Colors.blue : Colors.grey.shade300,
                    width: _penColor == c ? 2 : 1,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          // Sizes
          for (final s in sizes)
            GestureDetector(
              onTap: () => setState(() {
                _penSize = s;
                _isDrawing = true;
              }),
              child: Container(
                width: 20, height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _penSize == s ? Colors.grey.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Container(
                  width: s + 2, height: s + 2,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          const Spacer(),
          // Add text note
          GestureDetector(
            onTap: () => _addTextNote(const Offset(320, 100)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_add, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('메모', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Undo
          GestureDetector(
            onTap: () {
              if (_strokes.isNotEmpty) {
                setState(() => _strokes.removeLast());
              }
            },
            child: Icon(Icons.undo, size: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelW = constraints.maxWidth;
        final panelH = constraints.maxHeight;
        final maxBottom = _cardLayout.values.fold(
            panelH, (v, r) => max(v, r.bottom + 200));
        final maxRight = _cardLayout.values.fold(
            panelW, (v, r) => max(v, r.right + 200));

        final canvasContent = SizedBox(
          width: max(panelW, maxRight),
          height: max(panelH, maxBottom),
          child: Stack(
            children: [
              // Background grid
              Positioned.fill(
                child: CustomPaint(painter: _GridPainter()),
              ),
              // Deselect on background tap
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => setState(() => _selectedCard = null),
                ),
              ),
              // Scrap cards
              for (var i = 0; i < widget.elements.length; i++)
                _buildCard(i),
              // Selection handles
              if (_selectedCard != null && !_isDrawing)
                ..._buildSelectionHandles(_selectedCard!),
              // Text notes
              for (var i = 0; i < _notes.length; i++)
                _buildNote(i),
              // Drawing strokes
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _StrokePainter(
                      strokes: _strokes,
                      currentPoints: _currentPoints,
                      penColor: _penColor,
                      penSize: _penSize,
                    ),
                  ),
                ),
              ),
              // Drawing input layer
              if (_isDrawing)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (d) => setState(() =>
                        _currentPoints = [d.localPosition]),
                    onPanUpdate: (d) => setState(() =>
                        _currentPoints = [..._currentPoints, d.localPosition]),
                    onPanEnd: (_) {
                      if (_currentPoints.length >= 2) {
                        _strokes.add(_Stroke(
                          points: List.from(_currentPoints),
                          color: _penColor,
                          size: _penSize,
                        ));
                      }
                      setState(() => _currentPoints = []);
                    },
                  ),
                ),
            ],
          ),
        );

        if (_isDrawing) {
          return ClipRect(child: canvasContent);
        }

        return InteractiveViewer(
          transformationController: _transformCtrl,
          constrained: false,
          boundaryMargin: EdgeInsets.zero,
          minScale: 0.5,
          maxScale: 2.0,
          child: canvasContent,
        );
      },
    );
  }

  Widget _buildCard(int index) {
    final el = widget.elements[index];
    final rect = _cardLayout[index]!;
    final imgPath = _resolveImage(el);
    final isHighlight = el.type == ElementType.highlight;
    final isSelected = _selectedCard == index;
    final rotation = _cardRotations[index] ?? 0.0;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
        onTap: _isDrawing
            ? null
            : () => setState(() => _selectedCard = index),
        onPanUpdate: (_isDrawing || _isResizing)
            ? null
            : (d) {
                setState(() {
                  _selectedCard = index;
                  final old = _cardLayout[index]!;
                  _cardLayout[index] = Rect.fromLTWH(
                    old.left + d.delta.dx,
                    old.top + d.delta.dy,
                    old.width,
                    old.height,
                  );
                });
              },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
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
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? Colors.purple.shade50
                        : Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isHighlight ? Icons.highlight_rounded : Icons.crop,
                        size: 12,
                        color: isHighlight
                            ? Colors.purple.shade400
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text('P${el.pageNumber}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: imgPath != null
                      ? Image.file(File(imgPath),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              _textContent(el.selectedText))
                      : _textContent(el.selectedText),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  // ─── Selection handles for individual cards ───

  List<Widget> _buildSelectionHandles(int index) {
    final rect = _cardLayout[index]!;
    const hs = 10.0; // handle size

    Widget handle(double left, double top, MouseCursor cursor,
        void Function(DragUpdateDetails) onDrag) {
      return Positioned(
        left: left - hs / 2,
        top: top - hs / 2,
        child: MouseRegion(
          cursor: cursor,
          child: GestureDetector(
            onPanStart: (_) => _isResizing = true,
            onPanUpdate: (d) {
              _isResizing = true;
              onDrag(d);
            },
            onPanEnd: (_) => _isResizing = false,
            child: Container(
              width: hs + 6, height: hs + 6,
              alignment: Alignment.center,
              child: Container(
                width: hs, height: hs,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade400, width: 2),
                ),
              ),
            ),
          ),
        ),
      );
    }

    void resize(int idx, double dl, double dt, double dw, double dh) {
      setState(() {
        final old = _cardLayout[idx]!;
        _cardLayout[idx] = Rect.fromLTWH(
          old.left + dl, old.top + dt,
          (old.width + dw).clamp(100.0, 600.0),
          (old.height + dh).clamp(80.0, 500.0),
        );
      });
    }

    return [
      // Blue border
      Positioned(
        left: rect.left - 2, top: rect.top - 2,
        width: rect.width + 4, height: rect.height + 4,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade400, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
      // 4 corner handles
      handle(rect.left, rect.top, SystemMouseCursors.resizeUpLeft,
          (d) => resize(index, d.delta.dx, d.delta.dy, -d.delta.dx, -d.delta.dy)),
      handle(rect.right, rect.top, SystemMouseCursors.resizeUpRight,
          (d) => resize(index, 0, d.delta.dy, d.delta.dx, -d.delta.dy)),
      handle(rect.left, rect.bottom, SystemMouseCursors.resizeDownLeft,
          (d) => resize(index, d.delta.dx, 0, -d.delta.dx, d.delta.dy)),
      handle(rect.right, rect.bottom, SystemMouseCursors.resizeDownRight,
          (d) => resize(index, 0, 0, d.delta.dx, d.delta.dy)),
      // Bottom center
      handle(rect.center.dx, rect.bottom, SystemMouseCursors.resizeDown,
          (d) => resize(index, 0, 0, 0, d.delta.dy)),
      // Rotation handle (top center, above card)
      Positioned(
        left: rect.center.dx - 12,
        top: rect.top - 34,
        width: 24,
        height: 34,
        child: Column(
          children: [
            GestureDetector(
              onPanUpdate: (d) {
                setState(() {
                  _cardRotations[index] =
                      (_cardRotations[index] ?? 0.0) + d.delta.dx * 0.01;
                });
              },
              child: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Container(width: 1, height: 18, color: Colors.green.shade400),
          ],
        ),
      ),
    ];
  }

  Widget _textContent(String? text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text ?? '',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.4),
        overflow: TextOverflow.fade,
      ),
    );
  }

  Widget _buildNote(int index) {
    final note = _notes[index];
    return Positioned(
      left: note.position.dx,
      top: note.position.dy,
      child: GestureDetector(
        onPanUpdate: _isDrawing
            ? null
            : (d) {
                setState(() {
                  _notes[index] = _CanvasNote(
                    position: note.position + d.delta,
                    text: note.text,
                  );
                });
              },
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.yellow.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            note.text,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
          ),
        ),
      ),
    );
  }
}

// ─── Internal models ─────────────────────────────

class _CanvasNote {
  final Offset position;
  final String text;
  _CanvasNote({required this.position, required this.text});
}

class _Stroke {
  final List<Offset> points;
  final int color;
  final double size;
  _Stroke({required this.points, required this.color, required this.size});
}

// ─── Painters ─────────────────────────────────────

class _GridPainter extends CustomPainter {
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
    final dotPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (double x = 24; x < size.width; x += 24) {
      for (double y = 24; y < min(size.height, 800); y += 24) {
        canvas.drawPoints(ui.PointMode.points, [Offset(x, y)], dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({
    required this.strokes,
    required this.currentPoints,
    required this.penColor,
    required this.penSize,
  });

  final List<_Stroke> strokes;
  final List<Offset> currentPoints;
  final int penColor;
  final double penSize;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      _draw(canvas, s.points, s.color, s.size);
    }
    if (currentPoints.length >= 2) {
      _draw(canvas, currentPoints, penColor, penSize);
    }
  }

  void _draw(Canvas canvas, List<Offset> pts, int color, double sz) {
    if (pts.length < 2) return;
    final paint = Paint()
      ..color = Color(color)
      ..strokeWidth = sz
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) => true;
}
