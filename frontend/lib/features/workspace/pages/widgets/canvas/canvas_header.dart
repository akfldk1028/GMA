import 'package:flutter/material.dart';

class CanvasHeader extends StatelessWidget {
  const CanvasHeader({
    super.key,
    required this.totalCount,
    required this.annotateMode,
    required this.onAnnotateToggled,
    this.onImportPressed,
    required this.onSwapLayout,
    required this.onFoldPanel,
  });

  final int totalCount;
  final bool annotateMode;
  final VoidCallback onAnnotateToggled;
  final VoidCallback? onImportPressed;
  final VoidCallback onSwapLayout;
  final VoidCallback onFoldPanel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Text('Scraps',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(width: 6),
          Text('$totalCount',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          _iconBtn(Icons.swap_horiz, 'Swap', onSwapLayout),
          _iconBtn(Icons.chevron_right, 'Fold', onFoldPanel),
          GestureDetector(
            onTap: onAnnotateToggled,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: annotateMode
                    ? Colors.blue.shade50
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.edit, size: 14,
                  color: annotateMode
                      ? Colors.blue.shade700
                      : Colors.grey.shade400),
            ),
          ),
          if (onImportPressed != null)
            _iconBtn(Icons.add, 'Import', onImportPressed!),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tip, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Icon(icon, size: 14, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
