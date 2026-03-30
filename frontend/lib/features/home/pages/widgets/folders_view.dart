import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../models/folder_model.dart';
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
    final store = ref.read(folderStoreProvider.notifier);
    final childFolders = store.getChildren(homeState.currentFolderId);

    // Build ancestor breadcrumb path
    final ancestors = homeState.currentFolderId != null
        ? store.getAncestors(homeState.currentFolderId!)
        : <FolderModel>[];

    return Column(
      children: [
        // Folder chip bar (children of current folder)
        FolderChipBar(
          folders: childFolders,
          selectedFolderId: null,
          onSelected: (id) =>
              ref.read(homeStateProvider.notifier).setCurrentFolder(id),
          onCreateNew: () => showFolderCreateDialog(context, ref,
              parentId: homeState.currentFolderId),
        ),
        // Breadcrumb (when inside a folder)
        if (ancestors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Root icon
                  GestureDetector(
                    onTap: () => ref
                        .read(homeStateProvider.notifier)
                        .setCurrentFolder(null),
                    child: const Icon(Icons.folder_outlined,
                        size: 16, color: AppColors.textMuted),
                  ),
                  // Each ancestor
                  for (final ancestor in ancestors) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.chevron_right,
                          size: 16, color: AppColors.textMuted),
                    ),
                    GestureDetector(
                      onTap: () => ref
                          .read(homeStateProvider.notifier)
                          .setCurrentFolder(ancestor.id),
                      child: Text(
                        ancestor.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: ancestor.id == homeState.currentFolderId
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: ancestor.id == homeState.currentFolderId
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        // Sort bar
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
