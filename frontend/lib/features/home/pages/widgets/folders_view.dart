import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/folder_store.dart';
import '../../providers/home_state_provider.dart';
import 'folder_chip_bar.dart';
import 'folder_create_dialog.dart';
import 'note_grid_view.dart';
import 'note_list_view.dart';
import 'sort_bar.dart';

class FoldersView extends ConsumerWidget {
  const FoldersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);
    ref.watch(folderStoreProvider);
    final folders = ref.read(folderStoreProvider.notifier).getChildren(null);

    // Find selected folder name for breadcrumb
    final selectedFolder = homeState.currentFolderId != null
        ? folders
              .where((f) => f.id == homeState.currentFolderId)
              .firstOrNull
        : null;

    return Column(
      children: [
        // Folder chip bar (always visible)
        FolderChipBar(
          folders: folders,
          selectedFolderId: homeState.currentFolderId,
          onSelected: (id) =>
              ref.read(homeStateProvider.notifier).setCurrentFolder(id),
          onCreateNew: () => showFolderCreateDialog(context, ref),
        ),
        // Breadcrumb (when folder selected)
        if (selectedFolder != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(homeStateProvider.notifier)
                      .setCurrentFolder(null),
                  child: const Icon(Icons.folder_outlined,
                      size: 16, color: AppColors.textMuted),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.chevron_right,
                      size: 16, color: AppColors.textMuted),
                ),
                Text(
                  selectedFolder.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        // Sort bar (always visible)
        const SortBar(),
        // Notes grid or empty state
        Expanded(
          child: homeState.viewMode == ViewMode.grid
              ? const NoteGridView(source: NoteSource.folder)
              : const NoteListView(source: NoteSource.folder),
        ),
      ],
    );
  }
}
