import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/app_colors.dart';
import '../../../../utils/note_storage_service.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../providers/home_state_provider.dart';
import 'folder_picker_dialog.dart';

class MultiSelectBottomBar extends ConsumerWidget {
  const MultiSelectBottomBar({super.key, required this.activeTab});

  final HomeTab activeTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(
        homeStateProvider.select((s) => s.selectedNoteIds));

    return AnimatedSlide(
      offset: selectedIds.isEmpty ? const Offset(0, 1) : Offset.zero,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel button
              TextButton(
                onPressed: () =>
                    ref.read(homeStateProvider.notifier).exitMultiSelect(),
                child: Text(
                  'Cancel (${selectedIds.length})',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              if (activeTab == HomeTab.trash) ...[
                _BarAction(
                  icon: Icons.restore,
                  label: 'Restore',
                  onTap: () => _restoreSelected(context, ref),
                ),
                _BarAction(
                  icon: Icons.delete_forever,
                  label: 'Delete',
                  color: AppColors.error,
                  onTap: () => _permanentDeleteSelected(context, ref),
                ),
              ] else ...[
                _BarAction(
                  icon: Icons.drive_file_move_outlined,
                  label: 'Move',
                  onTap: () => _moveSelected(context, ref),
                ),
                _BarAction(
                  icon: Icons.lock_outline,
                  label: 'Lock',
                  onTap: () {
                    // TODO: note lock feature
                  },
                ),
                _BarAction(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    // TODO: share feature
                  },
                ),
                _BarAction(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: AppColors.error,
                  onTap: () => _deleteSelected(context, ref),
                ),
                _BarAction(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () => _showMoreActions(context, ref),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSelected(BuildContext context, WidgetRef ref) async {
    final notes = await ref.read(fileManagerProvider.future);
    final selectedIds = ref.read(homeStateProvider).selectedNoteIds;
    for (final id in selectedIds) {
      final note = notes.where((n) => n.id == id).firstOrNull;
      if (note != null) {
        await ref
            .read(deleteNoteMutationProvider.notifier)
            .call(filePath: note.filePath);
      }
    }
    ref.read(homeStateProvider.notifier).exitMultiSelect();
  }

  Future<void> _restoreSelected(BuildContext context, WidgetRef ref) async {
    final notes = await ref.read(fileManagerProvider.future);
    final selectedIds = ref.read(homeStateProvider).selectedNoteIds;
    for (final id in selectedIds) {
      final note = notes.where((n) => n.id == id).firstOrNull;
      if (note != null) {
        await ref
            .read(restoreNoteMutationProvider.notifier)
            .call(filePath: note.filePath);
      }
    }
    ref.read(homeStateProvider.notifier).exitMultiSelect();
  }

  Future<void> _permanentDeleteSelected(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Permanently Delete'),
        description: const Text(
            'This cannot be undone. Are you sure?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final notes = await ref.read(fileManagerProvider.future);
    final selectedIds = ref.read(homeStateProvider).selectedNoteIds;
    for (final id in selectedIds) {
      final note = notes.where((n) => n.id == id).firstOrNull;
      if (note != null) {
        await ref
            .read(permanentDeleteMutationProvider.notifier)
            .call(filePath: note.filePath);
      }
    }
    ref.read(homeStateProvider.notifier).exitMultiSelect();
  }

  Future<void> _moveSelected(BuildContext context, WidgetRef ref) async {
    final folderId = await showFolderPickerDialog(context, ref);
    if (folderId == null) return;

    final notes = await ref.read(fileManagerProvider.future);
    final selectedIds = ref.read(homeStateProvider).selectedNoteIds;
    for (final id in selectedIds) {
      final note = notes.where((n) => n.id == id).firstOrNull;
      if (note != null) {
        await ref
            .read(moveToFolderMutationProvider.notifier)
            .call(
              filePath: note.filePath,
              folderId: folderId.isEmpty ? null : folderId,
            );
      }
    }
    ref.read(homeStateProvider.notifier).exitMultiSelect();
  }

  void _showMoreActions(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.read(homeStateProvider).selectedNoteIds;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedIds.length == 1)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  _renameSelected(context, ref);
                },
              ),
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: const Text('Pin / Unpin'),
              onTap: () {
                Navigator.pop(context);
                _pinSelected(ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameSelected(BuildContext context, WidgetRef ref) async {
    final selectedIds = ref.read(homeStateProvider).selectedNoteIds;
    if (selectedIds.length != 1) return;
    final noteId = selectedIds.first;

    final notes = await ref.read(fileManagerProvider.future);
    final note = notes.where((n) => n.id == noteId).firstOrNull;
    if (note == null) return;

    final controller = TextEditingController(text: note.title);
    if (!context.mounted) return;
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Note', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Note title',
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
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newTitle == null || newTitle.isEmpty || newTitle == note.title) return;

    final noteStorage = ref.read(noteStorageServiceProvider);
    final content = await noteStorage.loadNote(noteId: noteId);
    if (content == null) return;

    final updated = content.replaceFirst(
      RegExp(r'^title:.*$', multiLine: true),
      'title: $newTitle',
    );
    await noteStorage.saveNoteImmediate(noteId: noteId, content: updated);
    ref.read(fileManagerProvider.notifier).refresh();
    ref.read(homeStateProvider.notifier).exitMultiSelect();
  }

  Future<void> _pinSelected(WidgetRef ref) async {
    final notes = await ref.read(fileManagerProvider.future);
    final selectedIds = ref.read(homeStateProvider).selectedNoteIds;
    for (final id in selectedIds) {
      final note = notes.where((n) => n.id == id).firstOrNull;
      if (note != null) {
        await ref
            .read(togglePinMutationProvider.notifier)
            .call(filePath: note.filePath, isPinned: !note.isPinned);
      }
    }
    ref.read(homeStateProvider.notifier).exitMultiSelect();
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: c)),
          ],
        ),
      ),
    );
  }
}
