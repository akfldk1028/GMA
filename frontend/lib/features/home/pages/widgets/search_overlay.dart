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
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.sokBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.sokDivider, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back, size: 22),
            color: AppColors.sokPrimary,
            tooltip: '검색 닫기',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: '노트 검색...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.sokDisabled),
              ),
              style: const TextStyle(fontSize: 16, color: AppColors.sokPrimary),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.sokSecondary,
              tooltip: '검색어 지우기',
            ),
        ],
      ),
    );
  }
}
