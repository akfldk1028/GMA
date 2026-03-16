import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/home_state_provider.dart';

class HomeIconRail extends ConsumerWidget {
  const HomeIconRail({super.key});

  static const double width = 56.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Hamburger menu
          IconButton(
            onPressed: () =>
                ref.read(homeStateProvider.notifier).toggleSidebar(),
            icon: const Icon(Icons.menu, size: 22),
            tooltip: 'Expand sidebar',
          ),
          const SizedBox(height: 16),
          // Nav items
          _RailItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'All Notes',
            isActive: homeState.activeTab == HomeTab.allNotes,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.allNotes),
          ),
          _RailItem(
            icon: Icons.delete_outline,
            activeIcon: Icons.delete,
            label: 'Trash',
            isActive: homeState.activeTab == HomeTab.trash,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.trash),
          ),
          _RailItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            label: 'Folders',
            isActive: homeState.activeTab == HomeTab.folders,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.folders),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Tooltip(
        message: label,
        child: Material(
          color: isActive
              ? AppColors.primaryLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
