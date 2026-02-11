import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/note_metadata_model.dart';
import '../providers/note_list_provider.dart';
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

    return Container(
      color: theme.colorScheme.background,
      child: notesAsync.when(
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with note count + create button
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    Text(
                      'Notes',
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${notes.length})',
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                    ),
                    const Spacer(),
                    ShadButton.outline(
                      size: ShadButtonSize.sm,
                      onPressed: () => _showCreateNoteDialog(context),
                      child: const Icon(Icons.add, size: 16),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ShadInput(
                  controller: _searchController,
                  placeholder: const Text('Search...'),
                ),
              ),
              if (isSearchActive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ShadButton.outline(
                    size: ShadButtonSize.sm,
                    onPressed: _clearSearch,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 14),
                        SizedBox(width: 4),
                        Text('Clear'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Divider(height: 1, color: theme.colorScheme.border),
              // Note list
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Text(
                          'No notes match your search',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: NoteListItem(
                              note: note,
                              onTap: () => _handleNoteSelected(context, note),
                            ),
                          );
                        },
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
    );
  }
}
