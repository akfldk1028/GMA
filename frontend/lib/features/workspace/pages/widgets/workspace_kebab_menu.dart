import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Three-dot context menu for workspace-level actions.
///
/// Provides quick access to workspace settings and utilities.
/// Menu items are currently stubs that show a toast notification.
class WorkspaceKebabMenu extends StatelessWidget {
  const WorkspaceKebabMenu({super.key, this.buttonSize = 32.0, this.iconSize = 18.0});

  final double buttonSize;
  final double iconSize;

  static const _menuItems = [
    (icon: Icons.search_rounded, label: 'Search in PDF'),
    (icon: Icons.image_rounded, label: 'Cover Settings'),
    (icon: Icons.grid_view_rounded, label: 'Page Template'),
    (icon: Icons.bookmark_border_rounded, label: 'Bookmarks'),
    (icon: Icons.info_outline_rounded, label: 'PDF Info'),
  ];

  void _showMenu(BuildContext context) {
    final theme = ShadTheme.of(context);
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(
      Offset(button.size.width, button.size.height),
      ancestor: overlay,
    );

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx - 180,
        offset.dy,
        offset.dx,
        offset.dy + 200,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: theme.colorScheme.background,
      items: [
        for (final item in _menuItems)
          PopupMenuItem<String>(
            value: item.label,
            height: 36,
            child: Row(
              children: [
                Icon(item.icon, size: 16, color: theme.colorScheme.mutedForeground),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value != null && context.mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text(value),
            description: const Text('Coming soon'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Tooltip(
      message: 'More Options',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => _showMenu(context),
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Icon(
              Icons.more_vert_rounded,
              size: iconSize,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
