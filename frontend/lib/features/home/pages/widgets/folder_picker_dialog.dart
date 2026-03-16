import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../providers/folder_store.dart';

/// Returns folder ID or empty string for root. Returns null if cancelled.
Future<String?> showFolderPickerDialog(
    BuildContext context, WidgetRef ref) async {
  ref.read(folderStoreProvider); // ensure loaded
  final folders = ref.read(folderStoreProvider.notifier).all();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Move to Folder'),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Root (no folder)
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Root (No folder)'),
              onTap: () => Navigator.pop(context, ''),
            ),
            if (folders.isNotEmpty) const Divider(),
            ...folders.map((f) => ListTile(
                  leading: const Icon(Icons.folder_outlined,
                      color: AppColors.primary),
                  title: Text(f.name),
                  onTap: () => Navigator.pop(context, f.id),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
