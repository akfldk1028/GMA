import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../models/folder_model.dart';

/// Horizontal scrollable row of large folder icons (file-explorer style).
class FolderChipBar extends StatelessWidget {
  const FolderChipBar({
    super.key,
    required this.folders,
    required this.selectedFolderId,
    required this.onSelected,
    required this.onCreateNew,
  });

  final List<FolderModel> folders;
  final String? selectedFolderId;
  final ValueChanged<String?> onSelected;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          final isSelected = selectedFolderId == folder.id;
          return _FolderTile(
            name: folder.name,
            isSelected: isSelected,
            onTap: () => onSelected(folder.id),
          );
        },
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_rounded,
              size: 64,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.secondary,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
