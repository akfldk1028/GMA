import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gma_app/constants/design_tokens.dart';

/// Placeholder right panel for the Scrapnote Canvas.
/// Will be connected to the scrapnote feature in a future iteration.
class ScrapnotePanel extends ConsumerWidget {
  const ScrapnotePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Container(
      color: colors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.md,
          children: [
            Icon(
              Icons.draw_outlined,
              size: AppIconSize.xxl,
              color: colors.mutedForeground,
            ),
            Text(
              'Scrapnote Canvas',
              style: AppTypography.headline(color: colors.foreground),
            ),
            Text(
              'Drawing and annotation tools will appear here.',
              style: AppTypography.subheadline(color: colors.mutedForeground),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
