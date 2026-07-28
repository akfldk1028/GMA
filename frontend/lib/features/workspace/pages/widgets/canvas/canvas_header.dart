import 'package:flutter/material.dart';

import '../../../../../constants/app_colors.dart';

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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.sokSurface,
        border: Border(bottom: BorderSide(color: AppColors.sokDivider)),
      ),
      child: Row(
        children: [
          const Text(
            '스크랩',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.sokPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$totalCount',
            style: TextStyle(
              fontSize: 11,
              color: totalCount > 0
                  ? AppColors.sokAccent
                  : AppColors.sokSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (onZoomOut != null) _iconBtn(Icons.remove, '축소', onZoomOut!),
          if (onZoomReset != null)
            GestureDetector(
              onTap: onZoomReset,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                child: const Text(
                  'fit',
                  style: TextStyle(fontSize: 10, color: AppColors.sokSecondary),
                ),
              ),
            ),
          if (onZoomIn != null) _iconBtn(Icons.add, '확대', onZoomIn!),
          const SizedBox(width: 4),
          _iconBtn(Icons.swap_horiz, '레이아웃 전환', onSwapLayout),
          _iconBtn(Icons.chevron_right, '접기', onFoldPanel),
          if (onImportPressed != null)
            _iconBtn(Icons.add, '가져오기', onImportPressed!),
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
          child: Icon(icon, size: 17, color: AppColors.sokPrimary),
        ),
      ),
    );
  }
}
