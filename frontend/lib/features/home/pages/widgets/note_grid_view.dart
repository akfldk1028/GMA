import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../../constants/app_colors.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../providers/home_note_list_provider.dart';
import 'note_card.dart';

enum NoteSource { all, folder }

class NoteGridView extends ConsumerWidget {
  const NoteGridView({super.key, required this.source});

  final NoteSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = source == NoteSource.all
        ? ref.watch(allNotesProvider)
        : ref.watch(folderNotesProvider);

    return notesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary, strokeWidth: 2),
      ),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (notes) {
        if (notes.isEmpty) return _buildEmpty();
        return _buildGrid(context, notes);
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<NoteMetadata> notes) {
    final isMobile = Responsive.isMobile(context);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isMobile ? 140 : 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) =>
          NoteCard(key: ValueKey(notes[index].id), note: notes[index]),
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
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.note_add_outlined,
              size: 28,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create a new note to get started',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
