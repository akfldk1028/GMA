import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';

/// Three-dot overflow menu for workspace actions.
/// Stubs show a "Coming Soon" toast; Delete shows a confirmation dialog.
class KebabMenu extends ConsumerWidget {
  const KebabMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadPopover(
      popover: (_) => _MenuContent(context: context),
      child: ShadButton.ghost(
        size: ShadButtonSize.sm,
        onPressed: () {},
        child: const Icon(Icons.more_vert, size: AppIconSize.sm),
      ),
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent({required this.context});

  final BuildContext context;

  void _showComingSoon(BuildContext ctx, String feature) {
    ShadToaster.of(ctx).show(
      ShadToast(
        title: Text('$feature — Coming Soon'),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx) {
    showShadDialog<void>(
      context: ctx,
      builder: (_) => ShadDialog(
        title: const Text('Delete Document'),
        description: const Text(
          'Are you sure you want to delete this document? This action cannot be undone.',
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showComingSoon(ctx, 'Delete');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext outerContext) {
    final theme = ShadTheme.of(outerContext);

    Widget item({
      required IconData icon,
      required String label,
      VoidCallback? onTap,
      bool destructive = false,
    }) {
      final color = destructive
          ? theme.colorScheme.destructive
          : theme.colorScheme.foreground;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              Icon(icon, size: AppIconSize.sm, color: color),
              Text(label, style: AppTypography.subheadline(color: color)),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary actions
          item(
            icon: Icons.search,
            label: 'Search',
            onTap: () => _showComingSoon(outerContext, 'Search'),
          ),
          item(
            icon: Icons.image_outlined,
            label: 'Cover Settings',
            onTap: () => _showComingSoon(outerContext, 'Cover Settings'),
          ),
          item(
            icon: Icons.dashboard_outlined,
            label: 'Page Template',
            onTap: () => _showComingSoon(outerContext, 'Page Template'),
          ),
          item(
            icon: Icons.settings_outlined,
            label: 'Page Settings',
            onTap: () => _showComingSoon(outerContext, 'Page Settings'),
          ),
          item(
            icon: Icons.save_alt_outlined,
            label: 'Save as File',
            onTap: () => _showComingSoon(outerContext, 'Save as File'),
          ),
          item(
            icon: Icons.info_outline,
            label: 'Info',
            onTap: () => _showComingSoon(outerContext, 'Info'),
          ),

          Divider(height: AppSpacing.sm, color: theme.colorScheme.border),

          // Bottom actions
          item(
            icon: Icons.bookmark_outline,
            label: 'Bookmark',
            onTap: () => _showComingSoon(outerContext, 'Bookmark'),
          ),
          item(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () => _showComingSoon(outerContext, 'Share'),
          ),
          item(
            icon: Icons.ios_share_outlined,
            label: 'Export',
            onTap: () => _showComingSoon(outerContext, 'Export'),
          ),
          item(
            icon: Icons.delete_outline,
            label: 'Delete',
            destructive: true,
            onTap: () => _confirmDelete(outerContext),
          ),
        ],
      ),
    );
  }
}
