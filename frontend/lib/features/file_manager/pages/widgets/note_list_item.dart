import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../file_manager/models/note_metadata_model.dart';
import '../providers/file_manager_provider.dart';

/// A list item widget that displays a note's metadata in a card format.
///
/// Displays:
/// - Note title
/// - Modified date (formatted)
/// - Preview text (truncated to 50 characters)
/// - PDF link indicator icon if the note has a linked PDF
///
/// Accepts an [onTap] callback for handling note selection.
/// Long-press to delete the note with confirmation.
class NoteListItem extends ConsumerWidget {
  const NoteListItem({
    required this.note,
    required this.onTap,
    super.key,
  });

  final NoteMetadata note;
  final VoidCallback onTap;

  static final _dateFormatter = DateFormat('MMM d, yyyy • HH:mm');

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final result = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Delete Note'),
        description: Text(
          'Are you sure you want to delete "${note.title}"? This action cannot be undone.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await _handleDelete(context, ref);
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final mutation = ref.read(deleteNoteMutationProvider.notifier);
    try {
      await mutation.call(filePath: note.filePath);
      if (context.mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Success'),
            description: Text('Note deleted successfully.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Delete Failed'),
            description: Text('Failed to delete note: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    // Truncate preview text to 50 characters
    final previewText = note.previewText?.isNotEmpty == true
        ? (note.previewText!.length > 50
            ? '${note.previewText!.substring(0, 50)}...'
            : note.previewText!)
        : 'No preview available';

    return ShadCard(
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showDeleteConfirmation(context, ref),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with PDF indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.large.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.hasLinkedPdf) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.picture_as_pdf,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Modified date
              Text(
                _dateFormatter.format(note.modifiedAt),
                style: theme.textTheme.muted.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              // Preview text
              Text(
                previewText,
                style: theme.textTheme.small,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
