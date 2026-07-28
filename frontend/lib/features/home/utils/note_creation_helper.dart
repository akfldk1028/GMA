import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../file_manager/pages/providers/file_manager_provider.dart';
import '../../workspace/pages/providers/workspace_provider.dart';

/// Shows the New Note dialog and, on confirmation, creates a note via the
/// shared mutation and navigates to the workspace.
///
/// Single source of truth used by both the home top bar's "+" button and the
/// empty-state icon in the notes grid. Returns the created note id, or null
/// if the user cancelled or creation failed.
Future<String?> showCreateNoteFlow({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final controller = TextEditingController(
    text: DateFormat('yyyyMMdd_HHmm').format(DateTime.now()),
  );
  final title = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New Note', style: TextStyle(fontSize: 16)),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Note name',
          isDense: true,
        ),
        onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: const Text('Create'),
        ),
      ],
    ),
  );
  if (title == null || title.isEmpty) return null;

  try {
    ref.invalidate(createNoteMutationProvider);
    final mutation = ref.read(createNoteMutationProvider.notifier);
    final note = await mutation.call(title: title);
    if (!context.mounted) return note.id;
    await ref.read(workspaceProviderProvider.notifier).loadNote(note.id);
    if (!context.mounted) return note.id;
    context.go('/workspace');
    return note.id;
  } catch (e) {
    if (context.mounted) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Failed to create note'),
          description: Text('$e'),
        ),
      );
    }
    return null;
  }
}
