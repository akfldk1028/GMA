import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/home_state_provider.dart';

class SortBar extends ConsumerWidget {
  const SortBar({super.key});

  String _sortLabel(NoteSortOption option) {
    switch (option) {
      case NoteSortOption.createdDesc:
        return '생성일 (최신순)';
      case NoteSortOption.createdAsc:
        return '생성일 (오래된순)';
      case NoteSortOption.modifiedDesc:
        return '수정일 (최신순)';
      case NoteSortOption.modifiedAsc:
        return '수정일 (오래된순)';
      case NoteSortOption.titleAsc:
        return '제목 (가나다순)';
      case NoteSortOption.titleDesc:
        return '제목 (가나다 역순)';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(homeStateProvider.select((s) => s.sortOption));

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
      child: Row(
        children: [
          PopupMenuButton<NoteSortOption>(
            onSelected: (option) =>
                ref.read(homeStateProvider.notifier).setSortOption(option),
            offset: const Offset(0, 36),
            color: AppColors.sokSurface,
            elevation: 8,
            shadowColor: AppColors.sokPrimary.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                hoverColor: AppColors.sokHover,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sort_rounded,
                        size: 16,
                        color: AppColors.sokSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _sortLabel(sortOption),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.sokSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.sokSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            itemBuilder: (context) => NoteSortOption.values
                .map(
                  (opt) => PopupMenuItem(
                    value: opt,
                    child: Text(
                      _sortLabel(opt),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: opt == sortOption
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: opt == sortOption
                            ? AppColors.sokAccent
                            : AppColors.sokPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
