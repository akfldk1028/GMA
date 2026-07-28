import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/home_state_provider.dart';
import 'folder_tree_widget.dart';

class HomeExpandedSidebar extends ConsumerWidget {
  const HomeExpandedSidebar({super.key});

  static const double width = 312.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.ease,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sokSurface,
        border: Border(
          right: BorderSide(color: AppColors.sokDivider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 64,
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: IconButton(
                    onPressed: () =>
                        ref.read(homeStateProvider.notifier).toggleSidebar(),
                    icon: const Icon(Icons.menu_rounded, size: 22),
                    tooltip: '사이드바 닫기',
                    color: AppColors.sokPrimary,
                  ),
                ),
                Image.asset(
                  'assets/brand/soknote_logo.png',
                  width: 100,
                  height: 44,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              ],
            ),
          ),
          // Nav items
          _SidebarNavItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: '모든 노트',
            isActive: homeState.activeTab == HomeTab.allNotes,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.allNotes),
          ),
          _SidebarNavItem(
            icon: Icons.delete_outline,
            activeIcon: Icons.delete,
            label: '휴지통',
            isActive: homeState.activeTab == HomeTab.trash,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.trash),
          ),
          _SidebarNavItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            label: '폴더',
            isActive: homeState.activeTab == HomeTab.folders,
            onTap: () =>
                ref.read(homeStateProvider.notifier).setTab(HomeTab.folders),
          ),
          // Folder tree when folders tab is active
          if (homeState.activeTab == HomeTab.folders) ...[
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppColors.sokDivider,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: isActive ? AppColors.sokHover : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: 22,
                    color: isActive
                        ? AppColors.sokAccent
                        : AppColors.sokSecondary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? AppColors.sokAccent
                        : AppColors.sokPrimary,
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
