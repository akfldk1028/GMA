import 'package:flutter/material.dart';

import '../../../workspace/models/pdf_marker_model.dart';

/// Widget for rendering an individual PDF marker.
///
/// Displays a marker's color, page number, and selected text.
/// Can be tapped to navigate to the marker's location in the PDF.
class MarkerOverlayWidget extends StatelessWidget {
  const MarkerOverlayWidget({
    super.key,
    required this.marker,
    this.onTap,
    this.showFullText = false,
  });

  /// The PDF marker to display.
  final PdfMarker marker;

  /// Callback when the marker is tapped.
  /// Typically used to navigate to the marker's location.
  final VoidCallback? onTap;

  /// Whether to show the full selected text or truncate it.
  final bool showFullText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = marker.selectedText != null && marker.selectedText!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: marker.color.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: marker.color.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Color emoji and page number
            Row(
              children: [
                // Color emoji
                Text(
                  marker.color.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                // Page number
                Text(
                  'P${marker.pageNumber}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: marker.color.color,
                  ),
                ),
                const Spacer(),
                // Navigation icon
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              ],
            ),
            // Selected text
            if (hasText) ...[
              const SizedBox(height: 8),
              Text(
                marker.selectedText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                maxLines: showFullText ? null : 3,
                overflow: showFullText ? null : TextOverflow.ellipsis,
              ),
            ],
            // Image indicator
            if (marker.capturedImagePath != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Has captured image',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact version of MarkerOverlayWidget for use in lists or tight spaces.
class MarkerOverlayCompact extends StatelessWidget {
  const MarkerOverlayCompact({
    super.key,
    required this.marker,
    this.onTap,
  });

  /// The PDF marker to display.
  final PdfMarker marker;

  /// Callback when the marker is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = marker.selectedText != null && marker.selectedText!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: marker.color.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: marker.color.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Color emoji
            Text(
              marker.color.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            // Page number
            Text(
              'P${marker.pageNumber}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: marker.color.color,
              ),
            ),
            if (hasText) ...[
              const SizedBox(width: 8),
              // Truncated text
              Expanded(
                child: Text(
                  marker.selectedText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            // Navigation icon
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
