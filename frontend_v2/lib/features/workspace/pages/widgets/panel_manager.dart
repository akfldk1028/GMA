import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/workspace/models/secplan_state.dart';
import 'package:gma_app/features/workspace/pages/providers/panel_provider.dart';

import 'panel_divider.dart';

/// Manages dual-panel layout with split, maximized, and swapped states.
/// Wraps each panel in a [FocusScope] and animates transitions.
class PanelManager extends ConsumerWidget {
  const PanelManager({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
  });

  final Widget leftPanel;
  final Widget rightPanel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelState = ref.watch(panelProviderProvider);
    final notifier = ref.read(panelProviderProvider.notifier);

    final Widget left = FocusScope(
      child: GestureDetector(
        onTap: () => notifier.setFocus(FocusedPanel.left),
        behavior: HitTestBehavior.translucent,
        child: leftPanel,
      ),
    );

    final Widget right = FocusScope(
      child: GestureDetector(
        onTap: () => notifier.setFocus(FocusedPanel.right),
        behavior: HitTestBehavior.translucent,
        child: rightPanel,
      ),
    );

    // Maximized states — show only one panel
    if (panelState.maximizedPanel == MaximizedPanel.left) {
      return AnimatedSwitcher(
        duration: AppAnimation.normal,
        child: SizedBox(key: const ValueKey('max-left'), child: left),
      );
    }

    if (panelState.maximizedPanel == MaximizedPanel.right) {
      return AnimatedSwitcher(
        duration: AppAnimation.normal,
        child: SizedBox(key: const ValueKey('max-right'), child: right),
      );
    }

    // Right panel hidden
    if (!panelState.isRightPanelVisible) {
      return AnimatedSwitcher(
        duration: AppAnimation.normal,
        child: SizedBox(key: const ValueKey('left-only'), child: left),
      );
    }

    // Split view
    final first = panelState.isSwapped ? right : left;
    final second = panelState.isSwapped ? left : right;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dividerWidth = AppLayout.panelDividerWidth;
        final availableWidth = totalWidth - dividerWidth;

        final firstWidth = availableWidth * panelState.panelRatio;
        final secondWidth = availableWidth * (1 - panelState.panelRatio);

        return Row(
          children: [
            SizedBox(width: firstWidth, child: first),
            PanelDivider(
              onDragUpdate: (details) {
                final delta = details.delta.dx / totalWidth;
                final newRatio = panelState.panelRatio + delta;
                notifier.setRatio(newRatio);
              },
            ),
            SizedBox(width: secondWidth, child: second),
          ],
        );
      },
    );
  }
}
