import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/note_editor_provider.dart';
import '../providers/note_provider.dart';
import '../widgets/frontmatter_header.dart';
import '../widgets/marker_line_widget.dart';

/// Callback for marker click events in the note editor.
/// Called when user taps on a marker line (e.g., "- 🔴 P3 Selected text...").
typedef OnMarkerClickCallback = void Function(String markerId);

/// Markdown editor panel with edit/preview toggle.
/// Supports frontmatter, wiki-links, marker syntax, LaTeX, and auto-save.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.onMarkerClick,
  });

  final String? noteId;

  /// Callback invoked when a marker is clicked in the note editor.
  /// This will be wired to the workspace provider to navigate the PDF viewer.
  final OnMarkerClickCallback? onMarkerClick;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize state and listeners here
  }

  @override
  void dispose() {
    // Cleanup resources here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle case: no noteId provided
    if (widget.noteId == null) {
      return Center(
        child: Text(
          'Select a note to edit',
          style: ShadTheme.of(context).textTheme.muted,
        ),
      );
    }

    // Watch note state for loading/error handling
    final noteState = ref.watch(noteStateProvider(widget.noteId!));

    // Watch editor provider for TextEditingController
    final controller = ref.watch(noteEditorProvider(widget.noteId!));

    return noteState.when(
      data: (note) {
        // Handle case: controller not yet initialized
        if (controller == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Main editor UI will be built here in subsequent subtasks
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Frontmatter header at the top
            FrontmatterHeader(
              frontmatter: note.frontmatter,
            ),
            const SizedBox(height: 16),

            // Render marker lines if there are any
            if (note.markers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Markers',
                      style: ShadTheme.of(context).textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...note.markers.map(
                      (marker) => MarkerLineWidget(
                        color: marker.color,
                        pageNumber: marker.pageNumber,
                        text: marker.selectedText,
                        imagePath: null, // Image path handling to be implemented
                        onTap: widget.onMarkerClick != null
                            ? () => widget.onMarkerClick!(marker.id)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Multiline TextField for Markdown content editing
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Write your markdown notes here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading note',
              style: ShadTheme.of(context).textTheme.h4,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: ShadTheme.of(context).textTheme.muted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
