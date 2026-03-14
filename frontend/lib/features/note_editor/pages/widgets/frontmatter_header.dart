import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/frontmatter_model.dart';

/// Widget that displays YAML frontmatter metadata for a note.
class FrontmatterHeader extends StatefulWidget {
  const FrontmatterHeader({
    super.key,
    this.frontmatter,
  });

  final Frontmatter? frontmatter;

  @override
  State<FrontmatterHeader> createState() => _FrontmatterHeaderState();
}

class _FrontmatterHeaderState extends State<FrontmatterHeader> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.frontmatter == null) {
      return const SizedBox.shrink();
    }

    final fm = widget.frontmatter!;
    final theme = ShadTheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with title and expand toggle
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fm.title.isNotEmpty ? fm.title : 'Untitled',
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fm.linkedPdfPath != null) ...[
                    Icon(
                      Icons.link,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded) ...[
            Divider(height: 1, color: theme.colorScheme.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linked PDF
                  if (fm.linkedPdfPath != null) ...[
                    _buildField(
                      context,
                      icon: Icons.picture_as_pdf,
                      label: 'Linked PDF',
                      value: fm.linkedPdfPath!.split(RegExp(r'[/\\]')).last,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Tags
                  if (fm.tags.isNotEmpty) ...[
                    _buildTagsField(context, fm.tags),
                    const SizedBox(height: 8),
                  ],

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          context,
                          icon: Icons.calendar_today_outlined,
                          label: 'Created',
                          value: _formatDate(fm.createdAt),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          context,
                          icon: Icons.update,
                          label: 'Modified',
                          value: _formatDate(fm.modifiedAt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = ShadTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: theme.colorScheme.mutedForeground),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.muted.copyWith(fontSize: 10),
              ),
              Text(
                value,
                style: theme.textTheme.small,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField(BuildContext context, List<String> tags) {
    final theme = ShadTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.label_outlined, size: 12, color: theme.colorScheme.mutedForeground),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.muted.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(date);
  }
}
