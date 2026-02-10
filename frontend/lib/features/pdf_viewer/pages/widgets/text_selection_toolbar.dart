import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gma_frontend/constants/marker_colors.dart';

/// A toolbar that appears when text is selected in the PDF viewer,
/// allowing the user to choose a marker color for annotation.
///
/// Displays all 5 marker colors (🔴🟡🟢🔵🟣) as selectable buttons.
///
/// Example:
/// ```dart
/// PdfTextSelectionToolbar(
///   onColorSelected: (color) {
///     // Create marker with selected color
///     print('Selected color: ${color.emoji}');
///   },
/// )
/// ```
class PdfTextSelectionToolbar extends StatelessWidget {
  const PdfTextSelectionToolbar({
    super.key,
    required this.onColorSelected,
    this.selectedText,
  });

  /// Callback when a marker color is selected.
  final void Function(MarkerColor color) onColorSelected;

  /// Optional selected text to display (for preview/context).
  final String? selectedText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Optional text preview
            if (selectedText != null && selectedText!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  selectedText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
            ],
            // Color buttons row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: MarkerColor.values.map((color) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _PdfColorButton(
                    color: color,
                    onTap: () => onColorSelected(color),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual color button in the toolbar.
class _PdfColorButton extends StatelessWidget {
  const _PdfColorButton({
    required this.color,
    required this.onTap,
  });

  final MarkerColor color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            color.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
