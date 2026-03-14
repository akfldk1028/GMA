import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../tools/tool_registry.dart';
import '../providers/drawing_provider.dart';
import 'drawing_toolbar_widgets.dart';

/// Drawing toolbar — dynamically built from tool registry.
///
/// No hardcoded tool buttons: iterates drawingTools list.
/// Adding a new tool to tool_registry.dart automatically adds its button.
/// Uses shared widget primitives from [drawing_toolbar_widgets.dart].
class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({super.key, this.pageNumber, this.noteId});

  final int? pageNumber;
  final String? noteId;

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
          ToolbarIconButton(
            icon: Icons.draw,
            tooltip: isActive ? 'Exit Drawing' : 'Start Drawing',
            isActive: isActive,
            activeColor: theme.colorScheme.primary,
            onTap: () => ref.read(drawingModeProvider.notifier).toggleActive(),
          ),
          if (isActive) ...[
            const ToolbarDivider(),
            // Tool buttons from registry
            for (final tool in drawingTools)
              ToolbarIconButton(
                icon: tool.icon,
                tooltip: tool.label,
                isActive: drawingMode.currentToolId == tool.id,
                onTap: () => ref
                    .read(drawingModeProvider.notifier)
                    .selectTool(tool.id),
              ),
            const ToolbarDivider(),
            // Color palette (only if current tool supports color)
            if (getToolById(drawingMode.currentToolId).supportsColor)
              for (final color in kDrawingPaletteColors)
                ToolbarColorDot(
                  color: Color(color),
                  isSelected: drawingMode.colorValue == color,
                  onTap: () =>
                      ref.read(drawingModeProvider.notifier).setColor(color),
                ),
            if (getToolById(drawingMode.currentToolId).supportsColor)
              const ToolbarDivider(),
            // Stroke size
            for (final size in kDrawingStrokeSizes)
              ToolbarSizeDot(
                strokeSize: size,
                isSelected: drawingMode.strokeSize == size,
                onTap: () =>
                    ref.read(drawingModeProvider.notifier).setSize(size),
              ),
            const ToolbarDivider(),
            // Undo / Redo
            ToolbarIconButton(
              icon: Icons.undo,
              tooltip: 'Undo',
              isActive: false,
              onTap: (pageNumber != null && noteId != null)
                  ? () => ref
                      .read(drawingStrokesProvider(noteId!).notifier)
                      .undo(pageNumber!)
                  : null,
            ),
            ToolbarIconButton(
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
}
