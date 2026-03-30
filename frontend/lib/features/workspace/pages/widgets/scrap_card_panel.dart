import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../utils/file_system_provider.dart';
import '../../../note_editor/pages/providers/note_editor_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/note_scrap_provider.dart';
import '../../../scrapnote/utils/scrapnote_block_editor.dart';
import '../providers/workspace_provider.dart';

/// Right panel showing ScrapNote scrap cards in a vertical list.
///
/// Data source: `::: scrapnote` block in note markdown (via NoteScrapProvider).
/// The note markdown is the source of truth for which scraps appear here.
class ScrapCardPanel extends ConsumerWidget {
  const ScrapCardPanel({super.key, required this.noteId});

  final String? noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final ws = ref.watch(workspaceProviderProvider).valueOrNull;
    final selectedIds = ws?.selectedScrapIds ?? {};
    final isEditMode = selectedIds.isNotEmpty;

    // Get elements from note markdown via NoteScrapProvider
    final elements = noteId != null
        ? ref.watch(noteScrapProvider(noteId!))
        : <ScrapElement>[];

    // Get captures directory for resolving image paths
    final capturesDir = ref.watch(capturesDirectoryProvider).valueOrNull?.path;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          left: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Column(
        children: [
          // ─── Simple header ───
          _PanelHeader(
            theme: theme,
            scrapCount: elements.length,
          ),

          // ─── Edit mode action bar ───
          if (isEditMode)
            _EditModeBar(
              selectedCount: selectedIds.length,
              onDelete: () async {
                final idsToDelete = selectedIds.toList();
                for (final id in idsToDelete) {
                  // Remove from ElementStore
                  ref.read(elementStoreProvider.notifier).delete(id);
                  // Remove @el line from note markdown
                  if (noteId != null) {
                    final controller =
                        ref.read(noteEditorProvider(noteId!));
                    if (controller != null) {
                      controller.text = ScrapnoteBlockEditor.removeElement(
                        controller.text,
                        id,
                      );
                    }
                  }
                }
                // Persist changes to disk (programmatic controller.text= doesn't auto-save)
                if (noteId != null) {
                  await ref
                      .read(noteEditorProvider(noteId!).notifier)
                      .saveContent(noteId!);
                }
                ref
                    .read(workspaceProviderProvider.notifier)
                    .clearScrapSelection();
              },
              onCancel: () => ref
                  .read(workspaceProviderProvider.notifier)
                  .clearScrapSelection(),
              onSelectAll: () {
                final allIds = elements.map((e) => e.id).toSet();
                ref
                    .read(workspaceProviderProvider.notifier)
                    .setScrapSelection(allIds);
              },
            ),

          // ─── Scrap cards list ───
          Expanded(
            child: elements.isEmpty
                ? _EmptyState(theme: theme)
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: elements.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (noteId == null) return;
                      // Adjust for ReorderableListView behavior
                      if (newIndex > oldIndex) newIndex--;
                      final ids = elements.map((e) => e.id).toList();
                      final movedId = ids.removeAt(oldIndex);
                      ids.insert(newIndex, movedId);
                      // Update note markdown with new order
                      final controller =
                          ref.read(noteEditorProvider(noteId!));
                      if (controller != null) {
                        controller.text =
                            ScrapnoteBlockEditor.reorderElements(
                          controller.text,
                          null,
                          ids,
                        );
                      }
                      // Persist to disk
                      await ref
                          .read(noteEditorProvider(noteId!).notifier)
                          .saveContent(noteId!);
                    },
                    itemBuilder: (context, index) {
                      final element = elements[index];
                      final isSelected = selectedIds.contains(element.id);
                      return _ScrapCard(
                        key: ValueKey(element.id),
                        element: element,
                        index: index + 1,
                        capturesDir: capturesDir,
                        isSelected: isSelected,
                        isEditMode: isEditMode,
                        onLongPress: () {
                          final ids = Set<String>.from(selectedIds)
                            ..add(element.id);
                          ref
                              .read(workspaceProviderProvider.notifier)
                              .setScrapSelection(ids);
                        },
                        onTap: () {
                          ref
                              .read(workspaceProviderProvider.notifier)
                              .toggleScrapSelection(element.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.theme,
    required this.scrapCount,
  });

  final ShadThemeData theme;
  final int scrapCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Scraps',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
          const Spacer(),
          // Scrap count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$scrapCount scraps',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_add_rounded,
            size: 40,
            color: theme.colorScheme.mutedForeground.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'ScrapNote',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Capture or highlight\nto create scraps',
            style: TextStyle(
              fontSize: 11,
              color:
                  theme.colorScheme.mutedForeground.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Edit mode action bar
class _EditModeBar extends StatelessWidget {
  const _EditModeBar({
    required this.selectedCount,
    required this.onDelete,
    required this.onCancel,
    required this.onSelectAll,
  });

  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onCancel;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onCancel,
            child: Icon(Icons.close,
                size: 18, color: theme.colorScheme.foreground),
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCount selected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: onSelectAll,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.select_all,
                  size: 18, color: theme.colorScheme.mutedForeground),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: selectedCount > 0 ? onDelete : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.delete_outline,
                  size: 18,
                  color: selectedCount > 0
                      ? Colors.red
                      : theme.colorScheme.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrapCard extends StatelessWidget {
  const _ScrapCard({
    super.key,
    required this.element,
    required this.index,
    this.capturesDir,
    this.isSelected = false,
    this.isEditMode = false,
    this.onLongPress,
    this.onTap,
  });

  final ScrapElement element;
  final int index;
  final String? capturesDir;
  final bool isSelected;
  final bool isEditMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  /// Resolve image path: if it's just a filename, join with capturesDir
  String? get _resolvedImagePath {
    final img = element.imagePath;
    if (img == null) return null;
    // Already absolute path
    if (p.isAbsolute(img)) return img;
    // Join with capturesDir
    if (capturesDir != null) return p.join(capturesDir!, img);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isHighlight = element.type == ElementType.highlight;
    final isCapture = element.type == ElementType.capture;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : theme.colorScheme.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(7)),
                ),
                child: Row(
                  children: [
                    if (isEditMode) ...[
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(
                      isCapture
                          ? Icons.crop_rounded
                          : isHighlight
                              ? Icons.highlight_rounded
                              : Icons.draw_rounded,
                      size: 13,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#$index  P${element.pageNumber}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                    const Spacer(),
                    if (!isEditMode)
                      Icon(
                        Icons.drag_handle,
                        size: 14,
                        color: theme.colorScheme.mutedForeground,
                      ),
                  ],
                ),
              ),
              // Card body
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image (capture or drawing with image)
                    if (_resolvedImagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(_resolvedImagePath!),
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 80,
                            width: double.infinity,
                            color: theme.colorScheme.muted,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded,
                                  size: 24),
                            ),
                          ),
                        ),
                      ),
                      if (element.selectedText != null &&
                          element.selectedText!.isNotEmpty)
                        const SizedBox(height: 6),
                    ],
                    // Text content (highlight text, context text, etc.)
                    if (element.selectedText != null &&
                        element.selectedText!.isNotEmpty)
                      Text(
                        element.selectedText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.foreground,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    // Fallback for elements with no content
                    if (_resolvedImagePath == null &&
                        (element.selectedText == null ||
                            element.selectedText!.isEmpty))
                      Text(
                        'P${element.pageNumber} ${element.type.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
