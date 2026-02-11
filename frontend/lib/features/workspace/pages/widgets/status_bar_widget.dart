import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../pdf_viewer/pages/providers/pdf_document_provider.dart';
import '../providers/workspace_provider.dart';

/// Status bar widget showing workspace information at the bottom of the screen.
/// Displays:
/// - Current PDF filename
/// - Page X/Y indicator
/// - Zoom level percentage
/// - Auto-save status
/// - PDF connection indicator
class StatusBarWidget extends ConsumerWidget {
  const StatusBarWidget({
    super.key,
    this.controller,
  });

  /// Optional PDF viewer controller for accessing zoom level.
  /// If not provided, zoom will not be displayed.
  final dynamic controller; // PdfViewerController

  /// Extract filename from full path
  String _extractFilename(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.isEmpty ? path : parts.last;
  }

  /// Format zoom level as percentage
  String _formatZoom(double zoom) {
    return '${(zoom * 100).round()}%';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch workspace state for PDF info
    final workspaceState = ref.watch(workspaceProviderProvider).valueOrNull;
    final pdfDocState = ref.watch(pdfDocumentProvider);

    // Extract status information
    final pdfPath = workspaceState?.currentPdfPath;
    final pdfFilename = pdfPath != null ? _extractFilename(pdfPath) : null;
    final isPdfConnected = pdfPath != null;

    // Get page info from PDF document provider (only when controller is ready)
    final pdfController = pdfDocState.controller;
    final isReady = pdfController != null && pdfController.isReady;
    final currentPage = isReady ? pdfController.pageNumber : null;
    final pageCount = isReady ? pdfController.pageCount : null;

    // Get zoom level from controller if available (only when ready)
    final zoom = isReady ? pdfController.currentZoom : null;

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.background,
        border: Border(
          top: BorderSide(
            color: ShadTheme.of(context).colorScheme.border,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // PDF filename or placeholder
            if (pdfFilename != null) ...[
              Icon(
                Icons.picture_as_pdf,
                size: 14,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                pdfFilename,
                style: ShadTheme.of(context).textTheme.muted.copyWith(
                      fontSize: 12,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ] else ...[
              Text(
                'No PDF loaded',
                style: ShadTheme.of(context).textTheme.muted.copyWith(
                      fontSize: 12,
                    ),
              ),
            ],

            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 16,
              color: ShadTheme.of(context).colorScheme.border,
            ),
            const SizedBox(width: 16),

            // Page indicator
            if (currentPage != null && pageCount != null) ...[
              Icon(
                Icons.description_outlined,
                size: 14,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                'Page $currentPage / $pageCount',
                style: ShadTheme.of(context).textTheme.muted.copyWith(
                      fontSize: 12,
                    ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 16,
                color: ShadTheme.of(context).colorScheme.border,
              ),
              const SizedBox(width: 16),
            ],

            // Zoom indicator
            if (zoom != null) ...[
              Icon(
                Icons.zoom_in,
                size: 14,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                _formatZoom(zoom),
                style: ShadTheme.of(context).textTheme.muted.copyWith(
                      fontSize: 12,
                    ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 16,
                color: ShadTheme.of(context).colorScheme.border,
              ),
              const SizedBox(width: 16),
            ],

            const Spacer(),

            // Auto-save status
            Icon(
              Icons.check_circle_outline,
              size: 14,
              color: ShadTheme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Saved',
              style: ShadTheme.of(context).textTheme.muted.copyWith(
                    fontSize: 12,
                    color: ShadTheme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 16,
              color: ShadTheme.of(context).colorScheme.border,
            ),
            const SizedBox(width: 16),

            // PDF connection indicator
            Icon(
              isPdfConnected ? Icons.link : Icons.link_off,
              size: 14,
              color: isPdfConnected
                  ? ShadTheme.of(context).colorScheme.primary
                  : ShadTheme.of(context).colorScheme.mutedForeground,
            ),
            const SizedBox(width: 6),
            Text(
              isPdfConnected ? 'PDF Connected' : 'No PDF',
              style: ShadTheme.of(context).textTheme.muted.copyWith(
                    fontSize: 12,
                    color: isPdfConnected
                        ? ShadTheme.of(context).colorScheme.primary
                        : ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
