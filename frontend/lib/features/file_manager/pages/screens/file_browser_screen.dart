import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/note_metadata_model.dart';
import '../providers/note_list_provider.dart';
import '../widgets/file_tree_widget.dart';
import '../widgets/note_create_dialog.dart';
import '../widgets/note_list_item.dart';

/// File browser sidebar showing note folders and files.
///
/// Displays:
/// - File tree view on the left showing directory structure
/// - Note list view on the right showing note cards
/// - Search bar to filter notes
/// - Floating action button to create new notes
/// - Loading and error states
class FileBrowserScreen extends ConsumerStatefulWidget {
  const FileBrowserScreen({
    this.onNoteSelected,
    super.key,
  });

  /// Callback triggered when a note is selected.
  /// If not provided, will navigate to note editor by default.
  final void Function(NoteMetadata note)? onNoteSelected;

  @override
  ConsumerState<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends ConsumerState<FileBrowserScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer for debouncing (300ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(noteListFilterProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(noteListFilterProvider.notifier).clearSearch();
  }

  void _handleNoteSelected(BuildContext context, NoteMetadata note) {
    if (widget.onNoteSelected != null) {
      widget.onNoteSelected!(note);
    } else {
      // Default behavior: navigate to note editor
      context.push('/note/${note.id}');
    }
  }

  Future<void> _showCreateNoteDialog(BuildContext context) async {
    await showShadDialog(
      context: context,
      builder: (context) => const NoteCreateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(noteListProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes found',
                    style: theme.textTheme.large,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first note to get started',
                    style: theme.textTheme.muted,
                  ),
                  const SizedBox(height: 24),
                  ShadButton(
                    onPressed: () => _showCreateNoteDialog(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 8),
                        Text('Create Note'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              // Left panel: File tree
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.border,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Files',
                          style: theme.textTheme.large.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: FileTreeWidget(
                          notes: notes,
                          onNoteSelected: (note) => _handleNoteSelected(context, note),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right panel: Note list with search
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with note count
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notes',
                            style: theme.textTheme.large.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${notes.length} ${notes.length == 1 ? 'note' : 'notes'}',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ShadInput(
                              controller: _searchController,
                              placeholder: const Text('Search notes...'),
                            ),
                          ),
                          if (isSearchActive) ...[
                            const SizedBox(width: 8),
                            ShadButton.outline(
                              size: ShadButtonSize.sm,
                              onPressed: _clearSearch,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close, size: 16),
                                  SizedBox(width: 4),
                                  Text('Clear'),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    // Note list
                    Expanded(
                      child: notes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No notes match your search',
                                    style: theme.textTheme.muted,
                                  ),
                                  const SizedBox(height: 8),
                                  ShadButton.outline(
                                    size: ShadButtonSize.sm,
                                    onPressed: _clearSearch,
                                    child: const Text('Clear search'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: notes.length,
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: NoteListItem(
                                    note: note,
                                    onTap: () =>
                                        _handleNoteSelected(context, note),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading notes...',
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.destructive,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading notes',
                style: theme.textTheme.large.copyWith(
                  color: theme.colorScheme.destructive,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.muted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNoteDialog(context),
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
