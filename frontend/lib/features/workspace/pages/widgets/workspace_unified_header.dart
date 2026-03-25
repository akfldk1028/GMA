import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../pdf_viewer/capture/pages/providers/capture_provider.dart';
import '../../../pdf_viewer/capture/pages/providers/lasso_provider.dart';
import '../../../pdf_viewer/drawing/pages/providers/drawing_provider.dart';
import '../../../pdf_viewer/drawing/pages/widgets/drawing_toolbar_widgets.dart';
import '../../../pdf_viewer/drawing/tools/tool_registry.dart';
import '../providers/workspace_provider.dart';

/// Map drawing color value to closest MarkerColor name for highlight sync.
String _colorValueToMarkerName(int colorValue) {
  const map = {
    0xFFEF4444: 'red',
    0xFF3B82F6: 'blue',
    0xFF22C55E: 'green',
    0xFFEAB308: 'yellow',
    0xFFF59E0B: 'yellow',
  };
  return map[colorValue] ?? 'yellow';
}

/// Unified header combining title + drawing tools + menu in a single row.
///
/// Layout matches 260316 기획안 슬라이드 1:
/// ┌─────────────────────────────────────────────────────────┐
/// │ < 제목  │  펜 형광펜 지우개 ● ● ● ── │ 📎 ⋮          │
/// └─────────────────────────────────────────────────────────┘
class WorkspaceUnifiedHeader extends ConsumerWidget {
  const WorkspaceUnifiedHeader({
    super.key,
    required this.title,
    required this.noteId,
    required this.pageNumber,
    required this.onToggleScrapnote,
    required this.onOpenPdf,
    required this.onMenuAction,
  });

  final String title;
  final String? noteId;
  final int? pageNumber;
  final VoidCallback onToggleScrapnote;
  final VoidCallback onOpenPdf;
  final void Function(String action) onMenuAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final drawingMode = ref.watch(drawingModeProvider);
    final isDrawing = drawingMode.isActive;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // ─── Left: Back + Title ───
            _BackButton(onTap: () => context.go('/home')),
            const SizedBox(width: 4),
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(width: 8),
            _HeaderDivider(),
            const SizedBox(width: 4),

            // ─── Center: Drawing tools (always visible per 기획안) ───
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tool buttons from registry (pen, highlighter, eraser)
                    for (final tool in drawingTools)
                      ToolbarIconButton(
                        icon: tool.icon,
                        tooltip: tool.label,
                        isActive: isDrawing &&
                            drawingMode.currentToolId == tool.id,
                        onTap: () {
                          final notifier =
                              ref.read(drawingModeProvider.notifier);
                          if (isDrawing && drawingMode.currentToolId == tool.id) {
                            // Same tool tapped again → turn off
                            notifier.setActive(false);
                          } else {
                            notifier.setActive(true);
                            notifier.selectTool(tool.id);
                          }
                        },
                      ),
                    const ToolbarDivider(),
                    // Color palette (shared: drawing + highlight)
                    for (final color in kDrawingPaletteColors)
                      ToolbarColorDot(
                        color: Color(color),
                        isSelected: drawingMode.colorValue == color,
                        onTap: () {
                          final notifier =
                              ref.read(drawingModeProvider.notifier);
                          if (!isDrawing) notifier.toggleActive();
                          notifier.setColor(color);
                          // Sync highlight color to closest MarkerColor
                          final hlName = _colorValueToMarkerName(color);
                          ref.read(workspaceProviderProvider.notifier)
                              .setHighlightColor(hlName);
                        },
                      ),
                    const ToolbarDivider(),
                    // Stroke size (always visible)
                    for (final size in kDrawingStrokeSizes)
                      ToolbarSizeDot(
                        strokeSize: size,
                        isSelected: drawingMode.strokeSize == size,
                        onTap: () {
                          final notifier =
                              ref.read(drawingModeProvider.notifier);
                          if (!isDrawing) notifier.toggleActive();
                          notifier.setSize(size);
                        },
                      ),
                    const ToolbarDivider(),
                    // Highlight mode toggle + check to complete
                    Builder(builder: (context) {
                      final ws = ref.watch(workspaceProviderProvider).valueOrNull;
                      final isHL = ws?.isHighlightMode ?? false;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ToolbarIconButton(
                            icon: Icons.border_color_rounded,
                            tooltip: isHL ? 'Highlight Mode ON' : 'Highlight Mode',
                            isActive: isHL,
                            activeColor: Colors.green,
                            onTap: () => ref
                                .read(workspaceProviderProvider.notifier)
                                .toggleHighlightMode(),
                          ),
                          if (isHL)
                            ToolbarIconButton(
                              icon: Icons.check_circle,
                              tooltip: 'Highlight Done',
                              isActive: true,
                              activeColor: Colors.green,
                              onTap: () => ref
                                  .read(workspaceProviderProvider.notifier)
                                  .toggleHighlightMode(),
                            ),
                        ],
                      );
                    }),
                    const ToolbarDivider(),
                    // Capture (crop) button
                    ToolbarIconButton(
                      icon: Icons.crop,
                      tooltip: 'Capture',
                      isActive: ref.watch(captureModeProvider),
                      onTap: () => ref
                          .read(captureModeProvider.notifier)
                          .toggle(),
                    ),
                    // Lasso button
                    ToolbarIconButton(
                      icon: Icons.gesture,
                      tooltip: 'Lasso',
                      isActive: ref.watch(lassoModeProvider),
                      onTap: () => ref
                          .read(lassoModeProvider.notifier)
                          .toggle(),
                    ),
                    const ToolbarDivider(),
                    // Quick scrap toggle (슬라이드 10~12)
                    ToolbarIconButton(
                      icon: Icons.bolt,
                      tooltip: 'Quick Scrap',
                      isActive: ref.watch(workspaceProviderProvider)
                              .valueOrNull
                              ?.isQuickScrapMode ==
                          true,
                      activeColor: Colors.amber,
                      onTap: () => ref
                          .read(workspaceProviderProvider.notifier)
                          .toggleQuickScrapMode(),
                    ),
                    const ToolbarDivider(),
                    // Undo / Redo
                    ToolbarIconButton(
                      icon: Icons.undo,
                      tooltip: 'Undo',
                      isActive: false,
                      onTap: (pageNumber != null && noteId != null)
                          ? () => ref
                              .read(
                                  drawingStrokesProvider(noteId!).notifier)
                              .undo(pageNumber!)
                          : null,
                    ),
                    ToolbarIconButton(
                      icon: Icons.redo,
                      tooltip: 'Redo',
                      isActive: false,
                      onTap: (pageNumber != null && noteId != null)
                          ? () => ref
                              .read(
                                  drawingStrokesProvider(noteId!).notifier)
                              .redo(pageNumber!)
                          : null,
                    ),
                  ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Right: Actions ───
            const SizedBox(width: 4),
            _HeaderDivider(),
            const SizedBox(width: 4),

            // Open PDF button
            _HeaderIconBtn(
              icon: Icons.link_rounded,
              tooltip: 'Open PDF',
              onTap: onOpenPdf,
            ),

            // ScrapNote toggle
            _HeaderIconBtn(
              icon: Icons.auto_awesome_mosaic_rounded,
              tooltip: 'ScrapNote',
              onTap: onToggleScrapnote,
            ),

            // Overflow menu
            _OverflowMenu(onAction: onMenuAction),
          ],
        ),
      ),
    );
  }
}

// ─── Private widgets ─────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          Icons.chevron_left_rounded,
          size: 22,
          color: theme.colorScheme.foreground,
        ),
      ),
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      color: ShadTheme.of(context).colorScheme.border,
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  const _HeaderIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    // ignore: unused_element_parameter
  this.isActive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu({required this.onAction});
  final void Function(String action) onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    return PopupMenuButton<String>(
      onSelected: onAction,
      icon: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: theme.colorScheme.mutedForeground,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'swap',
          child: Row(
            children: [
              Icon(Icons.swap_horiz, size: 16),
              SizedBox(width: 8),
              Text('Swap Layout'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'editor',
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 16),
              SizedBox(width: 8),
              Text('Note Editor'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'scrapnote_manage',
          child: Row(
            children: [
              Icon(Icons.collections_bookmark_rounded, size: 16),
              SizedBox(width: 8),
              Text('ScrapNote Manage'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_structure',
          child: Row(
            children: [
              Icon(Icons.account_tree_rounded, size: 16),
              SizedBox(width: 8),
              Text(ref.read(workspaceProviderProvider).valueOrNull?.isStructureOverlayVisible == true
                  ? 'Hide Structure'
                  : 'Show Structure'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'import_pdf_md',
          child: Row(
            children: [
              Icon(Icons.import_contacts_rounded, size: 16),
              SizedBox(width: 8),
              Text('PDF → Note Import'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_rounded, size: 16),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
      ],
    );
  }
}
