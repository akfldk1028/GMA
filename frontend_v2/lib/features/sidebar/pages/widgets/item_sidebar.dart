import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/sidebar/pages/providers/sidebar_provider.dart';

/// Left collapsible sidebar showing scrapnote elements filtered by type.
/// Width: [AppLayout.sidebarWidthExpanded] (240px) when open, 0 when closed.
class ItemSidebar extends ConsumerWidget {
  const ItemSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarState = ref.watch(sidebarProviderProvider);
    final notifier = ref.read(sidebarProviderProvider.notifier);
    final theme = ShadTheme.of(context);

    return AnimatedContainer(
      duration: AppAnimation.normal,
      curve: AppAnimation.defaultCurve,
      width:
          sidebarState.isOpen ? AppLayout.sidebarWidthExpanded : 0,
      child: sidebarState.isOpen
          ? _SidebarContent(
              state: sidebarState,
              notifier: notifier,
              theme: theme,
            )
          : const SizedBox.shrink(),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.state,
    required this.notifier,
    required this.theme,
  });

  final SidebarState state;
  final SidebarProvider notifier;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          right: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Column(
        children: [
          _FilterTabBar(state: state, notifier: notifier, theme: theme),
          Expanded(child: _EmptyState(theme: theme)),
        ],
      ),
    );
  }
}

class _FilterTabBar extends StatelessWidget {
  const _FilterTabBar({
    required this.state,
    required this.notifier,
    required this.theme,
  });

  final SidebarState state;
  final SidebarProvider notifier;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppLayout.tabBarHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: SidebarFilter.values.map((filter) {
          final isActive = state.filter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => notifier.setFilter(filter),
              child: AnimatedContainer(
                duration: AppAnimation.fast,
                decoration: BoxDecoration(
                  border: isActive
                      ? Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  SidebarProvider.getElementLabel(filter),
                  style: AppTypography.caption1(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.sm,
        children: [
          Icon(
            Icons.layers_outlined,
            size: AppIconSize.xl,
            color: theme.colorScheme.mutedForeground,
          ),
          Text(
            'No items yet',
            style: AppTypography.footnote(
                color: theme.colorScheme.mutedForeground),
          ),
        ],
      ),
    );
  }
}
