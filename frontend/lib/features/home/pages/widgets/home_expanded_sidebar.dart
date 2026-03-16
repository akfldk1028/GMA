import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/home_state_provider.dart';
import 'folder_tree_widget.dart';

class HomeExpandedSidebar extends ConsumerWidget {
  const HomeExpandedSidebar({super.key});

  static const double width = 200.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Header with collapse button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () =>
                      ref.read(homeStateProvider.notifier).toggleSidebar(),
                  icon: const Icon(Icons.menu_open, size: 22),
                  tooltip: 'Collapse sidebar',
                ),
                const SizedBox(width: 4),
                const Text(
                  'LinkNote',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nav items
          _SidebarNavItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'All Notes',
            isActive: homeState.activeTab == HomeTab.allNotes,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.allNotes),
          ),
          _SidebarNavItem(
            icon: Icons.delete_outline,
            activeIcon: Icons.delete,
            label: 'Trash',
            isActive: homeState.activeTab == HomeTab.trash,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.trash),
          ),
          _SidebarNavItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            label: 'Folders',
            isActive: homeState.activeTab == HomeTab.folders,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.folders),
          ),
          // Folder tree when folders tab is active
          if (homeState.activeTab == HomeTab.folders) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            const Expanded(child: FolderTreeWidget()),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isActive ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 20,
                  color:
                      isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
