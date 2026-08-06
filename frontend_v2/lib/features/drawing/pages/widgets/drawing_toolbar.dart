import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/workspace/models/secplan_state.dart';
import 'package:gma_app/features/workspace/pages/providers/panel_provider.dart';
import '../../tools/tool_registry.dart';
import '../providers/drawing_provider.dart';

/// Drawing toolbar — panel-aware, dynamically built from tool registry.
///
/// Panel-aware: routes tool actions to the correct panel's drawing provider.
/// Height matches AppLayout.toolbarHeight (48px).
/// No hardcoded tool buttons: iterates drawingTools list.
class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({
    super.key,
    this.activeDocumentPath,
    this.currentPageNumber,
  });

  final String? activeDocumentPath;
  final int? currentPageNumber;

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
    final panelState = ref.watch(panelProviderProvider);
    final theme = ShadTheme.of(context);
    final isActive = drawingMode.isActive;

    // Determine if we're operating on the focused panel
    final isFocusedLeft = panelState.focusedPanel == FocusedPanel.left;

    return Container(
      height: AppLayout.toolbarHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Row(
        children: [
          // Panel indicator
          Icon(
            isFocusedLeft ? Icons.picture_as_pdf_outlined : Icons.note_outlined,
            size: AppIconSize.sm,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Drawing mode toggle
          _ToggleButton(
            icon: Icons.draw,
            tooltip: isActive ? 'Exit Drawing' : 'Start Drawing',
            isActive: isActive,
            activeColor: theme.colorScheme.primary,
            onTap: () =>
                ref.read(drawingModeProvider.notifier).toggleActive(),
          ),

          if (isActive) ...[
            _divider(theme),
            // Tool buttons from registry
            for (final tool in drawingTools)
              _ToolButton(
                icon: tool.icon,
                tooltip: tool.label,
                isActive: drawingMode.currentToolId == tool.id,
                onTap: () =>
                    ref.read(drawingModeProvider.notifier).selectTool(tool.id),
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
              onTap: (activeDocumentPath != null && currentPageNumber != null)
                  ? () => ref
                      .read(
                        drawingStrokesProvider(activeDocumentPath!).notifier,
                      )
                      .undo(currentPageNumber!)
                  : null,
            ),
            _ToggleButton(
              icon: Icons.redo,
              tooltip: 'Redo',
              isActive: false,
              onTap: (activeDocumentPath != null && currentPageNumber != null)
                  ? () => ref
                      .read(
                        drawingStrokesProvider(activeDocumentPath!).notifier,
                      )
                      .redo(currentPageNumber!)
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
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
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
            size: AppIconSize.sm,
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
            size: AppIconSize.sm,
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
        width: 20,
        height: 20,
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
                  ),
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
