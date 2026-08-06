import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/workspace/pages/providers/tab_provider.dart';

/// Horizontal tab bar showing open PDF tabs.
/// Hidden when there is only one or zero tabs.
/// Height: [AppLayout.tabBarHeight] (44px).
class PdfTabBar extends ConsumerWidget {
  const PdfTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabProviderProvider);
    final notifier = ref.read(tabProviderProvider.notifier);

    if (!tabState.showTabBar) return const SizedBox.shrink();

    final theme = ShadTheme.of(context);

    return Container(
      height: AppLayout.tabBarHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabState.tabs.length,
                itemBuilder: (context, index) {
                  final tab = tabState.tabs[index];
                  final isActive = index == tabState.activeIndex;

                  return _PdfTab(
                    title: tab.title,
                    isActive: isActive,
                    onTap: () => notifier.switchTab(index),
                    onClose: () => notifier.closeTab(index),
                  );
                },
              ),
            ),
          ),

          // Add tab button
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            onPressed: () {
              // Tab addition is triggered externally by opening a PDF.
            },
            child: const Icon(Icons.add, size: AppIconSize.sm),
          ),
        ],
      ),
    );
  }
}

class _PdfTab extends StatefulWidget {
  const _PdfTab({
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  State<_PdfTab> createState() => _PdfTabState();
}

class _PdfTabState extends State<_PdfTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final bgColor = widget.isActive
        ? theme.colorScheme.primary.withAlpha(20)
        : Colors.transparent;

    final borderColor =
        widget.isActive ? theme.colorScheme.primary : theme.colorScheme.border;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppAnimation.fast,
          margin: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  widget.title,
                  style: AppTypography.caption1(
                    color: widget.isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isActive || _hovered)
                GestureDetector(
                  onTap: widget.onClose,
                  child: Icon(
                    Icons.close,
                    size: AppIconSize.xs,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
