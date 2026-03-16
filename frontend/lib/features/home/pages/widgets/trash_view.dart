import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../providers/home_note_list_provider.dart';
import '../../providers/home_state_provider.dart';

class TrashView extends ConsumerWidget {
  const TrashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashAsync = ref.watch(trashNotesProvider);
    final homeState = ref.watch(homeStateProvider);

    return trashAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary, strokeWidth: 2),
      ),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (notes) {
        if (notes.isEmpty) return _buildEmpty();

        if (homeState.viewMode == ViewMode.grid) {
          return _buildGrid(context, ref, notes);
        }
        return _buildList(context, ref, notes);
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.delete_outline,
                size: 28,
                color: AppColors.textMuted.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Trash is empty',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Deleted notes will appear here',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
      BuildContext context, WidgetRef ref, List<NoteMetadata> notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) =>
          _TrashCard(note: notes[index]),
    );
  }

  Widget _buildList(
      BuildContext context, WidgetRef ref, List<NoteMetadata> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) =>
          _TrashListTile(note: notes[index]),
    );
  }
}

class _TrashCard extends ConsumerWidget {
  const _TrashCard({required this.note});

  final NoteMetadata note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);
    final isSelected = homeState.selectedNoteIds.contains(note.id);

    return GestureDetector(
      onTap: () {
        if (homeState.isMultiSelectMode) {
          ref.read(homeStateProvider.notifier).toggleNoteSelection(note.id);
        }
      },
      onLongPress: () =>
          ref.read(homeStateProvider.notifier).toggleNoteSelection(note.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDim.withValues(alpha: 0.7),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(Icons.description_outlined,
                          size: 28,
                          color: AppColors.textMuted.withValues(alpha: 0.3)),
                    ),
                  ),
                  if (homeState.isMultiSelectMode)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (note.deletedAt != null)
                    Text(
                      'Deleted ${DateFormat('M/d').format(note.deletedAt!)}',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrashListTile extends ConsumerWidget {
  const _TrashListTile({required this.note});

  final NoteMetadata note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.description_outlined,
            size: 18, color: AppColors.textMuted),
      ),
      title: Text(note.title,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textSecondary)),
      subtitle: note.deletedAt != null
          ? Text('Deleted ${DateFormat('M/d').format(note.deletedAt!)}',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textMuted))
          : null,
      onTap: () {
        ref.read(homeStateProvider.notifier).toggleNoteSelection(note.id);
      },
      onLongPress: () {
        ref.read(homeStateProvider.notifier).toggleNoteSelection(note.id);
      },
    );
  }
}
