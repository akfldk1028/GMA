import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class SearchOverlay extends StatelessWidget {
  const SearchOverlay({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back, size: 22),
            color: AppColors.textSecondary,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.textMuted,
            ),
        ],
      ),
    );
  }
}
