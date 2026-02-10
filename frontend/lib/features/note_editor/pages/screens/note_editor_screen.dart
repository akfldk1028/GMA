import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Callback for marker click events in the note editor.
/// Called when user taps on a marker line (e.g., "- 🔴 P3 Selected text...").
typedef OnMarkerClickCallback = void Function(String markerId);

/// Markdown editor panel with edit/preview toggle.
/// Supports frontmatter, wiki-links, marker syntax, LaTeX, and auto-save.
class NoteEditorScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text(
        'Note Editor',
        style: ShadTheme.of(context).textTheme.h3,
      ),
    );
  }
}
