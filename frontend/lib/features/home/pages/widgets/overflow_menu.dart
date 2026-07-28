import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../providers/home_note_list_provider.dart';
import '../../providers/home_state_provider.dart';

class OverflowMenu extends ConsumerWidget {
  const OverflowMenu({
    super.key,
    this.isTrash = false,
    this.onOpenPdf,
    this.onCreateFolder,
  });

  final bool isTrash;
  final VoidCallback? onOpenPdf;
  final VoidCallback? onCreateFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 22, color: AppColors.sokPrimary),
      tooltip: '더 보기',
      color: AppColors.sokSurface,
      elevation: 8,
      shadowColor: AppColors.sokPrimary.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      onSelected: (value) => _onSelected(context, ref, value, homeState),
      itemBuilder: (context) => [
        if (onOpenPdf != null)
          const PopupMenuItem(
            value: 'openPdf',
            child: _MenuRow(
              icon: Icons.picture_as_pdf_outlined,
              label: 'PDF 열기',
            ),
          ),
        if (onCreateFolder != null)
          const PopupMenuItem(
            value: 'createFolder',
            child: _MenuRow(
              icon: Icons.create_new_folder_outlined,
              label: '새 폴더',
            ),
          ),
        const PopupMenuItem(
          value: 'edit',
          child: _MenuRow(icon: Icons.edit_outlined, label: '선택'),
        ),
        if (isTrash)
          const PopupMenuItem(
            value: 'emptyTrash',
            child: _MenuRow(
              icon: Icons.delete_forever,
              label: '휴지통 비우기',
              color: AppColors.error,
            ),
          ),
        PopupMenuItem(
          value: 'viewToggle',
          child: _MenuRow(
            icon: homeState.viewMode == ViewMode.grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded,
            label: homeState.viewMode == ViewMode.grid ? '목록 보기' : '격자 보기',
          ),
        ),
        if (!isTrash)
          PopupMenuItem(
            value: 'pinToggle',
            child: _MenuRow(
              icon: homeState.pinFavoritesToTop
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
              label: homeState.pinFavoritesToTop ? '즐겨찾기 고정 해제' : '즐겨찾기 고정',
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'dashboard',
          child: _MenuRow(icon: Icons.dashboard_outlined, label: '대시보드'),
        ),
        const PopupMenuItem(
          value: 'graph',
          child: _MenuRow(icon: Icons.hub_outlined, label: '지식 그래프'),
        ),
        const PopupMenuItem(
          value: 'scraps',
          child: _MenuRow(
            icon: Icons.auto_awesome_mosaic_outlined,
            label: '스크랩 보관함',
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: _MenuRow(icon: Icons.settings_outlined, label: '설정'),
        ),
      ],
    );
  }

  void _onSelected(
    BuildContext context,
    WidgetRef ref,
    String value,
    HomeStateData state,
  ) {
    final notifier = ref.read(homeStateProvider.notifier);
    switch (value) {
      case 'openPdf':
        onOpenPdf?.call();
      case 'createFolder':
        onCreateFolder?.call();
      case 'edit':
        notifier.enterMultiSelect();
      case 'emptyTrash':
        _emptyTrash(context, ref);
      case 'viewToggle':
        notifier.setViewMode(
          state.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
        );
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
          'All items in trash will be permanently deleted. This cannot be undone.',
        ),
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
        Icon(icon, size: 18, color: color ?? AppColors.sokSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color ?? AppColors.sokPrimary),
        ),
      ],
    );
  }
}
