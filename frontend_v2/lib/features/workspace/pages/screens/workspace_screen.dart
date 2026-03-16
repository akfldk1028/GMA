import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/drawing/pages/widgets/drawing_toolbar.dart';
import 'package:gma_app/features/pdf_viewer/pages/screens/pdf_viewer_screen.dart';
import 'package:gma_app/features/sidebar/pages/widgets/item_sidebar.dart';
import 'package:gma_app/features/workspace/pages/providers/panel_provider.dart';
import 'package:gma_app/features/workspace/pages/providers/tab_provider.dart';
import 'package:gma_app/features/workspace/pages/widgets/panel_manager.dart';
import 'package:gma_app/features/workspace/pages/widgets/pdf_tab_bar.dart';
import 'package:gma_app/features/workspace/pages/widgets/scrapnote_panel.dart';
import 'package:gma_app/features/workspace/pages/widgets/secplan_header.dart';

class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure providers are initialized and watched
    ref.watch(panelProviderProvider);
    final tabState = ref.watch(tabProviderProvider);

    final theme = ShadTheme.of(context);

    // Active document path from current tab (if any)
    final activeDocumentPath = tabState.activeTab?.path;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Header bar (52px)
          const SecPlanHeader(),

          // Drawing toolbar (48px) — panel-aware
          DrawingToolbar(
            activeDocumentPath: activeDocumentPath,
            currentPageNumber: 1,
          ),

          // Main content area
          Expanded(
            child: Row(
              children: [
                // Collapsible sidebar (240px or 0)
                const ItemSidebar(),

                // PDF + scrapnote panels
                Expanded(
                  child: Column(
                    children: [
                      // PDF tab bar (44px, conditional)
                      const PdfTabBar(),

                      // Dual-panel layout
                      Expanded(
                        child: PanelManager(
                          leftPanel: const PdfViewerScreen(),
                          rightPanel: const ScrapnotePanel(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
