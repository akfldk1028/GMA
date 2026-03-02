import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../scrapnote/models/element_model.dart';

class ScrapCard extends StatefulWidget {
  const ScrapCard({
    required this.element,
    this.onTap,
    this.capturesDir,
    super.key,
  });

  final ScrapElement element;
  final VoidCallback? onTap;
  final String? capturesDir;

  @override
  State<ScrapCard> createState() => _ScrapCardState();
}

class _ScrapCardState extends State<ScrapCard> {
  bool _isHovered = false;

  Color get _accentColor {
    switch (widget.element.type) {
      case ElementType.highlight:
        return AppColors.primary;
      case ElementType.capture:
        return AppColors.success;
      case ElementType.drawing:
        return AppColors.warning;
    }
  }

  IconData get _icon {
    switch (widget.element.type) {
      case ElementType.highlight:
        return Icons.format_quote_rounded;
      case ElementType.capture:
        return Icons.image_rounded;
      case ElementType.drawing:
        return Icons.brush_rounded;
    }
  }

  String get _typeLabel {
    switch (widget.element.type) {
      case ElementType.highlight:
        return 'Highlight';
      case ElementType.capture:
        return 'Capture';
      case ElementType.drawing:
        return 'Drawing';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered
                  ? _accentColor.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
            boxShadow: _isHovered ? AppColors.cardShadowHover : AppColors.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Type header with accent ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _accentColor, width: 3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(_icon, size: 14, color: _accentColor),
                      const SizedBox(width: 6),
                      Text(
                        _typeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _accentColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDim,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'P${widget.element.pageNumber}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content area (expands to fill) ──
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final el = widget.element;

    // Image capture
    if (el.type == ElementType.capture && el.imagePath != null) {
      final imgPath = widget.capturesDir != null
          ? '${widget.capturesDir}/${el.imagePath!}'
          : el.imagePath!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Image.file(
                File(imgPath),
                fit: BoxFit.cover,
                errorBuilder: (_, e, st) => Container(
                  color: AppColors.surfaceDim,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: AppColors.textMuted, size: 28),
                  ),
                ),
              ),
            ),
          ),
          if (el.selectedText != null && el.selectedText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Text(
                el.selectedText!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      );
    }

    // Text content (highlight / drawing / no image capture)
    if (el.selectedText != null && el.selectedText!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
        child: Text(
          el.selectedText!,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // Fallback: empty element
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 24,
            color: _accentColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 6),
          Text(
            '$_typeLabel on page ${el.pageNumber}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
