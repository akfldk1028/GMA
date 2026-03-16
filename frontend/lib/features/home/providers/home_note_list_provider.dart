import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../file_manager/models/note_metadata_model.dart';
import '../../file_manager/pages/providers/file_manager_provider.dart';
import 'home_state_provider.dart';

part 'home_note_list_provider.g.dart';

@riverpod
Future<List<NoteMetadata>> allNotes(AllNotesRef ref) async {
  final notes = await ref.watch(fileManagerProvider.future);
  final homeState = ref.watch(homeStateProvider);

  var filtered = notes.where((n) => !n.isDeleted).toList();

  // Search filter
  if (homeState.searchQuery.isNotEmpty) {
    final q = homeState.searchQuery.toLowerCase();
    filtered = filtered
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            (n.previewText?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // Sort
  _sortNotes(filtered, homeState.sortOption);

  // Pin favorites to top
  if (homeState.pinFavoritesToTop) {
    final pinned = filtered.where((n) => n.isPinned).toList();
    final unpinned = filtered.where((n) => !n.isPinned).toList();
    filtered = [...pinned, ...unpinned];
  }

  return filtered;
}

@riverpod
Future<List<NoteMetadata>> trashNotes(TrashNotesRef ref) async {
  final notes = await ref.watch(fileManagerProvider.future);
  return notes.where((n) => n.isDeleted).toList()
    ..sort((a, b) => (b.deletedAt ?? b.modifiedAt).compareTo(
        a.deletedAt ?? a.modifiedAt));
}

@riverpod
Future<List<NoteMetadata>> folderNotes(FolderNotesRef ref) async {
  final notes = await ref.watch(fileManagerProvider.future);
  final homeState = ref.watch(homeStateProvider);
  final folderId = homeState.currentFolderId;

  var filtered = notes.where((n) => !n.isDeleted).toList();
  // If a specific folder is selected, filter by it.
  // "All" (null) shows all non-deleted notes.
  if (folderId != null) {
    filtered = filtered.where((n) => n.folderId == folderId).toList();
  }

  _sortNotes(filtered, homeState.sortOption);

  if (homeState.pinFavoritesToTop) {
    final pinned = filtered.where((n) => n.isPinned).toList();
    final unpinned = filtered.where((n) => !n.isPinned).toList();
    filtered = [...pinned, ...unpinned];
  }

  return filtered;
}

void _sortNotes(List<NoteMetadata> notes, NoteSortOption option) {
  switch (option) {
    case NoteSortOption.createdDesc:
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case NoteSortOption.createdAsc:
      notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    case NoteSortOption.modifiedDesc:
      notes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    case NoteSortOption.modifiedAsc:
      notes.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));
    case NoteSortOption.titleAsc:
      notes.sort((a, b) => a.title.compareTo(b.title));
    case NoteSortOption.titleDesc:
      notes.sort((a, b) => b.title.compareTo(a.title));
  }
}
