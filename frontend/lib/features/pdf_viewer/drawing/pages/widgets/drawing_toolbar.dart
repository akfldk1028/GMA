import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../tools/tool_registry.dart';
import '../providers/drawing_provider.dart';

/// Drawing toolbar — dynamically built from tool registry.
///
/// No hardcoded tool buttons: iterates drawingTools list.
/// Adding a new tool to tool_registry.dart automatically adds its button.
class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({super.key, this.pageNumber, this.noteId});

  final int? pageNumber;
  final String? noteId;

  static const _paletteColors = [
    0xFF000000, // black
    0xFFEF4444, // red
    0xFF3B82F6, // blue
    0xFF22C55E, // green
    0xFFEAB308, // yellow
  ];

  static const _strokeSizes = [2.0, 4.0, 8.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingMode = ref.watch(drawingModeProvider);
    final theme = ShadTheme.of(context);
    final isActive = drawingMode.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drawing mode toggle
          _ToggleButton(
            icon: Icons.draw,
            tooltip: isActive ? 'Exit Drawing' : 'Start Drawing',
            isActive: isActive,
            activeColor: theme.colorScheme.primary,
            onTap: () => ref.read(drawingModeProvider.notifier).toggleActive(),
          ),
          if (isActive) ...[
            _divider(theme),
            // Tool buttons from registry
            for (final tool in drawingTools)
              _ToolButton(
                icon: tool.icon,
                tooltip: tool.label,
                isActive: drawingMode.currentToolId == tool.id,
                onTap: () => ref
                    .read(drawingModeProvider.notifier)
                    .selectTool(tool.id),
              ),
            _divider(theme),
            // Color palette (only if current tool supports color)
            if (getToolById(drawingMode.currentToolId).supportsColor)
              for (final color in _paletteColors)
                _ColorDot(
                  color: Color(color),
                  isSelected: drawingMode.colorValue == color,
                  onTap: () =>
                      ref.read(drawingModeProvider.notifier).setColor(color),
                ),
            if (getToolById(drawingMode.currentToolId).supportsColor)
              _divider(theme),
            // Stroke size
            for (final size in _strokeSizes)
              _SizeDot(
                size: size,
                isSelected: drawingMode.strokeSize == size,
                foreground: theme.colorScheme.foreground,
                onTap: () =>
                    ref.read(drawingModeProvider.notifier).setSize(size),
              ),
            _divider(theme),
            // Undo / Redo
            _ToggleButton(
              icon: Icons.undo,
              tooltip: 'Undo',
              isActive: false,
              onTap: (pageNumber != null && noteId != null)
                  ? () => ref
                      .read(drawingStrokesProvider(noteId!).notifier)
                      .undo(pageNumber!)
                  : null,
            ),
            _ToggleButton(
              icon: Icons.redo,
              tooltip: 'Redo',
              isActive: false,
              onTap: (pageNumber != null && noteId != null)
                  ? () => ref
                      .read(drawingStrokesProvider(noteId!).notifier)
                      .redo(pageNumber!)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider(ShadThemeData theme) => Container(
        width: 1,
        height: 20,
        color: theme.colorScheme.border,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    this.activeColor,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? (activeColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? (activeColor ?? theme.colorScheme.primary)
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}

class _SizeDot extends StatelessWidget {
  const _SizeDot({
    required this.size,
    required this.isSelected,
    required this.foreground,
    required this.onTap,
  });

  final double size;
  final bool isSelected;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Tooltip(
      message: '${size.toInt()}px',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          child: Center(
            child: Container(
              width: size + 2,
              height: size + 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
