import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/folder_store.dart';

Future<void> showFolderCreateDialog(
    BuildContext context, WidgetRef ref, {String? parentId}) async {
  final controller = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(parentId != null ? 'New Subfolder' : 'New Folder'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Folder name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            ref
                .read(folderStoreProvider.notifier)
                .create(name: value.trim(), parentId: parentId);
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              ref
                  .read(folderStoreProvider.notifier)
                  .create(name: controller.text.trim(), parentId: parentId);
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}
