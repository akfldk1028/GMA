import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../../scrapnote/models/element_model.dart';
import '../providers/scraps_filter_provider.dart';

class ScrapFilterTabs extends ConsumerWidget {
  const ScrapFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(scrapsFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterTab(
            label: 'All',
            isActive: activeFilter == null,
            onTap: () =>
                ref.read(scrapsFilterProvider.notifier).setFilter(null),
          ),
          const SizedBox(width: 8),
          _FilterTab(
            label: 'Highlights',
            icon: Icons.format_quote_rounded,
            isActive: activeFilter == ElementType.highlight,
            onTap: () => ref
                .read(scrapsFilterProvider.notifier)
                .setFilter(ElementType.highlight),
          ),
          const SizedBox(width: 8),
          _FilterTab(
            label: 'Captures',
            icon: Icons.image_rounded,
            isActive: activeFilter == ElementType.capture,
            onTap: () => ref
                .read(scrapsFilterProvider.notifier)
                .setFilter(ElementType.capture),
          ),
          const SizedBox(width: 8),
          _FilterTab(
            label: 'Drawings',
            icon: Icons.brush_rounded,
            isActive: activeFilter == ElementType.drawing,
            onTap: () => ref
                .read(scrapsFilterProvider.notifier)
                .setFilter(ElementType.drawing),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatefulWidget {
  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<_FilterTab> createState() => _FilterTabState();
}

class _FilterTabState extends State<_FilterTab> {
  bool _isHovered = false;

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.isActive ? AppColors.primaryGradient : null,
            color: widget.isActive
                ? null
                : _isHovered
                    ? AppColors.surfaceHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isActive
                  ? Colors.transparent
                  : _isHovered
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.border,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 13,
                  color: widget.isActive ? Colors.white : AppColors.textMuted,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isActive
                      ? Colors.white
                      : _isHovered
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
