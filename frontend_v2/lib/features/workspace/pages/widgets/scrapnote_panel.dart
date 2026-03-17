import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/scrapnote/pages/widgets/live_scraps_panel.dart';
import '../providers/tab_provider.dart';

/// Right panel showing scraps (highlights and captures) for the active PDF.
/// Replaces the previous placeholder with the LiveScrapsPanel widget.
class ScrapnotePanel extends ConsumerWidget {
  const ScrapnotePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    final activeTab = ref.watch(tabProviderProvider).activeTab;

    // No PDF open: show a prompt to open a document
    if (activeTab == null) {
      return Container(
        color: colors.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.md,
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                size: AppIconSize.xxl,
                color: colors.mutedForeground,
              ),
              Text(
                'No PDF open',
                style: AppTypography.headline(color: colors.foreground),
              ),
              Text(
                'Open a PDF to see your scraps here.',
                style:
                    AppTypography.subheadline(color: colors.mutedForeground),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: colors.background,
      child: LiveScrapsPanel(pdfPath: activeTab.path),
    );
  }
}
