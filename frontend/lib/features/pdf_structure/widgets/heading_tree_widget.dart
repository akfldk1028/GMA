import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/pdf_structure_model.dart';
import '../providers/pdf_structure_provider.dart';

/// Displays the heading hierarchy of the analyzed PDF as a tree.
///
/// Each heading is indented by level and tappable to jump to the PDF page.
class HeadingTreeWidget extends ConsumerWidget {
  const HeadingTreeWidget({
    super.key,
    this.onHeadingTap,
  });

  /// Called when a heading is tapped: (pageNumber, pdfRect).
  final void Function(StructureElement heading)? onHeadingTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structureState = ref.watch(pdfStructureProvider);
    final theme = ShadTheme.of(context);

    if (structureState.isAnalyzing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(height: 8),
              Text('분석 중...', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
    }

    if (!structureState.isAvailable) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Java 11+ 필요',
          style: TextStyle(fontSize: 11, color: theme.colorScheme.mutedForeground),
        ),
      );
    }

    if (structureState.error != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          structureState.error!,
          style: TextStyle(fontSize: 11, color: theme.colorScheme.destructive),
        ),
      );
    }

    final headings = structureState.result?.headings ?? [];

    if (headings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          structureState.result == null ? 'PDF를 열면 구조 분석' : '헤딩 없음',
          style: TextStyle(fontSize: 11, color: theme.colorScheme.mutedForeground),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: headings.length,
      itemBuilder: (context, index) {
        final heading = headings[index];
        final level = heading.headingLevel ?? 1;
        final indent = (level - 1) * 12.0;

        return InkWell(
          onTap: () => onHeadingTap?.call(heading),
          child: Padding(
            padding: EdgeInsets.only(
              left: 8 + indent,
              right: 8,
              top: 4,
              bottom: 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: _levelColor(level).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'H$level',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _levelColor(level),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Heading text
                Expanded(
                  child: Text(
                    heading.content ?? '',
                    style: TextStyle(
                      fontSize: level == 1 ? 12 : 11,
                      fontWeight: level <= 2 ? FontWeight.w600 : FontWeight.normal,
                      color: theme.colorScheme.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Page number
                Text(
                  'P${heading.pageNumber}',
                  style: TextStyle(
                    fontSize: 9,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _levelColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF3B82F6); // blue
      case 2:
        return const Color(0xFF8B5CF6); // purple
      case 3:
        return const Color(0xFF10B981); // green
      default:
        return const Color(0xFF6B7280); // gray
    }
  }
}
