import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/note_editor_provider.dart';
import '../providers/note_provider.dart';
import '../widgets/frontmatter_header.dart';
import '../widgets/marker_line_widget.dart';

/// Callback for marker click events in the note editor.
typedef OnMarkerClickCallback = void Function(String markerId);

/// Markdown editor panel with toolbar, edit/preview, and auto-save.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.onMarkerClick,
  });

  final String? noteId;
  final OnMarkerClickCallback? onMarkerClick;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String noteId) {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
    // Debounced auto-save (2 seconds)
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _saveNote(noteId);
    });
  }

  Future<void> _saveNote(String noteId) async {
    final controller = ref.read(noteEditorProvider(noteId));
    if (controller == null) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(noteStateProvider(noteId).notifier)
          .updateContent(controller.text);
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Save failed'),
            description: Text(e.toString()),
          ),
        );
      }
    }
  }

  void _insertMarkdown(TextEditingController controller, String prefix, String suffix) {
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid) return;

    final selectedText = text.substring(selection.start, selection.end);
    final newText = '$prefix$selectedText$suffix';

    controller.value = TextEditingValue(
      text: text.replaceRange(selection.start, selection.end, newText),
      selection: TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length,
      ),
    );
  }

  void _insertAtLineStart(TextEditingController controller, String prefix) {
    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isValid) return;

    // Find the start of the current line
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    controller.value = TextEditingValue(
      text: text.replaceRange(lineStart, lineStart, prefix),
      selection: TextSelection.collapsed(
        offset: selection.start + prefix.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // No note selected
    if (widget.noteId == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.colorScheme.border),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note,
                size: 64,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                'Select a note to edit',
                style: theme.textTheme.h4,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a note from the sidebar or create a new one',
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
      );
    }

    final noteState = ref.watch(noteStateProvider(widget.noteId!));
    final controller = ref.watch(noteEditorProvider(widget.noteId!));

    return noteState.when(
      data: (note) {
        if (controller == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: theme.colorScheme.border),
            ),
          ),
          child: Column(
            children: [
              // Editor toolbar
              _buildToolbar(context, theme, controller),

              // Frontmatter (collapsible)
              if (note.frontmatter != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: FrontmatterHeader(frontmatter: note.frontmatter),
                ),

              // Markers section
              if (note.markers.isNotEmpty)
                _buildMarkersSection(theme, note),

              // Main editor
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) => _onTextChanged(widget.noteId!),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      height: 1.6,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.destructive),
            const SizedBox(height: 12),
            Text('Error loading note', style: theme.textTheme.h4),
            const SizedBox(height: 8),
            Text(error.toString(), style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }

  /// Markdown formatting toolbar
  Widget _buildToolbar(BuildContext context, ShadThemeData theme, TextEditingController controller) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Formatting buttons
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Bold (Ctrl+B)',
              onTap: () => _insertMarkdown(controller, '**', '**'),
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italic (Ctrl+I)',
              onTap: () => _insertMarkdown(controller, '_', '_'),
            ),
            _ToolbarButton(
              icon: Icons.strikethrough_s,
              tooltip: 'Strikethrough',
              onTap: () => _insertMarkdown(controller, '~~', '~~'),
            ),
            _toolbarDivider(theme),
            _ToolbarButton(
              icon: Icons.title,
              tooltip: 'Heading',
              onTap: () => _insertAtLineStart(controller, '## '),
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Bullet List',
              onTap: () => _insertAtLineStart(controller, '- '),
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Numbered List',
              onTap: () => _insertAtLineStart(controller, '1. '),
            ),
            _ToolbarButton(
              icon: Icons.check_box_outlined,
              tooltip: 'Task List',
              onTap: () => _insertAtLineStart(controller, '- [ ] '),
            ),
            _toolbarDivider(theme),
            _ToolbarButton(
              icon: Icons.code,
              tooltip: 'Inline Code',
              onTap: () => _insertMarkdown(controller, '`', '`'),
            ),
            _ToolbarButton(
              icon: Icons.data_object,
              tooltip: 'Code Block',
              onTap: () => _insertMarkdown(controller, '```\n', '\n```'),
            ),
            _ToolbarButton(
              icon: Icons.link,
              tooltip: 'Link',
              onTap: () => _insertMarkdown(controller, '[', '](url)'),
            ),
            _ToolbarButton(
              icon: Icons.functions,
              tooltip: 'LaTeX',
              onTap: () => _insertMarkdown(controller, r'$', r'$'),
            ),

            const Spacer(),

            // Save status indicator
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Saving...', style: theme.textTheme.muted.copyWith(fontSize: 11)),
                  ],
                ),
              )
            else if (_hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('Unsaved', style: theme.textTheme.muted.copyWith(fontSize: 11)),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('Saved', style: theme.textTheme.muted.copyWith(fontSize: 11)),
                  ],
                ),
              ),

            // Manual save button
            ShadButton.outline(
              onPressed: () => _saveNote(widget.noteId!),
              size: ShadButtonSize.sm,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_outlined, size: 14),
                  SizedBox(width: 4),
                  Text('Save'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Markers section above the editor
  Widget _buildMarkersSection(ShadThemeData theme, dynamic note) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              'PDF Markers',
              style: theme.textTheme.muted.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 4),
              children: [
                ...note.markers.map<Widget>(
                  (marker) => MarkerLineWidget(
                    color: marker.color,
                    pageNumber: marker.pageNumber,
                    text: marker.selectedText,
                    imagePath: null,
                    onTap: widget.onMarkerClick != null
                        ? () => widget.onMarkerClick!(marker.id)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _toolbarDivider(ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 1,
        height: 20,
        color: theme.colorScheme.border,
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
