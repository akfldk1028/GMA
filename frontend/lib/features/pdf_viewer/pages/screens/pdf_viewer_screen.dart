import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../../constants/marker_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../ocr/ocr_service.dart';
import '../../../ocr/pages/providers/ocr_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/models/scrapnote_canvas_model.dart';
import '../../../scrapnote/pages/providers/scrapnote_canvas_provider.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../../../scrapnote/providers/scrap_insertion_provider.dart';
import '../../../scrapnote/services/scrap_insertion_service.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../../capture/pages/providers/capture_provider.dart';
import '../../capture/pages/widgets/capture_overlay.dart';
import '../../drawing/models/drawing_model.dart';
import '../../drawing/pages/providers/drawing_provider.dart';
import '../../drawing/pages/widgets/drawing_overlay.dart';
import '../../utils/pdf_text_extractor.dart';
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
  })? onAddMarkerPressed;

  /// Current note ID for per-note drawing stroke storage.
  final String? noteId;

  /// When true, the drawing toolbar is rendered externally (by workspace header).
  /// The PDF viewer will skip its own internal toolbar.
  final bool externalToolbar;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  // State for text selection
  List<PdfPageTextRange>? _textSelections;
  String? _selectedText;
  int? _selectedPageNumber;
  PdfRect? _selectedTextRect;

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

    // Mutual exclusion: drawing ON → capture OFF
    ref.listen(drawingModeProvider, (prev, next) {
      if (next.isActive) {
        ref.read(captureModeProvider.notifier).setActive(false);
      }
    });

    // Watch drawing mode and capture mode for conditional text selection
    final drawingMode = ref.watch(drawingModeProvider);
    final captureMode = ref.watch(captureModeProvider);
    final anyOverlayActive = drawingMode.isActive || captureMode;

    return Stack(
      children: [
        // Main PDF viewer
        PdfViewer(
          docState.documentRef!,
          controller: controller!,
          params: PdfViewerParams(
            // Facing-page layout: page 1 solo, then 2-3, 4-5, ...
            layoutPages: _facingPagesLayout,
            // Disable text selection when drawing or capture mode is active
            textSelectionParams: anyOverlayActive
                ? const PdfTextSelectionParams()
                : PdfTextSelectionParams(
                    onTextSelectionChange: _handleTextSelectionChange,
                  ),
            // Page paint callbacks for markers (repainted when pdfMarkerStateProvider changes)
            pagePaintCallbacks: PdfPageOverlay.createPaintCallbacks(ref),
            // Combined overlays: drawing + capture
            pageOverlaysBuilder: widget.noteId != null
                ? _buildCombinedOverlays(ref)
                : null,
          ),
        ),
        // Text selection action (appears when text is selected)
        if (_textSelections != null && _textSelections!.isNotEmpty)
          _buildAddMarkerButton(),
        // Drawing toolbar + capture button (top-center) — only if not external
        if (widget.noteId != null && !widget.externalToolbar)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DrawingToolbar(
                    noteId: widget.noteId,
                    pageNumber:
                        controller.isReady ? controller.pageNumber : null,
                  ),
                  const SizedBox(width: 6),
                  _buildCaptureButton(context),
                ],
              ),
            ),
          ),
        // Capture button only (when toolbar is external but capture is still needed)
        if (widget.noteId != null && widget.externalToolbar)
          Positioned(
            top: 8,
            right: 8,
            child: _buildCaptureButton(context),
          ),
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

      setState(() {
        _textSelections = selections;
        if (selections.isEmpty) {
          _selectedText = null;
          _selectedPageNumber = null;
          _selectedTextRect = null;
        } else {
          // Get the first selection (pdfrx supports multi-selection but we use single)
          final firstSelection = selections.first;
          _selectedPageNumber = firstSelection.pageNumber;
          _selectedText = firstSelection.text;
          _selectedTextRect = firstSelection.bounds;
        }
      });
    } catch (e) {
      // Handle error silently or log it
      setState(() {
        _textSelections = null;
        _selectedText = null;
        _selectedPageNumber = null;
        _selectedTextRect = null;
      });
    }
  }

  /// Build text selection action buttons (Add Marker + Add Scrap).
  Widget _buildAddMarkerButton() {
    return Positioned(
      top: 60,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadButton(
            onPressed: () {
              if (_selectedPageNumber == null) return;
              widget.onAddMarkerPressed?.call(
                pageNumber: _selectedPageNumber!,
                selectedText: _selectedText,
                textRect: _selectedTextRect,
              );
              _clearSelection();
            },
            size: ShadButtonSize.sm,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_add, size: 16),
                SizedBox(width: 6),
                Text('Add Marker'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ShadButton.outline(
            onPressed: () => _handleAddScrap(),
            size: ShadButtonSize.sm,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_mosaic_rounded, size: 16),
                SizedBox(width: 6),
                Text('Add Scrap'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _textSelections = null;
      _selectedText = null;
      _selectedPageNumber = null;
      _selectedTextRect = null;
    });
  }

  /// Add selected text as a scrap element to the element store.
  Future<void> _handleAddScrap() async {
    if (_selectedPageNumber == null || _selectedText == null) return;

    final workspaceState =
        ref.read(workspaceProviderProvider).valueOrNull;
    if (workspaceState?.currentPdfPath == null) return;

    final pdfId = ref
        .read(pdfRegistryProvProvider.notifier)
        .getIdByPath(workspaceState!.currentPdfPath!);
    if (pdfId == null) return;

    final element = ScrapElement(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      pdfId: pdfId,
      pageNumber: _selectedPageNumber!,
      type: ElementType.highlight,
      selectedText: _selectedText,
      rect: _selectedTextRect,
      createdAt: DateTime.now(),
    );

    ref.read(elementStoreProvider.notifier).add(element);

    // Also add a CanvasElement to the scrapnote canvas so it appears visually.
    _addElementToCanvas(
      pdfId: pdfId,
      elementId: element.id,
      selectedText: _selectedText,
      pageNumber: _selectedPageNumber!,
      pdfPath: workspaceState.currentPdfPath!,
    );

    _clearSelection();
  }

  /// Adds a [CanvasElement] to the [ScrapnoteCanvasState] for the given [pdfId].
  ///
  /// The element's Y position is calculated by stacking below existing elements
  /// (max(y + height) + 20px gap), so new scraps appear below previous ones.
  void _addElementToCanvas({
    required String pdfId,
    required String elementId,
    required String? selectedText,
    required int pageNumber,
    required String pdfPath,
  }) {
    final canvasState =
        ref.read(scrapnoteCanvasStateProvider(pdfId)).valueOrNull;

    double nextY = 20.0;
    if (canvasState != null && canvasState.elements.isNotEmpty) {
      // Calculate the bottom edge of the lowest existing element
      double maxBottom = 0;
      for (final e in canvasState.elements) {
        final bottom = e.y + e.height;
        if (bottom > maxBottom) maxBottom = bottom;
      }
      nextY = maxBottom + 20.0;
    }

    final canvasElement = CanvasElement(
      id: elementId,
      type: CanvasElementType.highlight,
      x: 20.0,
      y: nextY,
      width: 300.0,
      height: 80.0,
      selectedText: selectedText,
      sourcePageNumber: pageNumber,
      sourcePdfPath: pdfPath,
      createdAt: DateTime.now(),
    );

    ref
        .read(scrapnoteCanvasStateProvider(pdfId).notifier)
        .addElement(canvasElement);
  }


  /// Build combined page overlays (drawing + capture).
  PdfPageOverlaysBuilder _buildCombinedOverlays(WidgetRef ref) {
    final drawingBuilder = DrawingOverlay.createOverlaysBuilder(
      noteId: widget.noteId!,
      ref: ref,
      onStrokeAdded: _handleDrawingStrokeAdded,
    );
    final captureBuilder = CaptureOverlay.createOverlaysBuilder(
      ref: ref,
      onCaptureCompleted: _handleCaptureCompleted,
    );
    return (BuildContext context, Rect pageRectInViewer, PdfPage page) {
      return [
        ...drawingBuilder(context, pageRectInViewer, page),
        ...captureBuilder(context, pageRectInViewer, page),
      ];
    };
  }

  /// Handle completed capture — insert image into note with context text.
  /// When OCR is enabled and native text extraction yields nothing,
  /// falls back to local LLM OCR on the captured image.
  Future<void> _handleCaptureCompleted({
    required int pageNumber,
    required String filename,
    required Rect normalizedRect,
  }) async {
    try {
      // Extract PDF text at the captured area
      var extractedText =
          await _extractTextFromRect(pageNumber, normalizedRect);

      // OCR fallback: if no text was extracted and OCR is enabled
      if ((extractedText == null || extractedText.trim().isEmpty)) {
        final ocrSettings =
            await ref.read(ocrSettingsProvider.future);
        if (ocrSettings.isEnabled) {
          try {
            final capturesDir =
                await ref.read(capturesDirectoryProvider.future);
            final imagePath = '${capturesDir.path}/$filename';
            extractedText = await OcrService.recognizeFile(
              imagePath,
              backendId: ocrSettings.backendId,
              baseUrl: ocrSettings.ollamaUrl,
              model: ocrSettings.modelName,
            );
          } catch (ocrError) {
            // OCR failed — continue with no text (image still gets inserted)
            debugPrint('OCR fallback failed: $ocrError');
          }
        }
      }

      // Convert normalized rect to pdfrx PdfRect for navigation
      final pdfRect = await _normalizedToPdfRect(
        pageNumber,
        normalizedRect.left,
        normalizedRect.top,
        normalizedRect.right,
        normalizedRect.bottom,
      );

      // Build full image path for proposal preview
      final capturesDir = await ref.read(capturesDirectoryProvider.future);
      final fullImagePath = '${capturesDir.path}/$filename';

      // Show confirm popup via ScrapInsertionService
      final workspaceState = ref.read(workspaceProviderProvider).valueOrNull;
      final service = ref.read(scrapInsertionServiceProvider);
      final result = await service.proposeCapture(CaptureProposal(
        imagePath: fullImagePath,
        sourcePageNumber: pageNumber,
        sourcePdfPath: workspaceState?.currentPdfPath ?? '',
      ));

      if (result != InsertionResult.accepted) return;

      // User accepted — create marker and scrap element
      final workspaceNotifier = ref.read(workspaceProviderProvider.notifier);
      await workspaceNotifier.createMarker(
        pageNumber: pageNumber,
        color: MarkerColor.yellow,
        capturedImagePath: filename,
        selectedText: extractedText,
        textRect: pdfRect,
      );

      // Also add as scrap element
      if (workspaceState?.currentPdfPath != null) {
        final pdfId = ref
            .read(pdfRegistryProvProvider.notifier)
            .getIdByPath(workspaceState!.currentPdfPath!);
        if (pdfId != null) {
          ref.read(elementStoreProvider.notifier).add(ScrapElement(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                pdfId: pdfId,
                pageNumber: pageNumber,
                type: ElementType.capture,
                selectedText: extractedText,
                imagePath: filename,
                rect: pdfRect,
                createdAt: DateTime.now(),
              ));
        }
      }
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

  /// Extract PDF text from a normalized rect area (for capture).
  Future<String?> _extractTextFromRect(int pageNumber, Rect normalizedRect) {
    final docState = ref.read(pdfDocumentProvider);
    final controller = widget.controller ?? docState.controller;
    if (controller == null) return Future.value(null);

    return PdfTextExtractor.fromNormalizedRect(
      controller,
      pageNumber,
      minX: normalizedRect.left,
      minY: normalizedRect.top,
      maxX: normalizedRect.right,
      maxY: normalizedRect.bottom,
      margin: 0.0,
    );
  }

  /// Handle drawing stroke added — extract nearby PDF text and insert pen marker.
  Future<void> _handleDrawingStrokeAdded(
    int pageNumber,
    DrawingStroke stroke,
  ) async {
    // Eraser strokes don't need a marker
    if (stroke.toolId == 'eraser') return;

    try {
      // Extract text near the stroke location from the PDF
      final extractedText = await _extractTextNearStroke(pageNumber, stroke);

      // Compute stroke bounding box for navigation
      PdfRect? strokeRect;
      if (stroke.points.length >= 2) {
        double minX = stroke.points[0].x, maxX = stroke.points[0].x;
        double minY = stroke.points[0].y, maxY = stroke.points[0].y;
        for (final pt in stroke.points.skip(1)) {
          if (pt.x < minX) minX = pt.x;
          if (pt.x > maxX) maxX = pt.x;
          if (pt.y < minY) minY = pt.y;
          if (pt.y > maxY) maxY = pt.y;
        }
        strokeRect =
            await _normalizedToPdfRect(pageNumber, minX, minY, maxX, maxY);
      }

      final workspaceNotifier = ref.read(workspaceProviderProvider.notifier);
      await workspaceNotifier.createDrawingMarker(
        pageNumber: pageNumber,
        extractedText: extractedText,
        textRect: strokeRect,
        strokes: [stroke],
      );
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to insert drawing marker: $e'),
          ),
        );
      }
    }
  }

  /// Extract PDF text near a drawing stroke using the shared utility.
  Future<String?> _extractTextNearStroke(
    int pageNumber,
    DrawingStroke stroke,
  ) {
    final docState = ref.read(pdfDocumentProvider);
    final controller = widget.controller ?? docState.controller;
    if (controller == null) return Future.value(null);

    return PdfTextExtractor.fromStroke(controller, pageNumber, stroke);
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

  /// Build the capture toggle button.
  Widget _buildCaptureButton(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isActive = ref.watch(captureModeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Tooltip(
        message: isActive ? 'Exit Capture' : 'Area Capture',
        child: InkWell(
          onTap: () {
            final captureNotifier = ref.read(captureModeProvider.notifier);
            if (!isActive) {
              // Turn off drawing when entering capture mode
              ref.read(drawingModeProvider.notifier).setActive(false);
            }
            captureNotifier.toggle();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.crop,
              size: 18,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      ),
    );
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
              _navButton(Icons.chevron_left, 'Previous',
                  currentPage > 1 ? () => controller.goToPage(pageNumber: currentPage - 1) : null, theme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$currentPage / $totalPages',
                  style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              _navButton(Icons.chevron_right, 'Next',
                  currentPage < totalPages ? () => controller.goToPage(pageNumber: currentPage + 1) : null, theme),
              Container(width: 1, height: 20, color: theme.colorScheme.border, margin: const EdgeInsets.symmetric(horizontal: 4)),
              _navButton(Icons.remove, 'Zoom out', () => controller.zoomDown(), theme),
              _navButton(Icons.add, 'Zoom in', () => controller.zoomUp(), theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, String tooltip, VoidCallback? onTap, ShadThemeData theme) {
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
            color: onTap != null ? theme.colorScheme.foreground : theme.colorScheme.mutedForeground,
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
      pageLayouts.add(Rect.fromLTWH(
        (docWidth - page.width) / 2,
        y,
        page.width,
        page.height,
      ));
      y += page.height + m;
      i++;
    }

    // Remaining pages in pairs
    while (i < pages.length) {
      final left = pages[i];
      final hasRight = i + 1 < pages.length;
      final right = hasRight ? pages[i + 1] : null;

      final rowHeight = hasRight ? max(left.height, right!.height) : left.height;

      // Left page: right-aligned to center gap
      final leftX = docWidth / 2 - gap / 2 - left.width;
      final leftY = y + (rowHeight - left.height) / 2;
      pageLayouts.add(Rect.fromLTWH(leftX, leftY, left.width, left.height));

      if (hasRight) {
        // Right page: left-aligned from center gap
        final rightX = docWidth / 2 + gap / 2;
        final rightY = y + (rowHeight - right!.height) / 2;
        pageLayouts.add(Rect.fromLTWH(rightX, rightY, right.width, right.height));
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
