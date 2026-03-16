import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../providers/home_note_list_provider.dart';
import '../../providers/home_state_provider.dart';

class OverflowMenu extends ConsumerWidget {
  const OverflowMenu({super.key, this.isTrash = false});

  final bool isTrash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 22, color: AppColors.textSecondary),
      tooltip: 'More options',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      onSelected: (value) => _onSelected(context, ref, value, homeState),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: _MenuRow(icon: Icons.edit_outlined, label: 'Select'),
        ),
        if (isTrash)
          const PopupMenuItem(
            value: 'emptyTrash',
            child: _MenuRow(
              icon: Icons.delete_forever,
              label: 'Empty Trash',
              color: AppColors.error,
            ),
          ),
        PopupMenuItem(
          value: 'viewToggle',
          child: _MenuRow(
            icon: homeState.viewMode == ViewMode.grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded,
            label: homeState.viewMode == ViewMode.grid ? 'List View' : 'Grid View',
          ),
        ),
        if (!isTrash)
          PopupMenuItem(
            value: 'pinToggle',
            child: _MenuRow(
              icon: homeState.pinFavoritesToTop
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
              label: homeState.pinFavoritesToTop
                  ? 'Unpin Favorites'
                  : 'Pin Favorites to Top',
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'dashboard',
          child: _MenuRow(icon: Icons.dashboard_outlined, label: 'Dashboard'),
        ),
        const PopupMenuItem(
          value: 'graph',
          child: _MenuRow(icon: Icons.hub_outlined, label: 'Knowledge Graph'),
        ),
        const PopupMenuItem(
          value: 'scraps',
          child: _MenuRow(icon: Icons.auto_awesome_mosaic_outlined, label: 'Scraps Library'),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: _MenuRow(icon: Icons.settings_outlined, label: 'Settings'),
        ),
      ],
    );
  }

  void _onSelected(
      BuildContext context, WidgetRef ref, String value, HomeStateData state) {
    final notifier = ref.read(homeStateProvider.notifier);
    switch (value) {
      case 'edit':
        notifier.enterMultiSelect();
      case 'emptyTrash':
        _emptyTrash(context, ref);
      case 'viewToggle':
        notifier.setViewMode(
            state.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid);
      case 'pinToggle':
        notifier.togglePinFavoritesToTop();
      case 'dashboard':
        context.go('/dashboard');
      case 'graph':
        context.go('/knowledge-graph');
      case 'scraps':
        context.go('/scraps');
      case 'settings':
        context.go('/settings');
    }
  }

  Future<void> _emptyTrash(BuildContext context, WidgetRef ref) async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Empty Trash'),
        description: const Text(
            'All items in trash will be permanently deleted. This cannot be undone.'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final trashNotes = await ref.read(trashNotesProvider.future);
    for (final note in trashNotes) {
      await ref
          .read(permanentDeleteMutationProvider.notifier)
          .call(filePath: note.filePath);
    }
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }
}
