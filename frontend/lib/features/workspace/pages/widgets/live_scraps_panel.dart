import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../providers/workspace_provider.dart';

class LiveScrapsPanel extends ConsumerWidget {
  const LiveScrapsPanel({
    this.onElementTap,
    this.isSheet = false,
    super.key,
  });

  final void Function(ScrapElement element)? onElementTap;
  final bool isSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceState = ref.watch(workspaceProviderProvider).valueOrNull;
    ref.watch(elementStoreProvider);

    final capturesDir = ref.watch(capturesDirectoryProvider).valueOrNull?.path;

    List<ScrapElement> elements = [];
    if (workspaceState?.currentPdfPath != null) {
      final pdfId = ref
          .read(pdfRegistryProvProvider.notifier)
          .getIdByPath(workspaceState!.currentPdfPath!);
      if (pdfId != null) {
        elements = ref.read(elementStoreProvider.notifier).getByPdfId(pdfId);
      }
    }

    if (isSheet) return _buildSheetLayout(elements, capturesDir);
    return _buildSidebarLayout(elements, capturesDir);
  }

  Widget _buildSidebarLayout(
      List<ScrapElement> elements, String? capturesDir) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(elements.length),
          Expanded(child: _buildList(elements, capturesDir)),
        ],
      ),
    );
  }

  Widget _buildSheetLayout(
      List<ScrapElement> elements, String? capturesDir) {
    return Column(
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        _buildHeader(elements.length),
        Expanded(child: _buildList(elements, capturesDir)),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'LIVE SCRAPS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<ScrapElement> elements, String? capturesDir) {
    if (elements.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_mosaic_rounded,
                size: 32,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 8),
              Text(
                'No scraps yet',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Highlight text in the PDF to create scraps',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final el = elements[index];
        return _ElementCard(
          key: ValueKey(el.id),
          element: el,
          capturesDir: capturesDir,
          onTap: () => onElementTap?.call(el),
        );
      },
    );
  }
}

class _ElementCard extends StatelessWidget {
  const _ElementCard({
    super.key,
    required this.element,
    this.capturesDir,
    this.onTap,
  });

  final ScrapElement element;
  final String? capturesDir;
  final VoidCallback? onTap;

  Color get _accentColor {
    switch (element.type) {
      case ElementType.highlight:
        return AppColors.primary;
      case ElementType.capture:
        return AppColors.success;
      case ElementType.drawing:
        return AppColors.warning;
    }
  }

  IconData get _icon {
    switch (element.type) {
      case ElementType.highlight:
        return Icons.format_quote_rounded;
      case ElementType.capture:
        return Icons.image_rounded;
      case ElementType.drawing:
        return Icons.brush_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(_icon, size: 12, color: _accentColor),
                    const SizedBox(width: 4),
                    Text(
                      element.type.name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _accentColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'P${element.pageNumber}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                if (element.type == ElementType.capture &&
                    element.imagePath != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: kIsWeb
                          ? Container(
                              color: AppColors.surfaceDim,
                              child: const Center(
                                child: Icon(Icons.image_rounded,
                                    color: AppColors.textMuted, size: 20),
                              ),
                            )
                          : Image.network(
                              capturesDir != null
                                  ? '$capturesDir/${element.imagePath!}'
                                  : element.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, st) => Container(
                                color: AppColors.surfaceDim,
                                child: const Center(
                                  child: Icon(Icons.broken_image_rounded,
                                      color: AppColors.textMuted, size: 20),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
                if (element.selectedText != null &&
                    element.selectedText!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    element.selectedText!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
