import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../../constants/app_colors.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../providers/home_note_list_provider.dart';
import '../../utils/note_creation_helper.dart';
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

    // skipLoadingOnReload + skipLoadingOnRefresh: keep the old grid
    // visible while the provider re-evaluates (e.g., after rename).
    // Without these, every rename briefly flashes the spinner because
    // allNotesProvider awaits fileManagerProvider.future and any
    // upstream state change cycles through AsyncLoading → AsyncData,
    // even when the previous list is still valid.
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
        if (notes.isEmpty) return _buildEmpty(context, ref);
        return _buildGrid(context, notes);
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<NoteMetadata> notes) {
    final isMobile = Responsive.isMobile(context);

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 16 : 24,
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isMobile ? 170 : 210,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) =>
          NoteCard(key: ValueKey(notes[index].id), note: notes[index]),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showCreateNoteFlow(context: context, ref: ref),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.sokHover,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.note_add_outlined,
                  size: 28,
                  color: AppColors.sokAccent.withValues(alpha: 0.72),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 노트가 없습니다',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.sokPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '아이콘을 눌러 첫 노트를 만들어보세요',
            style: TextStyle(fontSize: 13, color: AppColors.sokSecondary),
          ),
        ],
      ),
    );
  }
}
