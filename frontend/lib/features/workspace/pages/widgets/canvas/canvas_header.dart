import 'package:flutter/material.dart';

class CanvasHeader extends StatelessWidget {
  const CanvasHeader({
    super.key,
    required this.totalCount,
    this.onImportPressed,
    required this.onSwapLayout,
    required this.onFoldPanel,
    this.onZoomIn,
    this.onZoomOut,
    this.onZoomReset,
  });

  final int totalCount;
  final VoidCallback? onImportPressed;
  final VoidCallback onSwapLayout;
  final VoidCallback onFoldPanel;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onZoomReset;

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
          if (onZoomOut != null) _iconBtn(Icons.remove, 'Zoom Out', onZoomOut!),
          if (onZoomReset != null)
            GestureDetector(
              onTap: onZoomReset,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                child: Text('fit', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ),
            ),
          if (onZoomIn != null) _iconBtn(Icons.add, 'Zoom In', onZoomIn!),
          const SizedBox(width: 4),
          _iconBtn(Icons.swap_horiz, 'Swap', onSwapLayout),
          _iconBtn(Icons.chevron_right, 'Fold', onFoldPanel),
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
