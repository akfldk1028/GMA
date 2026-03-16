import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_state_provider.g.dart';

enum HomeTab { allNotes, trash, folders }

enum ViewMode { grid, list }

enum NoteSortOption {
  createdDesc,
  createdAsc,
  modifiedDesc,
  modifiedAsc,
  titleAsc,
  titleDesc,
}

@Riverpod(keepAlive: true)
class HomeState extends _$HomeState {
  @override
  HomeStateData build() => const HomeStateData();

  void setTab(HomeTab tab) => state = state.copyWith(activeTab: tab);
  void setViewMode(ViewMode mode) => state = state.copyWith(viewMode: mode);
  void toggleSidebar() =>
      state = state.copyWith(isSidebarExpanded: !state.isSidebarExpanded);
  void setSidebarExpanded(bool expanded) =>
      state = state.copyWith(isSidebarExpanded: expanded);

  void enterMultiSelect() =>
      state = state.copyWith(isMultiSelectMode: true, selectedNoteIds: {});
  void exitMultiSelect() =>
      state = state.copyWith(isMultiSelectMode: false, selectedNoteIds: {});
  void toggleNoteSelection(String noteId) {
    final ids = Set<String>.from(state.selectedNoteIds);
    if (ids.contains(noteId)) {
      ids.remove(noteId);
    } else {
      ids.add(noteId);
    }
    state = state.copyWith(
      selectedNoteIds: ids,
      isMultiSelectMode: ids.isNotEmpty,
    );
  }

  void selectAll(List<String> noteIds) =>
      state = state.copyWith(selectedNoteIds: noteIds.toSet());

  void setCurrentFolder(String? folderId) =>
      state = state.copyWith(
        currentFolderId: folderId,
        clearCurrentFolder: folderId == null,
      );
  void setSortOption(NoteSortOption option) =>
      state = state.copyWith(sortOption: option);
  void togglePinFavoritesToTop() =>
      state = state.copyWith(pinFavoritesToTop: !state.pinFavoritesToTop);
  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
}

class HomeStateData {
  final HomeTab activeTab;
  final ViewMode viewMode;
  final bool isSidebarExpanded;
  final bool isMultiSelectMode;
  final Set<String> selectedNoteIds;
  final String? currentFolderId;
  final NoteSortOption sortOption;
  final bool pinFavoritesToTop;
  final String searchQuery;

  const HomeStateData({
    this.activeTab = HomeTab.allNotes,
    this.viewMode = ViewMode.grid,
    this.isSidebarExpanded = false,
    this.isMultiSelectMode = false,
    this.selectedNoteIds = const {},
    this.currentFolderId,
    this.sortOption = NoteSortOption.createdDesc,
    this.pinFavoritesToTop = true,
    this.searchQuery = '',
  });

  HomeStateData copyWith({
    HomeTab? activeTab,
    ViewMode? viewMode,
    bool? isSidebarExpanded,
    bool? isMultiSelectMode,
    Set<String>? selectedNoteIds,
    String? currentFolderId,
    bool clearCurrentFolder = false,
    NoteSortOption? sortOption,
    bool? pinFavoritesToTop,
    String? searchQuery,
  }) {
    return HomeStateData(
      activeTab: activeTab ?? this.activeTab,
      viewMode: viewMode ?? this.viewMode,
      isSidebarExpanded: isSidebarExpanded ?? this.isSidebarExpanded,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      selectedNoteIds: selectedNoteIds ?? this.selectedNoteIds,
      currentFolderId:
          clearCurrentFolder ? null : (currentFolderId ?? this.currentFolderId),
      sortOption: sortOption ?? this.sortOption,
      pinFavoritesToTop: pinFavoritesToTop ?? this.pinFavoritesToTop,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
