import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';
import 'package:gma_app/features/workspace/pages/providers/tab_provider.dart';
import '../providers/pdf_document_provider.dart';

/// Simple provider to track whether we're in asset-demo mode.
final assetPdfModeProvider = StateProvider<bool>((ref) => false);

/// PDF viewer screen that composes pdfrx PdfViewer with drawing overlays.
class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAssetMode = ref.watch(assetPdfModeProvider);
    final docState = ref.watch(pdfDocumentNotifierProvider);
    final theme = ShadTheme.of(context);

    // Asset demo mode — load bundled sample PDF directly
    if (isAssetMode) {
      return PdfViewer.asset(
        'assets/sample.pdf',
        params: const PdfViewerParams(),
      );
    }

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
      return _PdfViewerEmpty(
        theme: theme,
        onOpenPdf: () => _pickAndLoadPdf(ref),
        onLoadSample: () {
          ref.read(assetPdfModeProvider.notifier).state = true;
          ref.read(tabProviderProvider.notifier).addTab('assets/sample.pdf');
        },
      );
    }

    // Loaded state: display PDF with drawing overlays
    final notifier = ref.read(pdfDocumentNotifierProvider.notifier);
    final controller = notifier.controller;

    return PdfViewer.uri(
      Uri.file(''),
      controller: controller,
      params: const PdfViewerParams(),
    );
  }
}

/// Pick a PDF file and load it into the viewer.
Future<void> _pickAndLoadPdf(WidgetRef ref) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );
  if (result == null || result.files.isEmpty) return;

  final path = result.files.single.path;
  if (path == null) return;

  ref.read(tabProviderProvider.notifier).addTab(path);
  await ref.read(pdfDocumentNotifierProvider.notifier).loadDocument(path);
}

/// Empty state placeholder shown when no PDF is loaded.
class _PdfViewerEmpty extends StatelessWidget {
  const _PdfViewerEmpty({
    required this.theme,
    required this.onOpenPdf,
    required this.onLoadSample,
  });

  final ShadThemeData theme;
  final VoidCallback onOpenPdf;
  final VoidCallback onLoadSample;

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
            const SizedBox(height: AppSpacing.base),
            ShadButton(
              onPressed: onLoadSample,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description, size: AppIconSize.sm),
                  SizedBox(width: AppSpacing.xs),
                  Text('Load Sample PDF'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ShadButton.outline(
              onPressed: onOpenPdf,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: AppIconSize.sm),
                  SizedBox(width: AppSpacing.xs),
                  Text('Open PDF File'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
