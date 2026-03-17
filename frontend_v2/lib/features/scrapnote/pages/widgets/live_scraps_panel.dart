import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gma_app/constants/design_tokens.dart';
import '../../models/element_model.dart';
import '../../providers/element_store.dart';

/// Displays the list of ScrapElements for a given PDF file.
///
/// Shows highlight elements as colored text cards and capture elements as
/// image thumbnails. Displays an empty-state placeholder when no scraps exist.
class LiveScrapsPanel extends ConsumerWidget {
  const LiveScrapsPanel({super.key, required this.pdfPath});

  /// The PDF file path used to filter displayed elements.
  final String pdfPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    final allElements = ref.watch(elementStoreNotifierProvider);
    final elements =
        allElements.where((e) => e.pdfPath == pdfPath).toList();

    if (elements.isEmpty) {
      return _EmptyState(colors: colors);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: elements.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final element = elements[index];
        return GestureDetector(
          onTap: () => context.push(
            '/scrapnote?pdfPath=${Uri.encodeComponent(element.pdfPath)}',
          ),
          child: _ScrapItemCard(element: element, colors: colors),
        );
      },
    );
  }
}

/// Card representing a single ScrapElement in the panel list.
class _ScrapItemCard extends StatelessWidget {
  const _ScrapItemCard({
    required this.element,
    required this.colors,
  });

  final ScrapElement element;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypeIcon(element: element, colors: colors),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScrapContent(element: element, colors: colors),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Page ${element.sourcePageNumber}',
                    style: AppTypography.caption1(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the icon for the element type (highlight vs capture).
class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.element, required this.colors});

  final ScrapElement element;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    if (element.type == ScrapElementType.highlight) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Color(element.colorValue),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.text_fields,
          size: 12,
          color: colors.foreground.withValues(alpha: 0.7),
        ),
      );
    }
    return Icon(
      Icons.image_outlined,
      size: 20,
      color: colors.mutedForeground,
    );
  }
}

/// Displays the main content of the scrap element.
class _ScrapContent extends StatelessWidget {
  const _ScrapContent({required this.element, required this.colors});

  final ScrapElement element;
  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    if (element.type == ScrapElementType.highlight) {
      final text = element.selectedText ?? '';
      final snippet =
          text.length > 80 ? '${text.substring(0, 80)}...' : text;
      return Text(
        snippet.isNotEmpty ? snippet : '(empty)',
        style: AppTypography.subheadline(color: colors.foreground),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Capture element: show image thumbnail or placeholder
    final imagePath = element.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(imagePath),
          height: 80,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _ImagePlaceholder(colors: colors),
        ),
      );
    }
    return _ImagePlaceholder(colors: colors);
  }
}

/// Fallback when a capture image cannot be loaded.
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.colors});

  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: colors.mutedForeground,
        ),
      ),
    );
  }
}

/// Empty-state displayed when the current PDF has no scraps.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final AppColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.md,
        children: [
          Icon(
            Icons.bookmark_border,
            size: AppIconSize.xxl,
            color: colors.mutedForeground,
          ),
          Text(
            'No scraps yet',
            style: AppTypography.headline(color: colors.foreground),
          ),
          Text(
            'Highlight text in the PDF to capture it here.',
            style: AppTypography.subheadline(color: colors.mutedForeground),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
