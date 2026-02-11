import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/marker_colors.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../../capture/pages/providers/capture_provider.dart';
import '../../capture/pages/widgets/capture_overlay.dart';
import '../../drawing/models/drawing_model.dart';
import '../../drawing/pages/providers/drawing_provider.dart';
import '../../drawing/pages/widgets/drawing_overlay.dart';
import '../../utils/pdf_text_extractor.dart';
import '../../drawing/pages/widgets/drawing_toolbar.dart';
import '../../models/pdf_marker_model.dart' as local_model;
import '../providers/pdf_document_provider.dart';
import '../providers/pdf_marker_provider.dart';
import '../widgets/pdf_page_overlay.dart';
import '../widgets/text_selection_toolbar.dart';

/// Callback for PDF text selection events.
/// Called when user selects text in the PDF viewer.
typedef OnTextSelectionChangeCallback =
    void Function({
      required int pageNumber,
      required MarkerColor color,
      String? selectedText,
      PdfRect? textRect,
    });

/// PDF Viewer panel using pdfrx.
/// Supports text selection, page navigation, marker overlay, and area capture.
class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({
    super.key,
    this.controller,
    this.onTextSelectionChange,
    this.noteId,
  });

  /// Controller for programmatic PDF navigation (e.g., goToPage, goToRectInsidePage).
  /// This is used by the workspace to navigate to markers when clicked in the note editor.
  final PdfViewerController? controller;

  /// Callback invoked when text is selected in the PDF viewer.
  /// This will be wired to the workspace provider to create markers.
  final OnTextSelectionChangeCallback? onTextSelectionChange;

  /// Current note ID for per-note drawing stroke storage.
  final String? noteId;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  // State for text selection
  List<PdfPageTextRange>? _textSelections;
  String? _selectedText;
  int? _selectedPageNumber;
  PdfRect? _selectedTextRect;


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
        // Text selection toolbar (appears when text is selected)
        if (_textSelections != null && _textSelections!.isNotEmpty)
          _buildTextSelectionToolbar(),
        // Drawing toolbar + capture button (top-center)
        if (widget.noteId != null)
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

  /// Build the text selection toolbar.
  Widget _buildTextSelectionToolbar() {
    return Positioned(
      top: 60,
      right: 16,
      child: PdfTextSelectionToolbar(
        selectedText: _selectedText,
        onColorSelected: _handleColorSelected,
      ),
    );
  }

  /// Handle color selection from the toolbar.
  Future<void> _handleColorSelected(MarkerColor color) async {
    if (_selectedPageNumber == null) return;

    // Create marker via provider
    try {
      final markerProvider = ref.read(pdfMarkerStateProvider.notifier);
      final pageNum = _selectedPageNumber!;

      // Convert pdfrx PdfRect to local PdfRect model
      final localRect = _selectedTextRect != null
          ? local_model.PdfRect(
              x: _selectedTextRect!.left,
              y: _selectedTextRect!.top,
              width: _selectedTextRect!.width,
              height: _selectedTextRect!.height,
            )
          : null;

      await markerProvider.createMarker(
        pageNumber: pageNum,
        color: color,
        selectedText: _selectedText,
        textRect: localRect,
      );

      // Notify parent via callback (workspace will insert marker into note)
      widget.onTextSelectionChange?.call(
        pageNumber: pageNum,
        color: color,
        selectedText: _selectedText,
        textRect: _selectedTextRect,
      );

      // Clear selection
      setState(() {
        _textSelections = null;
        _selectedText = null;
        _selectedPageNumber = null;
        _selectedTextRect = null;
      });
    } catch (e) {
      // Show error toast
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to create marker: $e'),
          ),
        );
      }
    }
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
  Future<void> _handleCaptureCompleted({
    required int pageNumber,
    required String filename,
    required Rect normalizedRect,
  }) async {
    try {
      // Extract PDF text at the captured area
      final extractedText =
          await _extractTextFromRect(pageNumber, normalizedRect);
      // Convert normalized rect to pdfrx PdfRect for navigation
      final pdfRect = await _normalizedToPdfRect(
        pageNumber,
        normalizedRect.left,
        normalizedRect.top,
        normalizedRect.right,
        normalizedRect.bottom,
      );

      final workspaceNotifier = ref.read(workspaceProviderProvider.notifier);
      await workspaceNotifier.createMarker(
        pageNumber: pageNumber,
        color: MarkerColor.yellow,
        capturedImagePath: filename,
        selectedText: extractedText,
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

  /// Load a PDF file from path into both workspace and document provider
  Future<void> _loadPdfFromPath(String pdfPath) async {
    final filename = pdfPath.split(RegExp(r'[/\\]')).last;
    try {
      await ref.read(workspaceProviderProvider.notifier).loadPdf(pdfPath);
      await ref.read(pdfDocumentProvider.notifier).loadFromFile(pdfPath);

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
}
