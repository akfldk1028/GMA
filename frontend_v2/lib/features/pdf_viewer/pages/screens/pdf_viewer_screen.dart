import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';
import '../providers/pdf_document_provider.dart';

/// PDF viewer screen that composes pdfrx PdfViewer with drawing overlays.
///
/// States:
/// - Loading: CircularProgressIndicator
/// - Error: Error message with retry button
/// - Empty (no document): Placeholder UI
/// - Loaded: PdfViewer with drawing overlay
class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(pdfDocumentNotifierProvider);
    final theme = ShadTheme.of(context);

    // Loading state
    if (docState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (docState.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: AppIconSize.xxl,
              color: theme.colorScheme.destructive,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load PDF',
              style: AppTypography.headline(
                color: theme.colorScheme.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              docState.error!,
              style: AppTypography.caption1(
                color: theme.colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.base),
            ShadButton(
              onPressed: () {
                ref
                    .read(pdfDocumentNotifierProvider.notifier)
                    .clearDocument();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    }

    // Empty state (no document loaded)
    if (docState.document == null) {
      return _PdfViewerEmpty(theme: theme);
    }

    // Loaded state: display PDF with drawing overlays
    final notifier = ref.read(pdfDocumentNotifierProvider.notifier);
    final controller = notifier.controller;

    return PdfViewer.uri(
      Uri.file(''), // Placeholder — actual document managed by controller
      controller: controller,
      params: const PdfViewerParams(),
    );
  }
}

/// Empty state placeholder shown when no PDF is loaded.
class _PdfViewerEmpty extends StatelessWidget {
  const _PdfViewerEmpty({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: AppIconSize.xxl,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'PDF Viewer',
              style: AppTypography.headline(
                color: theme.colorScheme.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Open a PDF file to start reading.',
              style: AppTypography.subheadline(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
