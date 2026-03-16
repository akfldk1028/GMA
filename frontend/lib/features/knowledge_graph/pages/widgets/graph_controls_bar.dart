import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../providers/knowledge_graph_provider.dart';

/// Bottom-center overlay with filter chips and action buttons.
class GraphControlsBar extends StatelessWidget {
  const GraphControlsBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.onRelayout,
    required this.onResetZoom,
  });

  final GraphFilter currentFilter;
  final ValueChanged<GraphFilter> onFilterChanged;
  final VoidCallback onRelayout;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter chips
          _FilterChip(
            label: 'All',
            isActive: currentFilter == GraphFilter.all,
            onTap: () => onFilterChanged(GraphFilter.all),
          ),
          const SizedBox(width: 4),
          _FilterChip(
            label: 'PDFs',
            color: const Color(0xFF3B82F6),
            isActive: currentFilter == GraphFilter.pdfs,
            onTap: () => onFilterChanged(GraphFilter.pdfs),
          ),
          const SizedBox(width: 4),
          _FilterChip(
            label: 'Notes',
            color: const Color(0xFF10B981),
            isActive: currentFilter == GraphFilter.notes,
            onTap: () => onFilterChanged(GraphFilter.notes),
          ),

          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: 12),

          // Action buttons
          _IconBtn(
            icon: Icons.refresh_rounded,
            tooltip: 'Re-layout',
            onTap: onRelayout,
          ),
          const SizedBox(width: 4),
          _IconBtn(
            icon: Icons.center_focus_strong_rounded,
            tooltip: 'Reset zoom',
            onTap: onResetZoom,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.color,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final Color? color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? (color ?? AppColors.primary).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? (color ?? AppColors.primary).withValues(alpha: 0.4)
                  : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (color != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? (color ?? AppColors.primary)
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

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
