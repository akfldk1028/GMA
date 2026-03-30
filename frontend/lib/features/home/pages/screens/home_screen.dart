import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/home_note_list_provider.dart';
import '../../providers/home_state_provider.dart';
import '../widgets/folders_view.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/multi_select_bottom_bar.dart';
import '../widgets/note_grid_view.dart';
import '../widgets/note_list_view.dart';
import '../widgets/sort_bar.dart';
import '../widgets/trash_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    return Column(
      children: [
        const HomeTopBar(),
        if (homeState.activeTab == HomeTab.allNotes) const SortBar(),
        if (homeState.isMultiSelectMode) _buildSelectAllBar(ref, homeState),
        Expanded(child: _buildBody(homeState, ref)),
        if (homeState.isMultiSelectMode)
          MultiSelectBottomBar(activeTab: homeState.activeTab),
      ],
    );
  }

  Widget _buildSelectAllBar(WidgetRef ref, HomeStateData homeState) {
    final notesAsync = ref.watch(allNotesProvider);
    final allIds = notesAsync.valueOrNull?.map((n) => n.id).toList() ?? [];
    final selectedCount = homeState.selectedNoteIds.length;
    final isAllSelected = allIds.isNotEmpty && selectedCount == allIds.length;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (isAllSelected) {
                ref.read(homeStateProvider.notifier).exitMultiSelect();
              } else {
                ref.read(homeStateProvider.notifier).selectAll(allIds);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAllSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  isAllSelected ? 'Deselect All' : 'Select All',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '$selectedCount selected',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(HomeStateData homeState, [WidgetRef? ref]) {
    Widget content;
    switch (homeState.activeTab) {
      case HomeTab.allNotes:
        content = homeState.viewMode == ViewMode.grid
            ? const NoteGridView(source: NoteSource.all)
            : const NoteListView(source: NoteSource.all);
      case HomeTab.trash:
        content = const TrashView();
      case HomeTab.folders:
        content = const FoldersView();
    }
    // In multi-select mode, tapping empty area exits multi-select
    if (homeState.isMultiSelectMode && ref != null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => ref.read(homeStateProvider.notifier).exitMultiSelect(),
        child: content,
      );
    }
    return content;
  }
}
