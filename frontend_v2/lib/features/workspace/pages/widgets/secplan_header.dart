import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/workspace/models/secplan_state.dart';
import 'package:gma_app/features/workspace/pages/providers/panel_provider.dart';
import 'package:gma_app/features/workspace/pages/providers/tab_provider.dart';

import 'kebab_menu.dart';

/// Top header bar for the SecPlan workspace.
/// Height: [AppLayout.headerHeight] (52px).
///
/// Layout (left to right):
///   Back | Title (editable) | Swap | Ratio label | Maximize/Restore | Note toggle | Kebab
class SecPlanHeader extends ConsumerStatefulWidget {
  const SecPlanHeader({super.key});

  @override
  ConsumerState<SecPlanHeader> createState() => _SecPlanHeaderState();
}

class _SecPlanHeaderState extends ConsumerState<SecPlanHeader> {
  late TextEditingController _titleController;
  bool _editingTitle = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _titleFromTab() {
    final tabState = ref.read(tabProviderProvider);
    final active = tabState.activeTab;
    if (active == null) return 'SecPlan';
    return p.basenameWithoutExtension(active.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final panelState = ref.watch(panelProviderProvider);
    final panelNotifier = ref.read(panelProviderProvider.notifier);

    final isMaximized = panelState.maximizedPanel != MaximizedPanel.none;
    final ratioPercent = (panelState.panelRatio * 100).round();

    return Container(
      height: AppLayout.headerHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.border,
            width: AppLayout.panelDividerVisible,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          // Back button
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: const Icon(Icons.arrow_back_ios_new, size: AppIconSize.sm),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Editable title
          Expanded(
            child: GestureDetector(
              onDoubleTap: () {
                _titleController.text = _titleFromTab();
                setState(() => _editingTitle = true);
              },
              child: _editingTitle
                  ? ShadInput(
                      controller: _titleController,
                      autofocus: true,
                      style: AppTypography.headline(
                          color: theme.colorScheme.foreground),
                      onSubmitted: (_) =>
                          setState(() => _editingTitle = false),
                    )
                  : Text(
                      _titleFromTab(),
                      style: AppTypography.headline(
                          color: theme.colorScheme.foreground),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Ratio label
          if (!isMaximized && panelState.isRightPanelVisible)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                '$ratioPercent / ${100 - ratioPercent}',
                style: AppTypography.caption1(
                    color: theme.colorScheme.mutedForeground),
              ),
            ),

          // Swap panels
          ShadTooltip(
            builder: (_) => const Text('Swap Panels'),
            child: ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: panelNotifier.swap,
              child: const Icon(Icons.swap_horiz, size: AppIconSize.sm),
            ),
          ),

          // Maximize / Restore
          ShadTooltip(
            builder: (_) => Text(isMaximized ? 'Restore' : 'Maximize Left'),
            child: ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () => isMaximized
                  ? panelNotifier.restore()
                  : panelNotifier.maximize(MaximizedPanel.left),
              child: Icon(
                isMaximized
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen,
                size: AppIconSize.sm,
              ),
            ),
          ),

          // Toggle note panel
          ShadTooltip(
            builder: (_) => Text(
              panelState.isRightPanelVisible
                  ? 'Hide Notes'
                  : 'Show Notes',
            ),
            child: ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: panelNotifier.toggleRightPanel,
              child: Icon(
                panelState.isRightPanelVisible
                    ? Icons.notes
                    : Icons.note_add_outlined,
                size: AppIconSize.sm,
              ),
            ),
          ),

          // Kebab menu
          const KebabMenu(),
        ],
      ),
    );
  }
}
