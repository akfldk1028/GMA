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
      height: 132,
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
    return SizedBox(
      width: 110,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: isSelected ? AppColors.sokHover : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: AppColors.sokAccent, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_rounded,
                    size: 44,
                    color: isSelected
                        ? AppColors.sokAccent
                        : AppColors.sokSecondary,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.sokAccent
                            : AppColors.sokSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
