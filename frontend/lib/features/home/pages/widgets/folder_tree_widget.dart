import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../models/folder_model.dart';
import '../../providers/folder_store.dart';
import '../../providers/home_state_provider.dart';
import 'folder_create_dialog.dart';

class FolderTreeWidget extends ConsumerStatefulWidget {
  const FolderTreeWidget({super.key});

  @override
  ConsumerState<FolderTreeWidget> createState() => _FolderTreeWidgetState();
}

class _FolderTreeWidgetState extends ConsumerState<FolderTreeWidget> {
  final Set<String> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    ref.watch(folderStoreProvider);
    final store = ref.read(folderStoreProvider.notifier);
    final currentFolderId = ref.watch(
      homeStateProvider.select((s) => s.currentFolderId),
    );
    final notesAsync = ref.watch(fileManagerProvider);
    final allNotes = notesAsync.valueOrNull ?? [];
    final activeNotes = allNotes.where((n) => !n.isDeleted).toList();

    // Build folder → note count map
    final folderCounts = <String?, int>{};
    for (final note in activeNotes) {
      folderCounts[note.folderId] = (folderCounts[note.folderId] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // New folder button
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: InkWell(
            onTap: () => showFolderCreateDialog(context, ref),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.create_new_folder_outlined,
                    size: 18,
                    color: AppColors.sokAccent,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'New Folder',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sokAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // "All" item
        _FolderTile(
          icon: Icons.folder_open_outlined,
          label: 'All',
          count: activeNotes.length,
          depth: 0,
          isSelected: currentFolderId == null,
          onTap: () =>
              ref.read(homeStateProvider.notifier).setCurrentFolder(null),
        ),
        // Folder tree
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _buildFolderTree(
              store: store,
              parentId: null,
              depth: 0,
              currentFolderId: currentFolderId,
              folderCounts: folderCounts,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFolderTree({
    required FolderStore store,
    required String? parentId,
    required int depth,
    required String? currentFolderId,
    required Map<String?, int> folderCounts,
  }) {
    final folders = store.getChildren(parentId);
    final widgets = <Widget>[];

    for (final folder in folders) {
      final children = store.getChildren(folder.id);
      final hasChildren = children.isNotEmpty;
      final isExpanded = _expandedIds.contains(folder.id);

      widgets.add(
        _FolderTile(
          icon: Icons.folder_outlined,
          label: folder.name,
          count: folderCounts[folder.id] ?? 0,
          depth: depth,
          isSelected: currentFolderId == folder.id,
          hasChildren: hasChildren,
          isExpanded: isExpanded,
          onTap: () =>
              ref.read(homeStateProvider.notifier).setCurrentFolder(folder.id),
          onToggleExpand: hasChildren
              ? () {
                  setState(() {
                    if (isExpanded) {
                      _expandedIds.remove(folder.id);
                    } else {
                      _expandedIds.add(folder.id);
                    }
                  });
                }
              : null,
          onLongPress: () => _showFolderOptions(context, ref, folder),
        ),
      );

      // Render children if expanded
      if (hasChildren && isExpanded) {
        widgets.addAll(
          _buildFolderTree(
            store: store,
            parentId: folder.id,
            depth: depth + 1,
            currentFolderId: currentFolderId,
            folderCounts: folderCounts,
          ),
        );
      }
    }

    return widgets;
  }

  void _showFolderOptions(
    BuildContext context,
    WidgetRef ref,
    FolderModel folder,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('New Subfolder'),
              onTap: () {
                Navigator.pop(context);
                showFolderCreateDialog(context, ref, parentId: folder.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renameFolder(context, ref, folder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(folderStoreProvider.notifier).delete(folder.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _renameFolder(BuildContext context, WidgetRef ref, FolderModel folder) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(folderStoreProvider.notifier)
                    .rename(folder.id, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.depth,
    this.onLongPress,
    this.onToggleExpand,
    this.count,
    this.hasChildren = false,
    this.isExpanded = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggleExpand;
  final int? count;
  final int depth;
  final bool hasChildren;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final leftPadding = 12.0 + depth * 20.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Material(
        color: isSelected ? AppColors.sokHover : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.only(
              left: leftPadding,
              right: 12,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              children: [
                // Expand/collapse arrow
                if (hasChildren)
                  GestureDetector(
                    onTap: onToggleExpand,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.chevron_right,
                        size: 18,
                        color: AppColors.sokSecondary,
                      ),
                    ),
                  )
                else if (depth > 0)
                  const SizedBox(width: 22),
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.sokAccent
                      : AppColors.sokSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.sokAccent
                          : AppColors.sokPrimary,
                    ),
                  ),
                ),
                if (count != null)
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? AppColors.sokAccent
                          : AppColors.sokSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
