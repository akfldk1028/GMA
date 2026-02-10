import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Markdown editor panel with edit/preview toggle.
/// Supports frontmatter, wiki-links, marker syntax, LaTeX, and auto-save.
class NoteEditorScreen extends ConsumerWidget {
  const NoteEditorScreen({super.key, this.noteId});

  final String? noteId;

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
