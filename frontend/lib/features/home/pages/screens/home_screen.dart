import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        Expanded(child: _buildBody(homeState)),
        if (homeState.isMultiSelectMode)
          MultiSelectBottomBar(activeTab: homeState.activeTab),
      ],
    );
  }

  Widget _buildBody(HomeStateData homeState) {
    switch (homeState.activeTab) {
      case HomeTab.allNotes:
        return homeState.viewMode == ViewMode.grid
            ? const NoteGridView(source: NoteSource.all)
            : const NoteListView(source: NoteSource.all);
      case HomeTab.trash:
        return const TrashView();
      case HomeTab.folders:
        return const FoldersView();
    }
  }
}
