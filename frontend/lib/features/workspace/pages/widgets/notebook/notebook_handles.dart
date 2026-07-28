import 'package:flutter/material.dart';

import 'notebook_card_props.dart';

/// Round icon button used for card-level controls (X delete, page jump).
class NotebookIconButton extends StatelessWidget {
  const NotebookIconButton({
    super.key,
    required this.icon,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: NotebookConst.iconButtonSize,
        height: NotebookConst.iconButtonSize,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}

/// Top-center rotation handle (green dot at the end of a stem above the card).
///
/// Reports incremental rotation in radians via [onRotate]. The current
/// implementation maps horizontal drag (`dx`) to rotation: positive dx →
/// clockwise rotation. Vertical motion is ignored. Multiplier `0.01` rad/px
/// gives ~57° rotation per 100px drag.
class NotebookRotationHandle extends StatefulWidget {
  const NotebookRotationHandle({
    super.key,
    required this.onRotate,
    required this.onEnd,
  });

  final void Function(double deltaRad) onRotate;
  final VoidCallback onEnd;

  @override
  State<NotebookRotationHandle> createState() => _NotebookRotationHandleState();
}

class _NotebookRotationHandleState extends State<NotebookRotationHandle> {
  Offset? _last;

  void _onStart(DragStartDetails d) {
    _last = d.globalPosition;
  }

  void _onUpdate(DragUpdateDetails d) {
    final last = _last;
    if (last == null) return;
    final cur = d.globalPosition;
    final dx = cur.dx - last.dx;
    widget.onRotate(dx * 0.01);
    _last = cur;
  }

  void _onEnd(DragEndDetails d) {
    _last = null;
    widget.onEnd();
  }

  @override
  Widget build(BuildContext context) {
    // Visible green dot is small (rotationHandleSize) but the GestureDetector
    // fills the larger Positioned slot the parent gives it (~44px), keeping
    // the handle grabbable at low zoom.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onStart,
      onPanUpdate: _onUpdate,
      onPanEnd: _onEnd,
      child: Center(
        child: Container(
          width: NotebookConst.rotationHandleSize,
          height: NotebookConst.rotationHandleSize,
          decoration: BoxDecoration(
            color: Colors.green.shade500,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Icon(Icons.rotate_right, size: 12, color: Colors.white),
        ),
      ),
    );
  }
}

/// Tiny round corner handle (white fill, blue border) for card resize.
///
/// Drag updates report incremental [Offset] deltas; the panel translates
/// these into width/height/position changes (with aspect-locked geometry
/// per [NotebookCorner]).
class NotebookCornerHandle extends StatelessWidget {
  const NotebookCornerHandle({
    super.key,
    required this.onDrag,
    required this.onEnd,
  });

  final void Function(Offset delta) onDrag;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    // Larger hit area than the visible dot so the pen can grab the handle
    // even at low zoom. The visible dot stays small (draw.io style) while
    // the touch target expands invisibly around it.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => onDrag(d.delta),
      onPanEnd: (_) => onEnd(),
      child: Center(
        child: Container(
          width: NotebookConst.cornerHandleSize,
          height: NotebookConst.cornerHandleSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.shade600, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
