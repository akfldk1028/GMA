import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/frontmatter_model.dart';

/// Widget that displays YAML frontmatter metadata for a note.
///
/// Shows the following fields from Frontmatter model:
/// - file: The note filename
/// - file-path: The full path to the note file
/// - tags: List of tags
/// - created: Creation timestamp
///
/// Handles edge cases:
/// - Null frontmatter: Shows a placeholder message
/// - Empty fields: Displays "N/A" for missing values
///
/// Usage:
/// ```dart
/// FrontmatterHeader(frontmatter: note.frontmatter)
/// ```
class FrontmatterHeader extends StatelessWidget {
  const FrontmatterHeader({
    super.key,
    this.frontmatter,
    this.rawYaml,
    this.showError = false,
  });

  /// The frontmatter data to display. Null when no frontmatter or corrupted.
  final Frontmatter? frontmatter;

  /// Raw YAML string when frontmatter is corrupted. Used to show error state.
  final String? rawYaml;

  /// Whether to show error state for corrupted frontmatter.
  final bool showError;

  @override
  Widget build(BuildContext context) {
    // Handle corrupted frontmatter with error state
    if (showError && rawYaml != null) {
      return ShadCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFFFEF2F2), // Light red background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Corrupted Frontmatter',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to parse YAML frontmatter. Please fix the syntax below:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                rawYaml!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Handle null frontmatter (no frontmatter or corrupted without raw YAML)
    if (frontmatter == null) {
      return const SizedBox.shrink(); // Don't show anything if no frontmatter
    }

    // Display frontmatter fields
    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File name
          _buildField(
            context,
            icon: Icons.description_outlined,
            label: 'File',
            value: frontmatter!.file.isNotEmpty ? frontmatter!.file : 'N/A',
          ),
          const SizedBox(height: 12),

          // File path
          _buildField(
            context,
            icon: Icons.folder_outlined,
            label: 'Path',
            value: frontmatter!.filePath.isNotEmpty
                ? frontmatter!.filePath
                : 'N/A',
          ),
          const SizedBox(height: 12),

          // Tags
          _buildTagsField(context),
          const SizedBox(height: 12),

          // Created date
          _buildField(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Created',
            value: _formatDate(frontmatter!.created),
          ),
        ],
      ),
    );
  }

  /// Builds a single field row with icon, label, and value.
  Widget _buildField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the tags field with tag chips.
  Widget _buildTagsField(BuildContext context) {
    final tags = frontmatter!.tags;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.label_outlined,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tags',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              tags.isEmpty
                  ? Text(
                      'No tags',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.7),
                          ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) => _buildTagChip(context, tag)).toList(),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a single tag chip.
  Widget _buildTagChip(BuildContext context, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  /// Formats a DateTime to a readable string.
  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }
}
