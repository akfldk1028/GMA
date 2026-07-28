import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../features/home/pages/widgets/home_expanded_sidebar.dart';
import '../features/home/pages/widgets/home_icon_rail.dart';
import '../features/home/providers/home_state_provider.dart';
import 'responsive.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _mobileNavItems = [
    (
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: '노트',
      tab: HomeTab.allNotes,
    ),
    (
      icon: Icons.delete_outline,
      activeIcon: Icons.delete,
      label: '휴지통',
      tab: HomeTab.trash,
    ),
    (
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
      label: '폴더',
      tab: HomeTab.folders,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final currentPath = GoRouterState.of(context).uri.path;
    final isHomePath = currentPath.startsWith('/home');

    if (isMobile) {
      return _buildMobileShell(context, ref, isHomePath);
    }
    return _buildDesktopShell(context, ref, isHomePath);
  }

  Widget _buildMobileShell(
    BuildContext context,
    WidgetRef ref,
    bool isHomePath,
  ) {
    if (!isHomePath) {
      // Non-home routes: no bottom nav
      return Scaffold(body: SafeArea(child: child));
    }

    final homeState = ref.watch(homeStateProvider);
    final selectedIndex = _mobileNavItems.indexWhere(
      (item) => item.tab == homeState.activeTab,
    );

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.clamp(0, _mobileNavItems.length - 1),
        onDestinationSelected: (index) {
          ref
              .read(homeStateProvider.notifier)
              .setTab(_mobileNavItems[index].tab);
        },
        height: 64,
        backgroundColor: AppColors.sokSurface,
        indicatorColor: AppColors.sokHover,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _mobileNavItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon, size: 22),
                selectedIcon: Icon(
                  item.activeIcon,
                  size: 22,
                  color: AppColors.sokAccent,
                ),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDesktopShell(
    BuildContext context,
    WidgetRef ref,
    bool isHomePath,
  ) {
    if (!isHomePath) {
      // Non-home routes (dashboard, settings, etc.): minimal shell
      return Scaffold(
        body: Row(
          children: [
            // Minimal back rail
            Container(
              width: 48,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  right: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    tooltip: 'Back to Home',
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    final isSidebarExpanded = ref.watch(
      homeStateProvider.select((s) => s.isSidebarExpanded),
    );

    return Scaffold(
      backgroundColor: AppColors.sokBackground,
      body: ColoredBox(
        color: AppColors.sokBackground,
        child: Row(
          children: [
            // Sidebar: icon rail or expanded, swipe to toggle
            GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity > 200 && !isSidebarExpanded) {
                  ref.read(homeStateProvider.notifier).setSidebarExpanded(true);
                } else if (velocity < -200 && isSidebarExpanded) {
                  ref
                      .read(homeStateProvider.notifier)
                      .setSidebarExpanded(false);
                }
              },
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.ease,
                alignment: Alignment.centerLeft,
                child: isSidebarExpanded
                    ? const HomeExpandedSidebar()
                    : const HomeIconRail(),
              ),
            ),
            // Main content
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
