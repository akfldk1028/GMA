import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/marker_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../pdf_structure/services/pdf_text_extraction_service.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../workspace/models/workspace_state.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../../capture/pages/providers/capture_provider.dart';
import '../../capture/pages/providers/lasso_provider.dart';
import '../../capture/pages/widgets/capture_overlay.dart';
import '../../capture/pages/widgets/lasso_overlay.dart';
import '../../drawing/pages/providers/drawing_provider.dart';
import '../../drawing/pages/widgets/drawing_overlay.dart';
import '../../drawing/pages/widgets/drawing_toolbar.dart';
import '../providers/pdf_document_provider.dart';
import '../providers/pdf_marker_provider.dart';
import '../widgets/pdf_page_overlay.dart';

/// PDF Viewer panel using pdfrx.
/// Supports text selection, page navigation, marker overlay, and area capture.
class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({
    super.key,
    this.controller,
    this.onAddMarkerPressed,
    this.noteId,
    this.externalToolbar = false,
  });

  /// Controller for programmatic PDF navigation (e.g., goToPage, goToRectInsidePage).
  /// This is used by the workspace to navigate to markers when clicked in the note editor.
  final PdfViewerController? controller;

  /// Callback for the "Add Marker" button (text selection → modal flow).
  final void Function({
    required int pageNumber,
    String? selectedText,
    PdfRect? textRect,
    List<PdfRect>? lineRects,
  })?
  onAddMarkerPressed;

  /// Current note ID for per-note drawing stroke storage.
  final String? noteId;

  /// When true, the drawing toolbar is rendered externally (by workspace header).
  /// The PDF viewer will skip its own internal toolbar.
  final bool externalToolbar;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  // Track controller state to avoid excessive rebuilds from scroll/zoom
  int? _lastPageNumber;
  bool _wasReady = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PdfViewerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// Rebuild only when page number or ready state changes (not on every scroll/zoom).
  void _onControllerChanged() {
    if (!mounted) return;
    final controller = widget.controller;
    if (controller == null) return;

    final isReady = controller.isReady;
    final pageNumber = isReady ? controller.pageNumber : null;

    if (isReady != _wasReady || pageNumber != _lastPageNumber) {
      _wasReady = isReady;
      _lastPageNumber = pageNumber;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(pdfDocumentProvider);
    final controller = widget.controller ?? docState.controller;

    // Watch marker state so PdfViewer rebuilds when markers change.
    // This ensures pagePaintCallbacks gets fresh data after marker creation.
    ref.watch(pdfMarkerStateProvider);

    // Show empty state if no document is loaded
    if (docState.documentRef == null) {
      return _buildEmptyState(context);
    }

    // Mutual exclusion: drawing ON → capture/lasso OFF
    ref.listen(drawingModeProvider, (prev, next) {
      if (next.isActive) {
        ref.read(captureModeProvider.notifier).setActive(false);
        ref.read(lassoModeProvider.notifier).setActive(false);
      }
    });
    ref.listen(captureModeProvider, (prev, next) {
      if (next) {
        ref.read(lassoModeProvider.notifier).setActive(false);
      }
    });
    ref.listen(lassoModeProvider, (prev, next) {
      if (next) {
        ref.read(captureModeProvider.notifier).setActive(false);
        ref.read(drawingModeProvider.notifier).setActive(false);
      }
    });

    // Watch drawing mode, capture mode, lasso mode for conditional text selection
    final drawingMode = ref.watch(drawingModeProvider);
    final captureMode = ref.watch(captureModeProvider);
    final lassoMode = ref.watch(lassoModeProvider);
    final anyOverlayActive = drawingMode.isActive || captureMode || lassoMode;

    return Stack(
      children: [
        // Main PDF viewer
        PdfViewer(
          docState.documentRef!,
          controller: controller!,
          params: PdfViewerParams(
            // Layout depends on workspace view mode setting
            layoutPages: _resolvePageLayout(ref),
            panAxis: PanAxis.vertical,
            scrollByMouseWheel: 0.35,
            scrollHorizontallyByMouseWheel: false,
            scrollByArrowKey: 80,
            scrollPhysics: PdfViewerParams.getScrollPhysics(context),
            // Disable text selection when drawing or capture mode is active
            textSelectionParams: anyOverlayActive
                ? const PdfTextSelectionParams()
                : PdfTextSelectionParams(
                    onTextSelectionChange: _handleTextSelectionChange,
                  ),
            viewerOverlayBuilder: (context, size, handleLinkTap) => [
              PdfViewerScrollThumb(
                controller: controller,
                orientation: ScrollbarOrientation.right,
                margin: 6,
                thumbSize: const Size(28, 48),
                thumbBuilder: (context, thumbSize, pageNumber, controller) {
                  final total = controller.pageCount;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        total > 0 && pageNumber != null ? '$pageNumber' : '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            // Page paint callbacks for markers (repainted when pdfMarkerStateProvider changes)
            pagePaintCallbacks: PdfPageOverlay.createPaintCallbacks(ref),
            // Combined overlays: drawing + capture
            pageOverlaysBuilder: widget.noteId != null
                ? _buildCombinedOverlays(ref)
                : null,
          ),
        ),
        // Drawing toolbar (only if not external — workspace header handles it)
        if (widget.noteId != null && !widget.externalToolbar)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: DrawingToolbar(
                noteId: widget.noteId,
                pageNumber: controller.isReady ? controller.pageNumber : null,
              ),
            ),
          ),
        // All capture/lasso/highlight buttons moved to workspace header
        // Page navigation controls
        _buildNavigationControls(controller),
      ],
    );
  }

  /// Handle text selection changes from PdfViewer.
  Future<void> _handleTextSelectionChange(
    PdfTextSelection textSelection,
  ) async {
    try {
      // Get the selected text ranges
      final selections = await textSelection.getSelectedTextRanges();

      if (selections.isEmpty) return;

      final firstSelection = selections.first;

      // Compute per-line (fragment) rects for precise highlight rendering
      final lineRects = firstSelection
          .enumerateFragmentBoundingRects()
          .map((fb) => fb.bounds)
          .toList();

      // Highlight mode: auto-create highlight on text selection
      final ws = ref.read(workspaceProviderProvider).valueOrNull;
      if (ws?.isHighlightMode == true) {
        final color = MarkerColor.fromName(ws!.highlightModeColorName);
        ref
            .read(workspaceProviderProvider.notifier)
            .createMarker(
              pageNumber: firstSelection.pageNumber,
              color: color,
              selectedText: firstSelection.text,
              textRect: firstSelection.bounds,
              lineRects: lineRects,
            );
        return;
      }

      // Normal mode: forward to workspace via callback
      widget.onAddMarkerPressed?.call(
        pageNumber: firstSelection.pageNumber,
        selectedText: firstSelection.text,
        textRect: firstSelection.bounds,
        lineRects: lineRects,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  /// Build combined page overlays (drawing + capture + lasso).
  PdfPageOverlaysBuilder _buildCombinedOverlays(WidgetRef ref) {
    final drawingBuilder = DrawingOverlay.createOverlaysBuilder(
      noteId: widget.noteId!,
      ref: ref,
    );
    final captureBuilder = CaptureOverlay.createOverlaysBuilder(
      ref: ref,
      onCaptureCompleted: _handleCaptureCompleted,
      noteId: widget.noteId,
    );
    final lassoBuilder = LassoOverlay.createOverlaysBuilder(
      ref: ref,
      onLassoCaptureCompleted: _handleLassoCaptureCompleted,
      noteId: widget.noteId,
    );
    return (BuildContext context, Rect pageRectInViewer, PdfPage page) {
      return [
        ...drawingBuilder(context, pageRectInViewer, page),
        ...captureBuilder(context, pageRectInViewer, page),
        ...lassoBuilder(context, pageRectInViewer, page),
      ];
    };
  }

  /// Handle completed capture — insert image into note with context text.
  /// When OCR is enabled and native text extraction yields nothing,
  /// falls back to local LLM OCR on the captured image.
  ///
  /// Quick scrap mode: skip popup, create instantly.
  /// Normal mode: open ScrapBoard popup via workspace state.
  Future<void> _handleCaptureCompleted({
    required int pageNumber,
    required String filename,
    required Rect normalizedRect,
  }) async {
    try {
      // Extract PDF text at the captured area (via submodule)
      final extractedText = await _extractTextFromRect(
        pageNumber,
        normalizedRect,
      );

      // Convert normalized rect to pdfrx PdfRect for navigation
      final pdfRect = await _normalizedToPdfRect(
        pageNumber,
        normalizedRect.left,
        normalizedRect.top,
        normalizedRect.right,
        normalizedRect.bottom,
      );

      final workspaceState = ref.read(workspaceProviderProvider).valueOrNull;
      final workspaceNotifier = ref.read(workspaceProviderProvider.notifier);

      // Quick scrap mode: skip popup, create instantly
      if (workspaceState?.isQuickScrapMode == true) {
        final selectedColor = MarkerColor.fromName(
          workspaceState!.highlightModeColorName,
        );
        await workspaceNotifier.createMarker(
          pageNumber: pageNumber,
          color: selectedColor,
          capturedImagePath: filename,
          selectedText: extractedText,
          textRect: pdfRect,
        );
        return;
      }

      // Normal mode: open ScrapBoard popup
      final capturesDir = await ref.read(capturesDirectoryProvider.future);
      final fullImagePath = '${capturesDir.path}/$filename';
      workspaceNotifier.openScrapBoard(
        pageNumber: pageNumber,
        selectedText: extractedText,
        imagePath: fullImagePath,
        textRect: pdfRect,
      );
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to insert capture: $e'),
          ),
        );
      }
    }
  }

  /// Handle completed lasso capture — similar to rect capture but with lasso type.
  ///
  /// Quick scrap mode: skip popup, create instantly.
  /// Normal mode: open ScrapBoard popup via workspace state.
  Future<void> _handleLassoCaptureCompleted({
    required int pageNumber,
    required String filename,
    required Rect normalizedRect,
    required List<Offset> lassoPoints,
  }) async {
    try {
      final extractedText = await _extractTextFromRect(
        pageNumber,
        normalizedRect,
      );

      final pdfRect = await _normalizedToPdfRect(
        pageNumber,
        normalizedRect.left,
        normalizedRect.top,
        normalizedRect.right,
        normalizedRect.bottom,
      );

      final workspaceState = ref.read(workspaceProviderProvider).valueOrNull;
      final workspaceNotifier = ref.read(workspaceProviderProvider.notifier);

      // Quick scrap mode: skip popup, create instantly
      if (workspaceState?.isQuickScrapMode == true) {
        final selectedColor = MarkerColor.fromName(
          workspaceState!.highlightModeColorName,
        );
        await workspaceNotifier.createMarker(
          pageNumber: pageNumber,
          color: selectedColor,
          capturedImagePath: filename,
          selectedText: extractedText,
          textRect: pdfRect,
          elementTypeOverride: ElementType.lasso,
        );
        return;
      }

      // Normal mode: open ScrapBoard popup
      final capturesDir = await ref.read(capturesDirectoryProvider.future);
      final fullImagePath = '${capturesDir.path}/$filename';
      workspaceNotifier.openScrapBoard(
        pageNumber: pageNumber,
        selectedText: extractedText,
        imagePath: fullImagePath,
        textRect: pdfRect,
        elementType: ElementType.lasso,
      );
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to insert lasso capture: $e'),
          ),
        );
      }
    }
  }

  /// Extract PDF text from a normalized rect area using submodule.
  Future<String?> _extractTextFromRect(
    int pageNumber,
    Rect normalizedRect,
  ) async {
    final pdfPath = ref
        .read(workspaceProviderProvider)
        .valueOrNull
        ?.currentPdfPath;
    if (pdfPath == null) return null;

    // Convert normalized rect to PdfRect
    final pdfRect = await _normalizedToPdfRect(
      pageNumber,
      normalizedRect.left,
      normalizedRect.top,
      normalizedRect.right,
      normalizedRect.bottom,
    );
    if (pdfRect == null) return null;

    try {
      return await PdfTextExtractionService.extractTextInRect(
        pdfPath,
        pageNumber,
        pdfRect,
      );
    } catch (e) {
      debugPrint('[_extractTextFromRect] submodule failed: $e');
      return null;
    }
  }

  /// Convert normalized [0,1] rect → pdfrx PdfRect (PDF page coordinates).
  Future<PdfRect?> _normalizedToPdfRect(
    int pageNumber,
    double minX,
    double minY,
    double maxX,
    double maxY,
  ) async {
    final docState = ref.read(pdfDocumentProvider);
    final controller = widget.controller ?? docState.controller;
    if (controller == null || !controller.isReady) return null;

    return await controller.useDocument<PdfRect?>((document) async {
      if (pageNumber < 1 || pageNumber > document.pages.length) return null;
      final page = document.pages[pageNumber - 1];

      // PDF coords: origin bottom-left, Y-axis up (top >= bottom)
      final left = minX * page.width;
      final top = (1 - minY) * page.height;
      final right = maxX * page.width;
      final bottom = (1 - maxY) * page.height;

      return PdfRect(left, top, right, bottom);
    });
  }

  /// Build page navigation controls overlay (GoodNotes-style pill bar).
  Widget _buildNavigationControls(PdfViewerController? controller) {
    if (controller == null || !controller.isReady) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);
    final currentPage = controller.pageNumber ?? 1;
    final totalPages = controller.pageCount;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.border),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.foreground.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navButton(
                Icons.chevron_left,
                'Previous',
                currentPage > 1
                    ? () => controller.goToPage(pageNumber: currentPage - 1)
                    : null,
                theme,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$currentPage / $totalPages',
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _navButton(
                Icons.chevron_right,
                'Next',
                currentPage < totalPages
                    ? () => controller.goToPage(pageNumber: currentPage + 1)
                    : null,
                theme,
              ),
              Container(
                width: 1,
                height: 20,
                color: theme.colorScheme.border,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              _navButton(
                Icons.remove,
                'Zoom out',
                () => controller.zoomDown(),
                theme,
              ),
              _navButton(
                Icons.add,
                'Zoom in',
                () => controller.zoomUp(),
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(
    IconData icon,
    String tooltip,
    VoidCallback? onTap,
    ShadThemeData theme,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null
                ? theme.colorScheme.foreground
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }

  /// Load a PDF file from path into workspace (which also loads the document provider).
  Future<void> _loadPdfFromPath(String pdfPath) async {
    final filename = pdfPath.split(RegExp(r'[/\\]')).last;
    try {
      // loadPdf() already calls pdfDocumentProvider.loadFromFile() internally
      await ref.read(workspaceProviderProvider.notifier).loadPdf(pdfPath);

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('PDF Loaded'),
            description: Text('Opened $filename'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Failed to open PDF'),
            description: Text(e.toString()),
          ),
        );
      }
    }
  }

  /// Handle PDF file selection from empty state
  Future<void> _handleOpenPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'Select PDF File',
      );

      if (result != null && result.files.single.path != null) {
        await _loadPdfFromPath(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Failed to open PDF'),
            description: Text(e.toString()),
          ),
        );
      }
    }
  }

  /// Build empty state when no PDF is loaded.
  Widget _buildEmptyState(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      color: theme.colorScheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 56,
              color: theme.colorScheme.mutedForeground.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No PDF loaded',
              style: theme.textTheme.h4.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Open a PDF file to start viewing and annotating',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 20),
            ShadButton.outline(
              onPressed: _handleOpenPdf,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 16),
                  SizedBox(width: 6),
                  Text('Open PDF'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resolve page layout function based on workspace view mode.
  static PdfPageLayoutFunction? _resolvePageLayout(WidgetRef ref) {
    final ws = ref.watch(workspaceProviderProvider).valueOrNull;
    if (ws == null || ws.pdfViewMode == PdfViewMode.continuous) return null;
    return _facingPagesLayout;
  }

  /// Custom 2-page facing layout (book-style).
  /// Page 1 is displayed alone (cover page), then pages are paired: 2-3, 4-5, etc.
  /// Each row is centered horizontally.
  static PdfPageLayout _facingPagesLayout(
    List<PdfPage> pages,
    PdfViewerParams params,
  ) {
    if (pages.isEmpty) {
      return PdfPageLayout(pageLayouts: [], documentSize: Size.zero);
    }

    final m = params.margin;
    final gap = m; // gap between paired pages
    final pageLayouts = <Rect>[];
    double y = m;

    // Max width of a single page (used to compute total document width)
    final maxPageWidth = pages.fold(0.0, (w, p) => max(w, p.width));
    // Document width = two pages side-by-side + margins + gap
    final docWidth = maxPageWidth * 2 + gap + m * 2;

    int i = 0;

    // First page alone (cover) — centered
    if (i < pages.length) {
      final page = pages[i];
      pageLayouts.add(
        Rect.fromLTWH((docWidth - page.width) / 2, y, page.width, page.height),
      );
      y += page.height + m;
      i++;
    }

    // Remaining pages in pairs
    while (i < pages.length) {
      final left = pages[i];
      final hasRight = i + 1 < pages.length;
      final right = hasRight ? pages[i + 1] : null;

      final rowHeight = hasRight
          ? max(left.height, right!.height)
          : left.height;

      // Left page: right-aligned to center gap
      final leftX = docWidth / 2 - gap / 2 - left.width;
      final leftY = y + (rowHeight - left.height) / 2;
      pageLayouts.add(Rect.fromLTWH(leftX, leftY, left.width, left.height));

      if (hasRight) {
        // Right page: left-aligned from center gap
        final rightX = docWidth / 2 + gap / 2;
        final rightY = y + (rowHeight - right!.height) / 2;
        pageLayouts.add(
          Rect.fromLTWH(rightX, rightY, right.width, right.height),
        );
        i += 2;
      } else {
        i += 1;
      }

      y += rowHeight + m;
    }

    return PdfPageLayout(
      pageLayouts: pageLayouts,
      documentSize: Size(docWidth, y),
    );
  }
}
