import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import 'app_sidebar.dart';
import 'responsive.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  static const sidebarWidth = 260.0;

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isSidebarExpanded = true;
  bool _didAutoCollapse = false;

  static const _navItems = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
    (icon: Icons.folder_rounded, label: 'Library', path: '/file-browser'),
    (icon: Icons.auto_awesome_mosaic_rounded, label: 'Scraps', path: '/scraps'),
    (icon: Icons.hub_rounded, label: 'Graph', path: '/knowledge-graph'),
    (icon: Icons.settings_rounded, label: 'Settings', path: '/settings'),
  ];

  int _currentNavIndex(String currentPath) {
    for (var i = 0; i < _navItems.length; i++) {
      if (currentPath.startsWith(_navItems[i].path)) return i;
    }
    return 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-collapse sidebar on mobile (only once per size change)
    final isMobile = Responsive.isMobile(context);
    if (isMobile && _isSidebarExpanded && !_didAutoCollapse) {
      _isSidebarExpanded = false;
      _didAutoCollapse = true;
    } else if (!isMobile) {
      _didAutoCollapse = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isCompact = MediaQuery.sizeOf(context).width <= Breakpoints.tablet;

    if (isMobile) {
      return _buildMobileShell(context);
    }
    return _buildDesktopShell(context, isCompact);
  }

  Widget _buildMobileShell(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _currentNavIndex(currentPath);

    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.go(_navItems[index].path);
        },
        height: 64,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _navItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon, size: 22),
                  selectedIcon:
                      Icon(item.icon, size: 22, color: AppColors.primary),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDesktopShell(BuildContext context, bool isCompact) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Row(
            children: [
              // Reserve space for sidebar when expanded
              if (_isSidebarExpanded) const SizedBox(width: AppShell.sidebarWidth),
              // Collapsed rail on compact screens
              if (!_isSidebarExpanded && isCompact)
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
                      Tooltip(
                        message: 'Open menu',
                        child: IconButton(
                          onPressed: () =>
                              setState(() => _isSidebarExpanded = true),
                          icon: const Icon(Icons.menu, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: widget.child),
            ],
          ),

          // Sidebar (overlay on tablet, inline on desktop)
          if (_isSidebarExpanded)
            Row(
              children: [
                const AppSidebar(),
                // Dismiss area on compact screens
                if (isCompact)
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _isSidebarExpanded = false),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
