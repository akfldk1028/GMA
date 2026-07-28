import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';

import '../../providers/home_note_list_provider.dart';
import '../../providers/home_state_provider.dart';
import 'note_grid_view.dart';

class NoteListView extends ConsumerWidget {
  const NoteListView({super.key, required this.source});

  final NoteSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = source == NoteSource.all
        ? ref.watch(allNotesProvider)
        : ref.watch(folderNotesProvider);

    return notesAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (notes) {
        if (notes.isEmpty) {
          return const Center(
            child: Text(
              '노트가 없습니다',
              style: TextStyle(color: AppColors.sokSecondary),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          itemCount: notes.length,
          itemBuilder: (context, index) => _NoteListTile(note: notes[index]),
        );
      },
    );
  }
}

class _NoteListTile extends ConsumerWidget {
  const _NoteListTile({required this.note});

  final NoteMetadata note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);
    final isSelected = homeState.selectedNoteIds.contains(note.id);
    final isMultiSelect = homeState.isMultiSelectMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSelected ? AppColors.sokHover : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            if (isMultiSelect) {
              ref.read(homeStateProvider.notifier).toggleNoteSelection(note.id);
              return;
            }
            await ref
                .read(workspaceProviderProvider.notifier)
                .loadNote(note.id);
            if (note.hasLinkedPdf) {
              await ref
                  .read(workspaceProviderProvider.notifier)
                  .loadPdf(note.linkedPdfPath!);
            }
            if (context.mounted) context.go('/workspace');
          },
          onLongPress: () {
            ref.read(homeStateProvider.notifier).toggleNoteSelection(note.id);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (isMultiSelect) ...[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.sokAccent
                          : AppColors.sokSurface,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.sokAccent
                            : AppColors.sokSecondary,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                ],
                // Thumbnail
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    note.hasLinkedPdf
                        ? Icons.picture_as_pdf_outlined
                        : Icons.description_outlined,
                    size: 20,
                    color: AppColors.sokSecondary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.sokPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd').format(note.modifiedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.sokSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (note.isPinned)
                  const Icon(
                    Icons.push_pin,
                    size: 14,
                    color: AppColors.sokAccent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
