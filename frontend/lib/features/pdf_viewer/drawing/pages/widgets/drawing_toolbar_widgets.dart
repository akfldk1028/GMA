import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../constants/app_colors.dart';

/// Shared toolbar UI primitives used by both DrawingToolbar (PDF) and
/// ScrapnotePanel (sidebar). Extracted to avoid code duplication.

// ─── Standard palettes ─────────────────────────────────────

/// Standard 5-color palette shared across toolbars.
const List<int> kDrawingPaletteColors = [
  0xFF000000, // black
  0xFFEF4444, // red
  0xFF3B82F6, // blue
  0xFF22C55E, // green
  0xFFEAB308, // yellow
];

/// Compact 3-color palette for sidebar context.
const List<int> kCompactPaletteColors = [
  0xFF000000, // black
  0xFF1D4ED8, // blue
  0xFFB45309, // orange
];

/// Standard stroke sizes.
const List<double> kDrawingStrokeSizes = [2.0, 4.0, 8.0];

/// Compact stroke sizes for sidebar.
const List<double> kCompactStrokeSizes = [2.0, 5.0];

// ─── Shared widgets ────────────────────────────────────────

/// Toolbar icon button with active state highlight.
class ToolbarIconButton extends StatelessWidget {
  const ToolbarIconButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.tooltip,
    this.activeColor,
    this.size = 18.0,
    this.padding = 6.0,
    this.compact = false,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? activeColor;
  final double size;
  final double padding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final accent = activeColor ?? theme.colorScheme.primary;
    final iconSize = compact ? size - 4 : size;
    final pad = compact ? padding - 1 : padding;

    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(compact ? 5 : 8),
      child: Container(
        margin: compact ? const EdgeInsets.only(right: 3) : EdgeInsets.zero,
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: isActive
              ? accent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(compact ? 5 : 8),
          border: compact
              ? Border.all(
                  color: isActive
                      ? accent.withValues(alpha: 0.5)
                      : Colors.transparent,
                )
              : null,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isActive
              ? accent
              : compact
                  ? AppColors.textMuted
                  : theme.colorScheme.mutedForeground,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: child);
    }
    return child;
  }
}

/// Color selection dot for drawing palette.
class ToolbarColorDot extends StatelessWidget {
  const ToolbarColorDot({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.dotSize = 22.0,
    this.compact = false,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final double dotSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sz = compact ? 16.0 : dotSize;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sz,
        height: sz,
        margin: EdgeInsets.symmetric(horizontal: compact ? 2 : 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected
                ? compact
                    ? AppColors.primary
                    : Colors.white
                : compact
                    ? AppColors.border
                    : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && !compact
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

/// Stroke size selection dot.
class ToolbarSizeDot extends StatelessWidget {
  const ToolbarSizeDot({
    super.key,
    required this.strokeSize,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final double strokeSize;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (compact) {
      // Compact: labeled button style (S, L)
      final label = strokeSize <= 2.0 ? 'S' : 'L';
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 3),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    // Standard: circle dot style
    return Tooltip(
      message: '${strokeSize.toInt()}px',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          child: Center(
            child: Container(
              width: strokeSize + 2,
              height: strokeSize + 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical divider for toolbar sections.
class ToolbarDivider extends StatelessWidget {
  const ToolbarDivider({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      width: 1,
      height: compact ? 18 : 20,
      color: compact ? AppColors.border : theme.colorScheme.border,
      margin: EdgeInsets.symmetric(horizontal: compact ? 6 : 4),
    );
  }
}
