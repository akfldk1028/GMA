import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/home_state_provider.dart';

class HomeIconRail extends ConsumerWidget {
  const HomeIconRail({super.key});

  static const double width = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sokSurface,
        border: Border(
          right: BorderSide(color: AppColors.sokDivider, width: 1),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Center(
              child: IconButton(
                onPressed: () =>
                    ref.read(homeStateProvider.notifier).toggleSidebar(),
                icon: const Icon(Icons.menu_rounded, size: 22),
                tooltip: '사이드바 열기',
                color: AppColors.sokPrimary,
              ),
            ),
          ),
          // Nav items
          _RailItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: '모든 노트',
            isActive: homeState.activeTab == HomeTab.allNotes,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.allNotes),
          ),
          _RailItem(
            icon: Icons.delete_outline,
            activeIcon: Icons.delete,
            label: '휴지통',
            isActive: homeState.activeTab == HomeTab.trash,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.trash),
          ),
          _RailItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            label: '폴더',
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Tooltip(
        message: label,
        child: Material(
          color: isActive ? AppColors.sokHover : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 40,
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? AppColors.sokAccent : AppColors.sokSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
