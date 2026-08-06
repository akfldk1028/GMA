import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';

typedef DragUpdateCallback = void Function(DragUpdateDetails details);

/// A resizable panel divider that shows a thin visible line inside a wider
/// drag-handle area.
class PanelDivider extends StatefulWidget {
  const PanelDivider({
    super.key,
    required this.onDragUpdate,
  });

  final DragUpdateCallback onDragUpdate;

  @override
  State<PanelDivider> createState() => _PanelDividerState();
}

class _PanelDividerState extends State<PanelDivider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final lineColor = _isDragging
        ? theme.colorScheme.primary
        : theme.colorScheme.border;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragStart: (_) => setState(() => _isDragging = true),
        onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
        onHorizontalDragUpdate: widget.onDragUpdate,
        child: SizedBox(
          width: AppLayout.panelDividerWidth,
          child: Center(
            child: AnimatedContainer(
              duration: AppAnimation.fast,
              width: AppLayout.panelDividerVisible,
              color: lineColor,
            ),
          ),
        ),
      ),
    );
  }
}
