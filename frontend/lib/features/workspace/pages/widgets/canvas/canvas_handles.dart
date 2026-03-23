import 'package:flutter/material.dart';

enum HandlePos { topLeft, topRight, bottomLeft, bottomRight, topCenter, bottomCenter }

/// Builds a single resize handle at the given corner/edge of a card.
///
/// [onResize] is called with (elementId, HandlePos, delta) to update layout.
Widget buildHandle({
  required String elId,
  required HandlePos pos,
  required void Function(String elId, HandlePos pos, Offset delta) onResize,
}) {
  const handleSize = 10.0;
  const hitSize = 20.0;

  double? left, right, top, bottom;
  MouseCursor cursor;

  switch (pos) {
    case HandlePos.topLeft:
      left = -handleSize / 2;
      top = -handleSize / 2;
      cursor = SystemMouseCursors.resizeUpLeft;
    case HandlePos.topRight:
      right = -handleSize / 2;
      top = -handleSize / 2;
      cursor = SystemMouseCursors.resizeUpRight;
    case HandlePos.bottomLeft:
      left = -handleSize / 2;
      bottom = -handleSize / 2;
      cursor = SystemMouseCursors.resizeDownLeft;
    case HandlePos.bottomRight:
      right = -handleSize / 2;
      bottom = -handleSize / 2;
      cursor = SystemMouseCursors.resizeDownRight;
    case HandlePos.topCenter:
      left = 0;
      right = 0;
      top = -handleSize / 2;
      cursor = SystemMouseCursors.resizeUp;
    case HandlePos.bottomCenter:
      left = 0;
      right = 0;
      bottom = -handleSize / 2;
      cursor = SystemMouseCursors.resizeDown;
  }

  return Positioned(
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    child: (left != null && right != null)
        ? Center(child: _handleDot(elId, pos, handleSize, hitSize, cursor, onResize))
        : _handleDot(elId, pos, handleSize, hitSize, cursor, onResize),
  );
}

Widget _handleDot(
  String elId,
  HandlePos pos,
  double handleSize,
  double hitSize,
  MouseCursor cursor,
  void Function(String elId, HandlePos pos, Offset delta) onResize,
) {
  return MouseRegion(
    cursor: cursor,
    child: GestureDetector(
      onPanUpdate: (details) {
        onResize(elId, pos, details.delta);
      },
      child: Container(
        width: hitSize,
        height: hitSize,
        alignment: Alignment.center,
        child: Container(
          width: handleSize,
          height: handleSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.shade400, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Builds a rotation handle positioned at ([cx], [handleTop]).
///
/// [onRotate] is called with horizontal delta to rotate.
/// [onRotateStart] / [onRotateEnd] bracket the gesture.
Widget buildRotationHandleAt({
  required double cx,
  required double handleTop,
  required VoidCallback onRotateStart,
  required void Function(double deltaX) onRotate,
  required VoidCallback onRotateEnd,
}) {
  return Positioned(
    left: cx - 12,
    top: handleTop,
    width: 24,
    height: 34,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onPanStart: (_) => onRotateStart(),
            onPanUpdate: (details) => onRotate(details.delta.dx * 0.01),
            onPanEnd: (_) => onRotateEnd(),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 1,
          height: 18,
          color: Colors.green.shade400,
        ),
      ],
    ),
  );
}

/// Builds group bounding-box outline + corner dots + action buttons for multi-select.
///
/// [bounds] is the bounding rect of all selected cards.
/// [isGrouped] indicates whether current selection is already grouped.
/// [onGroup], [onUngroup], [onDelete], [onEdit] are action callbacks.
List<Widget> buildGroupHandles({
  required Rect bounds,
  required bool isGrouped,
  required VoidCallback onGroup,
  required VoidCallback onUngroup,
  required VoidCallback onDelete,
  required VoidCallback onEdit,
}) {
  const pad = 8.0;
  final r = Rect.fromLTRB(
    bounds.left - pad, bounds.top - pad,
    bounds.right + pad, bounds.bottom + pad,
  );

  Widget dot(double left, double top) {
    return Positioned(
      left: left - 5,
      top: top - 5,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue.shade400, width: 2),
        ),
      ),
    );
  }

  Widget actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  return [
    // Dashed-style border (solid for simplicity)
    Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ),
    // 6 corner/midpoint dots
    dot(r.left, r.top),
    dot(r.right, r.top),
    dot(r.left, r.bottom),
    dot(r.right, r.bottom),
    dot(r.left + r.width / 2, r.top),
    dot(r.left + r.width / 2, r.bottom),
    // Action buttons (bottom-right of bounding box)
    Positioned(
      left: r.right - 64,
      top: r.bottom + 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isGrouped) ...[
            // Edit group button
            actionButton(
              icon: Icons.edit,
              color: Colors.blue.shade500,
              onTap: onEdit,
            ),
            const SizedBox(width: 4),
            // Ungroup button
            actionButton(
              icon: Icons.link_off,
              color: Colors.orange.shade500,
              onTap: onUngroup,
            ),
          ] else ...[
            // Group button
            actionButton(
              icon: Icons.link,
              color: Colors.blue.shade500,
              onTap: onGroup,
            ),
          ],
          const SizedBox(width: 4),
          // Delete button (always)
          actionButton(
            icon: Icons.delete_outline,
            color: Colors.red.shade400,
            onTap: onDelete,
          ),
        ],
      ),
    ),
  ];
}
