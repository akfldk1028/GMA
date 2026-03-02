import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';

class RecentScrapsSection extends ConsumerWidget {
  const RecentScrapsSection({super.key});

  Color _accentColor(ElementType type) {
    switch (type) {
      case ElementType.highlight:
        return AppColors.primary;
      case ElementType.capture:
        return AppColors.success;
      case ElementType.drawing:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(elementStoreProvider);
    final elements = ref.read(elementStoreProvider.notifier).all();
    final capturesDir = ref.watch(capturesDirectoryProvider).valueOrNull?.path;

    elements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = elements.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Scraps',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/scraps'),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: recent.isEmpty
              ? Center(
                  child: Text(
                    'No scraps yet. Highlight text in a PDF to create scraps.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final el = recent[index];
                    final color = _accentColor(el.type);
                    return _ScrapPreviewCard(
                      key: ValueKey(el.id),
                      element: el,
                      accentColor: color,
                      capturesDir: capturesDir,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ScrapPreviewCard extends StatefulWidget {
  const _ScrapPreviewCard({
    super.key,
    required this.element,
    required this.accentColor,
    this.capturesDir,
  });

  final ScrapElement element;
  final Color accentColor;
  final String? capturesDir;

  @override
  State<_ScrapPreviewCard> createState() => _ScrapPreviewCardState();
}

class _ScrapPreviewCardState extends State<_ScrapPreviewCard> {
  bool _isHovered = false;

  Widget _buildContent() {
    final el = widget.element;
    if (el.type == ElementType.capture && el.imagePath != null) {
      final imgPath = widget.capturesDir != null
          ? '${widget.capturesDir}/${el.imagePath!}'
          : el.imagePath!;
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(imgPath),
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, e, st) => Center(
            child: Icon(Icons.broken_image_rounded,
                color: AppColors.textMuted, size: 20),
          ),
        ),
      );
    }
    return Text(
      el.selectedText ??
          '${el.type.name} on page ${el.pageNumber}',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 210,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? widget.accentColor.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          boxShadow: _isHovered ? AppColors.cardShadowHover : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.element.type.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: widget.accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  'P${widget.element.pageNumber}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
}
