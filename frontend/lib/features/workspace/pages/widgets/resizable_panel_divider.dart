import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A draggable divider for resizing adjacent panels.
///
/// Usage:
/// ```dart
/// Row(
///   children: [
///     Expanded(flex: 1, child: LeftPanel()),
///     ResizablePanelDivider(
///       onDrag: (delta) {
///         // Update panel sizes based on delta
///       },
///     ),
///     Expanded(flex: 1, child: RightPanel()),
///   ],
/// )
/// ```
class ResizablePanelDivider extends StatefulWidget {
  const ResizablePanelDivider({
    super.key,
    required this.onDrag,
    this.axis = Axis.vertical,
    this.width = 1.0,
    this.hoverWidth = 4.0,
  });

  /// Callback when the divider is dragged.
  /// Receives the drag delta (positive = right/down, negative = left/up).
  final ValueChanged<double> onDrag;

  /// The axis along which the divider can be dragged.
  /// [Axis.vertical] for horizontal panels (default).
  /// [Axis.horizontal] for vertical panels.
  final Axis axis;

  /// Width of the divider in its normal state.
  final double width;

  /// Width of the divider when hovered or dragged.
  final double hoverWidth;

  @override
  State<ResizablePanelDivider> createState() => _ResizablePanelDividerState();
}

class _ResizablePanelDividerState extends State<ResizablePanelDivider> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on state
    final Color backgroundColor;
    if (_isDragging) {
      backgroundColor = colorScheme.primary;
    } else if (_isHovered) {
      backgroundColor = colorScheme.mutedForeground.withValues(alpha:0.5);
    } else {
      backgroundColor = colorScheme.border;
    }

    // Determine cursor based on axis
    final cursor = widget.axis == Axis.vertical
        ? SystemMouseCursors.resizeColumn
        : SystemMouseCursors.resizeRow;

    // Determine width based on state
    final currentWidth =
        (_isHovered || _isDragging) ? widget.hoverWidth : widget.width;

    return MouseRegion(
      cursor: cursor,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          final delta = widget.axis == Axis.vertical
              ? details.delta.dx
              : details.delta.dy;
          widget.onDrag(delta);
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        onPanCancel: () => setState(() => _isDragging = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: widget.axis == Axis.vertical ? currentWidth : null,
          height: widget.axis == Axis.horizontal ? currentWidth : null,
          color: backgroundColor,
          // Add a subtle visual indicator in the center
          child: Center(
            child: Container(
              width: widget.axis == Axis.vertical ? 2 : 16,
              height: widget.axis == Axis.horizontal ? 2 : 16,
              decoration: BoxDecoration(
                color: _isDragging || _isHovered
                    ? colorScheme.mutedForeground.withValues(alpha:0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
