import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    return Center(
      child: Text(
        'Note Editor',
        style: ShadTheme.of(context).textTheme.h3,
      ),
    );
  }
}
