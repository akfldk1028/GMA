import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/home_state_provider.dart';

class SortBar extends ConsumerWidget {
  const SortBar({super.key});

  String _sortLabel(NoteSortOption option) {
    switch (option) {
      case NoteSortOption.createdDesc:
        return 'Created (newest)';
      case NoteSortOption.createdAsc:
        return 'Created (oldest)';
      case NoteSortOption.modifiedDesc:
        return 'Modified (newest)';
      case NoteSortOption.modifiedAsc:
        return 'Modified (oldest)';
      case NoteSortOption.titleAsc:
        return 'Title (A-Z)';
      case NoteSortOption.titleDesc:
        return 'Title (Z-A)';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(
        homeStateProvider.select((s) => s.sortOption));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          PopupMenuButton<NoteSortOption>(
            onSelected: (option) =>
                ref.read(homeStateProvider.notifier).setSortOption(option),
            offset: const Offset(0, 36),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort_rounded,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  _sortLabel(sortOption),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_downward,
                    size: 14, color: AppColors.textSecondary),
              ],
            ),
            itemBuilder: (context) => NoteSortOption.values
                .map((opt) => PopupMenuItem(
                      value: opt,
                      child: Text(
                        _sortLabel(opt),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: opt == sortOption
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: opt == sortOption
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
