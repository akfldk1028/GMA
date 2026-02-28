import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/note_metadata_model.dart';
import 'file_manager_provider.dart';

part 'note_list_provider.g.dart';

/// Sort options for note list
enum NoteSortOption {
  modifiedDateDesc,
  modifiedDateAsc,
  titleAsc,
  titleDesc,
  createdDateDesc,
  createdDateAsc,
}

/// State for note list filtering and sorting
class NoteListState {
  const NoteListState({
    this.searchQuery = '',
    this.sortOption = NoteSortOption.modifiedDateDesc,
  });

  final String searchQuery;
  final NoteSortOption sortOption;

  NoteListState copyWith({
    String? searchQuery,
    NoteSortOption? sortOption,
  }) {
    return NoteListState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

/// Provider for managing note list filter state
@riverpod
class NoteListFilter extends _$NoteListFilter {
  @override
  NoteListState build() {
    return const NoteListState();
  }

  /// Update search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update sort option
  void setSortOption(NoteSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  /// Clear search query
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

/// Provider that returns filtered and sorted note list
@riverpod
Future<List<NoteMetadata>> noteList(Ref ref) async {
  // Watch both the file manager and filter state
  final notesAsync = ref.watch(fileManagerProvider);
  final filterState = ref.watch(noteListFilterProvider);

  return notesAsync.when(
    data: (notes) {
      // Create a new list to avoid mutating the original
      List<NoteMetadata> filteredNotes;

      // Apply search filter
      if (filterState.searchQuery.isNotEmpty) {
        final query = filterState.searchQuery.toLowerCase();
        filteredNotes = notes.where((note) {
          // Search in title, preview text, and file path
          final titleMatch = note.title.toLowerCase().contains(query);
          final previewMatch =
              note.previewText?.toLowerCase().contains(query) ?? false;
          final pathMatch = note.filePath.toLowerCase().contains(query);
          return titleMatch || previewMatch || pathMatch;
        }).toList();
      } else {
        // Create a copy of the list to avoid mutation
        filteredNotes = [...notes];
      }

      // Apply sorting
      switch (filterState.sortOption) {
        case NoteSortOption.modifiedDateDesc:
          filteredNotes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        case NoteSortOption.modifiedDateAsc:
          filteredNotes.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));
        case NoteSortOption.titleAsc:
          filteredNotes.sort((a, b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        case NoteSortOption.titleDesc:
          filteredNotes.sort((a, b) =>
              b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        case NoteSortOption.createdDateDesc:
          filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        case NoteSortOption.createdDateAsc:
          filteredNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }

      return filteredNotes;
    },
    loading: () => <NoteMetadata>[],
    error: (_, _) => <NoteMetadata>[],
  );
}

/// Helper provider to check if notes list is loading
@riverpod
bool isNotesLoading(Ref ref) {
  final notesAsync = ref.watch(fileManagerProvider);
  return notesAsync.isLoading;
}

/// Helper provider to get notes count
@riverpod
Future<int> notesCount(Ref ref) async {
  final notes = await ref.watch(noteListProvider.future);
  return notes.length;
}

/// Helper provider to check if search is active
@riverpod
bool isSearchActive(Ref ref) {
  final filterState = ref.watch(noteListFilterProvider);
  return filterState.searchQuery.isNotEmpty;
}
