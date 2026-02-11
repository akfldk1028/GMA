import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../utils/latex_renderer.dart';
import '../../utils/markdown_config.dart';
import '../../utils/markdown_extension.dart';
import '../../utils/marker_line_renderer.dart';
import '../../utils/wiki_link_renderer.dart';
import '../providers/note_editor_provider.dart';
import '../providers/note_provider.dart';
import '../widgets/frontmatter_header.dart';

/// Callback for marker click events in the note editor.
typedef OnMarkerClickCallback = void Function(String markerId);

/// Editor view mode
enum EditorMode { edit, split, preview }

/// Obsidian-style markdown editor with Edit/Split/Preview modes.
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
  EditorMode _mode = EditorMode.split;

  // For live preview updates
  String _previewContent = '';

  // Track the controller we're listening to, so we can remove the listener
  TextEditingController? _listenedController;

  // Cached extensions — rebuilt only when widget.onMarkerClick changes
  late List<MarkdownExtension> _extensions = _buildExtensions();

  List<MarkdownExtension> _buildExtensions() => [
        LatexExtension(),
        MarkerLineExtension(
          onTap: (pageNumber, subNumber, color) {
            widget.onMarkerClick?.call('page:$pageNumber-$subNumber');
          },
        ),
        WikiLinkExtension(
          onTap: (target) {
            // TODO: Navigate to linked note
          },
        ),
      ];

  @override
  void didUpdateWidget(covariant NoteEditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onMarkerClick != widget.onMarkerClick) {
      _extensions = _buildExtensions();
    }
  }

  void _attachControllerListener(TextEditingController controller) {
    if (_listenedController == controller) return;
    _listenedController?.removeListener(_onControllerChanged);
    _listenedController = controller;
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final text = _listenedController?.text ?? '';
    if (text != _previewContent) {
      setState(() => _previewContent = text);
    }
  }

  @override
  void dispose() {
    _listenedController?.removeListener(_onControllerChanged);
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
        color: theme.colorScheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note,
                size: 56,
                color: theme.colorScheme.mutedForeground.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a note to edit',
                style: theme.textTheme.h4.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Open a PDF or choose a note from the sidebar',
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

        // Attach listener for real-time preview updates (including programmatic changes)
        _attachControllerListener(controller);

        // Initialize preview content from controller
        if (_previewContent.isEmpty && controller.text.isNotEmpty) {
          _previewContent = controller.text;
        }

        return Container(
          color: theme.colorScheme.background,
          child: Column(
            children: [
              // Toolbar
              _buildToolbar(context, theme, controller),

              // Frontmatter header (collapsible)
              if (note.frontmatter != null)
                FrontmatterHeader(frontmatter: note.frontmatter),

              // Main editor area
              Expanded(
                child: _buildEditorArea(context, theme, controller, note),
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

  /// Build the main editor area based on current mode
  Widget _buildEditorArea(
    BuildContext context,
    ShadThemeData theme,
    TextEditingController controller,
    dynamic note,
  ) {
    switch (_mode) {
      case EditorMode.edit:
        return _buildEditPanel(theme, controller);
      case EditorMode.preview:
        return _buildPreviewPanel(theme);
      case EditorMode.split:
        return Row(
          children: [
            // Edit panel
            Expanded(child: _buildEditPanel(theme, controller)),
            // Divider
            Container(
              width: 1,
              color: theme.colorScheme.border,
            ),
            // Preview panel
            Expanded(child: _buildPreviewPanel(theme)),
          ],
        );
    }
  }

  /// Raw markdown edit panel
  Widget _buildEditPanel(ShadThemeData theme, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (_) => _onTextChanged(widget.noteId!),
        decoration: InputDecoration(
          hintText: 'Start writing markdown...',
          hintStyle: TextStyle(
            color: theme.colorScheme.mutedForeground.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.7,
          color: theme.colorScheme.foreground,
        ),
      ),
    );
  }

  /// Rendered markdown preview panel
  Widget _buildPreviewPanel(ShadThemeData theme) {
    final config = buildMarkdownConfig(context, extensions: _extensions);
    final generator = buildMarkdownGenerator(extensions: _extensions);

    return Container(
      padding: const EdgeInsets.all(12),
      child: _previewContent.isEmpty
          ? Center(
              child: Text(
                'Preview will appear here',
                style: theme.textTheme.muted,
              ),
            )
          : MarkdownWidget(
              data: _previewContent,
              shrinkWrap: false,
              selectable: true,
              config: config,
              markdownGenerator: generator,
            ),
    );
  }

  /// Toolbar with formatting buttons and mode toggle
  Widget _buildToolbar(
    BuildContext context,
    ShadThemeData theme,
    TextEditingController controller,
  ) {
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
            // Formatting buttons (only in edit/split mode)
            if (_mode != EditorMode.preview) ...[
              _ToolbarButton(
                icon: Icons.format_bold,
                tooltip: 'Bold',
                onTap: () => _insertMarkdown(controller, '**', '**'),
              ),
              _ToolbarButton(
                icon: Icons.format_italic,
                tooltip: 'Italic',
                onTap: () => _insertMarkdown(controller, '_', '_'),
              ),
              _ToolbarButton(
                icon: Icons.strikethrough_s,
                tooltip: 'Strikethrough',
                onTap: () => _insertMarkdown(controller, '~~', '~~'),
              ),
              _divider(theme),
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
                icon: Icons.check_box_outlined,
                tooltip: 'Task',
                onTap: () => _insertAtLineStart(controller, '- [ ] '),
              ),
              _divider(theme),
              _ToolbarButton(
                icon: Icons.code,
                tooltip: 'Code',
                onTap: () => _insertMarkdown(controller, '`', '`'),
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
            ],

            const Spacer(),

            // Mode toggle (segmented button)
            _buildModeToggle(theme),

            const SizedBox(width: 8),

            // Save status
            _buildSaveStatus(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle(ShadThemeData theme) {
    Widget modeButton(EditorMode mode, IconData icon, String tooltip) {
      final isActive = _mode == mode;
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => setState(() => _mode = mode),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 14,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          modeButton(EditorMode.edit, Icons.edit_outlined, 'Edit'),
          modeButton(EditorMode.split, Icons.vertical_split, 'Split'),
          modeButton(EditorMode.preview, Icons.visibility_outlined, 'Preview'),
        ],
      ),
    );
  }

  Widget _buildSaveStatus(ShadThemeData theme) {
    if (_isSaving) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(width: 4),
          Text('Saving', style: theme.textTheme.muted.copyWith(fontSize: 10)),
        ],
      );
    } else if (_hasUnsavedChanges) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text('Unsaved', style: theme.textTheme.muted.copyWith(fontSize: 10)),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: 4),
          Text('Saved', style: theme.textTheme.muted.copyWith(fontSize: 10)),
        ],
      );
    }
  }

  static Widget _divider(ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(width: 1, height: 18, color: theme.colorScheme.border),
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
          padding: const EdgeInsets.all(5),
          child: Icon(
            icon,
            size: 15,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
