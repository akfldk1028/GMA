import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../workspace/pages/providers/workspace_provider.dart';
import '../models/pdf_structure_model.dart';
import '../providers/pdf_structure_provider.dart';

/// Displays the heading hierarchy of the analyzed PDF as a tree.
///
/// Each heading is indented by level and tappable to jump to the PDF page.
class HeadingTreeWidget extends ConsumerWidget {
  const HeadingTreeWidget({super.key, this.onHeadingTap});

  /// Called when a heading is tapped.
  final void Function(StructureElement heading)? onHeadingTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structureState = ref.watch(pdfStructureProvider);
    final theme = ShadTheme.of(context);

    if (structureState.result == null &&
        !structureState.isAnalyzing &&
        structureState.error == null) {
      final pdfPath = ref
          .read(workspaceProviderProvider)
          .valueOrNull
          ?.currentPdfPath;
      if (pdfPath != null) {
        Future.microtask(() {
          ref.read(pdfStructureProvider.notifier).analyze(pdfPath);
        });
      }
    }

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
              Text('Analyzing structure...', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
    }

    if (!structureState.isAvailable) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Structure analysis is not available for this PDF.',
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      );
    }

    if (structureState.error != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Structure analysis failed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _friendlyError(structureState.error!),
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: theme.colorScheme.mutedForeground,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                final pdfPath = ref
                    .read(workspaceProviderProvider)
                    .valueOrNull
                    ?.currentPdfPath;
                if (pdfPath != null) {
                  ref.read(pdfStructureProvider.notifier).analyze(pdfPath);
                }
              },
              child: const Text('Retry', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    final headings = structureState.result?.headings ?? [];

    if (headings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          structureState.result == null
              ? 'Open a PDF to analyze structure'
              : 'No headings found',
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.mutedForeground,
          ),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
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
                Expanded(
                  child: Text(
                    heading.content ?? '',
                    style: TextStyle(
                      fontSize: level == 1 ? 12 : 11,
                      fontWeight: level <= 2
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: theme.colorScheme.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
        return const Color(0xFF3B82F6);
      case 2:
        return const Color(0xFF8B5CF6);
      case 3:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _friendlyError(String error) {
    if (error.contains('opendataloader-pdf failed')) {
      return 'The primary PDF parser could not read this file, and the fallback parser did not find headings.';
    }
    if (error.contains('not found')) {
      return 'The bundled PDF structure parser is missing from this build.';
    }
    if (error.contains('Java')) {
      return 'Java was not found, and the fallback parser could not detect headings in this PDF.';
    }
    return error;
  }
}
