import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/scrapnote/models/element_model.dart';
import 'package:gma_app/features/scrapnote/models/highlight_color.dart';
import 'package:gma_app/features/scrapnote/providers/scrap_orchestrator_provider.dart';
import 'package:gma_app/features/workspace/pages/providers/tab_provider.dart';
import '../providers/pdf_document_provider.dart';

/// PDF viewer screen that composes pdfrx PdfViewer with drawing overlays.
///
/// States:
/// - Loading: CircularProgressIndicator
/// - Error: Error message with retry button
/// - Empty (no document): Placeholder UI
/// - Loaded: PdfViewer with drawing overlay and text-selection highlight capture
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

    // Loaded state: display PDF with drawing overlays and text selection
    final notifier = ref.read(pdfDocumentNotifierProvider.notifier);
    final controller = notifier.controller;
    final activeTab = ref.read(tabProviderProvider).activeTab;

    return PdfViewer.uri(
      Uri.file(''), // Placeholder — actual document managed by controller
      controller: controller,
      params: PdfViewerParams(
        textSelectionParams: PdfTextSelectionParams(
          enabled: true,
          onTextSelectionChange: (textSelection) async {
            // Only act when text has been selected
            if (!textSelection.hasSelectedText) return;

            final pdfPath = activeTab?.path;
            if (pdfPath == null) return;

            // Retrieve all selected text ranges (may span multiple pages)
            final ranges = await textSelection.getSelectedTextRanges();
            if (ranges.isEmpty) return;

            // Use the first range as the primary source for the highlight
            final primaryRange = ranges.first;
            final selectedText = ranges
                .map((r) => r.text)
                .join(' ')
                .trim();

            if (selectedText.isEmpty) return;

            // Build a normalized (0-1) ElementRect from the primary range bounds.
            // PdfRect uses PDF coordinates: origin bottom-left, Y grows upward.
            // We convert to top-left origin with 0-1 normalization against page size.
            final bounds = primaryRange.bounds;
            // Page width/height is needed for normalization.
            // Retrieve from the PdfDocument pages list via docState.
            final doc = docState.document;
            final pageIndex = primaryRange.pageNumber - 1;
            ElementRect sourceRect;

            if (doc != null && pageIndex >= 0 && pageIndex < doc.pages.length) {
              final pdfPage = doc.pages[pageIndex];
              final pageWidth = pdfPage.width;
              final pageHeight = pdfPage.height;

              sourceRect = ElementRect(
                left: (bounds.left / pageWidth).clamp(0.0, 1.0),
                // PDF Y origin is bottom-left; convert to top-origin
                top: (1.0 - bounds.top / pageHeight).clamp(0.0, 1.0),
                right: (bounds.right / pageWidth).clamp(0.0, 1.0),
                bottom: (1.0 - bounds.bottom / pageHeight).clamp(0.0, 1.0),
              );
            } else {
              // Fallback: use full-page rect when dimensions unavailable
              sourceRect = const ElementRect(
                left: 0.0,
                top: 0.0,
                right: 1.0,
                bottom: 1.0,
              );
            }

            // Resolve color from session state
            final colorValue = ref.read(lastUsedHighlightColorProvider);

            // Create the highlight element via the orchestrator (no modal dialog)
            await ref.read(scrapOrchestratorProvider.notifier).createHighlight(
                  pdfPath: pdfPath,
                  selectedText: selectedText,
                  pageNumber: primaryRange.pageNumber,
                  sourceRect: sourceRect,
                  colorValue: colorValue,
                );
          },
        ),
      ),
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
