import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../../constants/app_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../providers/scraps_filter_provider.dart';
import '../widgets/scrap_card.dart';
import '../widgets/scrap_filter_tabs.dart';

class ScrapsLibraryScreen extends ConsumerWidget {
  const ScrapsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(elementStoreProvider);
    final allElements = ref.read(elementStoreProvider.notifier).all();
    final filter = ref.watch(scrapsFilterProvider);
    final capturesDirAsync = ref.watch(capturesDirectoryProvider);
    final capturesDir = capturesDirAsync.valueOrNull?.path;
    final isMobile = Responsive.isMobile(context);

    final filtered = filter == null
        ? allElements
        : allElements.where((e) => e.type == filter).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: isMobile ? 170 : 300,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      mainAxisExtent: isMobile ? 180 : 240,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Scraps Library',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filtered.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'All your highlights, captures, and drawings in one place.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),

            // ── Filter tabs (scrollable on narrow screens) ──
            const ScrapFilterTabs(),
            const SizedBox(height: 20),

            // ── Cards grid ──
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      gridDelegate: gridDelegate,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final el = filtered[index];
                        return ScrapCard(
                          key: ValueKey(el.id),
                          element: el,
                          capturesDir: capturesDir,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.auto_awesome_mosaic_rounded,
              size: 32,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No scraps yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Highlight text in a PDF to create your first scrap.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
