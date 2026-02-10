import 'package:flutter/material.dart';

/// A widget that splits its children into resizable panels with a draggable divider.
///
/// Supports both horizontal and vertical split layouts. Users can drag the divider
/// to resize panels. The split ratio is maintained and can be saved/restored.
///
/// Example usage:
/// ```dart
/// SplitView(
///   axis: Axis.horizontal,
///   initialRatio: 0.3,
///   minRatio: 0.2,
///   maxRatio: 0.8,
///   first: FileTree(),
///   second: ContentView(),
///   dividerWidth: 8.0,
///   onRatioChanged: (ratio) => saveRatio(ratio),
/// )
/// ```
class SplitView extends StatefulWidget {
  /// The first (left/top) child widget
  final Widget first;

  /// The second (right/bottom) child widget
  final Widget second;

  /// Direction of the split (horizontal = left/right, vertical = top/bottom)
  final Axis axis;

  /// Initial ratio of first panel (0.0 to 1.0). Default is 0.5 (50%)
  final double initialRatio;

  /// Minimum ratio for first panel (prevents collapsing). Default is 0.1
  final double minRatio;

  /// Maximum ratio for first panel. Default is 0.9
  final double maxRatio;

  /// Width/height of the draggable divider in pixels. Default is 8.0
  final double dividerWidth;

  /// Color of the divider. If null, uses theme divider color
  final Color? dividerColor;

  /// Color of the divider when hovering. If null, uses primary color with opacity
  final Color? dividerHoverColor;

  /// Callback when the ratio changes (useful for persisting state)
  final ValueChanged<double>? onRatioChanged;

  const SplitView({
    super.key,
    required this.first,
    required this.second,
    this.axis = Axis.horizontal,
    this.initialRatio = 0.5,
    this.minRatio = 0.1,
    this.maxRatio = 0.9,
    this.dividerWidth = 8.0,
    this.dividerColor,
    this.dividerHoverColor,
    this.onRatioChanged,
  })  : assert(initialRatio >= 0.0 && initialRatio <= 1.0),
        assert(minRatio >= 0.0 && minRatio <= 1.0),
        assert(maxRatio >= 0.0 && maxRatio <= 1.0),
        assert(minRatio < maxRatio);

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late double _ratio;
  bool _isDragging = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
  }

  @override
  void didUpdateWidget(SplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRatio != oldWidget.initialRatio) {
      _ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
    }
  }

  void _updateRatio(double delta, double totalSize) {
    setState(() {
      final newRatio = (_ratio + (delta / totalSize))
          .clamp(widget.minRatio, widget.maxRatio);
      if (newRatio != _ratio) {
        _ratio = newRatio;
        widget.onRatioChanged?.call(_ratio);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = widget.axis == Axis.horizontal;
        final totalSize =
            isHorizontal ? constraints.maxWidth : constraints.maxHeight;
        final firstSize = totalSize * _ratio;
        final secondSize = totalSize - firstSize - widget.dividerWidth;

        return Flex(
          direction: widget.axis,
          children: [
            // First panel
            SizedBox(
              width: isHorizontal ? firstSize : null,
              height: isHorizontal ? null : firstSize,
              child: widget.first,
            ),

            // Draggable divider
            MouseRegion(
              cursor: isHorizontal
                  ? SystemMouseCursors.resizeColumn
                  : SystemMouseCursors.resizeRow,
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: GestureDetector(
                onPanStart: (_) => setState(() => _isDragging = true),
                onPanUpdate: (details) {
                  final delta = isHorizontal ? details.delta.dx : details.delta.dy;
                  _updateRatio(delta, totalSize);
                },
                onPanEnd: (_) => setState(() => _isDragging = false),
                child: Container(
                  width: isHorizontal ? widget.dividerWidth : null,
                  height: isHorizontal ? null : widget.dividerWidth,
                  decoration: BoxDecoration(
                    color: _getDividerColor(context),
                    border: Border.all(
                      color: _getBorderColor(context),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: isHorizontal ? 2 : widget.dividerWidth - 4,
                      height: isHorizontal ? widget.dividerWidth - 4 : 2,
                      decoration: BoxDecoration(
                        color: _getHandleColor(context),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Second panel
            SizedBox(
              width: isHorizontal ? secondSize : null,
              height: isHorizontal ? null : secondSize,
              child: widget.second,
            ),
          ],
        );
      },
    );
  }

  Color _getDividerColor(BuildContext context) {
    if (_isDragging || _isHovering) {
      return widget.dividerHoverColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    }
    return widget.dividerColor ?? Theme.of(context).dividerColor;
  }

  Color _getBorderColor(BuildContext context) {
    if (_isDragging) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.5);
    }
    if (_isHovering) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.3);
    }
    return Theme.of(context).dividerColor;
  }

  Color _getHandleColor(BuildContext context) {
    if (_isDragging) {
      return Theme.of(context).colorScheme.primary;
    }
    if (_isHovering) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.7);
    }
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
  }
}
