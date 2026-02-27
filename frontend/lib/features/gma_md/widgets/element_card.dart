import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../scrapnote/models/element_model.dart';
import '../../scrapnote/providers/pdf_registry_provider.dart';

/// A compact card widget that displays a ScrapElement.
///
/// Layout:
/// - Left: Icon based on element type (highlight/capture/drawing)
/// - Center: PDF name, page number, selected text preview (max 2 lines)
/// - Right: Optional thumbnail if imagePath is present
class ElementCard extends ConsumerWidget {
  const ElementCard({
    super.key,
    required this.element,
    this.onTap,
  });

  /// The scrap element to display
  final ScrapElement element;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  IconData _getIconForType(ElementType type) {
    switch (type) {
      case ElementType.highlight:
        return Icons.highlight;
      case ElementType.capture:
        return Icons.image;
      case ElementType.drawing:
        return Icons.draw;
    }
  }

  Color _getColorForType(ElementType type) {
    switch (type) {
      case ElementType.highlight:
        return const Color(0xFFF59E0B); // yellow
      case ElementType.capture:
        return const Color(0xFF3B82F6); // blue
      case ElementType.drawing:
        return const Color(0xFF8B5CF6); // purple
    }
  }

  String _getPdfName(String pdfId, WidgetRef ref) {
    final pdfPath = ref.read(pdfRegistryProvProvider.notifier).getPathById(pdfId);
    if (pdfPath == null || pdfPath.isEmpty) {
      return 'Unknown PDF';
    }
    return path.basename(pdfPath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final iconColor = _getColorForType(element.type);
    final hasImage = element.imagePath != null && element.imagePath!.isNotEmpty;
    final hasText = element.selectedText != null && element.selectedText!.isNotEmpty;

    return ShadCard(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(element.type),
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            // Center column: PDF name, page number, text preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PDF name
                  Text(
                    _getPdfName(element.pdfId, ref),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.foreground.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Page number badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'P${element.pageNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ),
                  // Selected text preview
                  if (hasText) ...[
                    const SizedBox(height: 6),
                    Text(
                      element.selectedText!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: theme.colorScheme.foreground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Right thumbnail (if image exists)
            if (hasImage) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.file(
                    File(element.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.muted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.broken_image,
                          color: theme.colorScheme.mutedForeground,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
