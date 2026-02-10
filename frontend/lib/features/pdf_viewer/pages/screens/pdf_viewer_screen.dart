import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/marker_colors.dart';
import '../../models/pdf_marker_model.dart' as model;
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
  });

  /// Controller for programmatic PDF navigation (e.g., goToPage, goToRectInsidePage).
  /// This is used by the workspace to navigate to markers when clicked in the note editor.
  final PdfViewerController? controller;

  /// Callback invoked when text is selected in the PDF viewer.
  /// This will be wired to the workspace provider to create markers.
  final OnTextSelectionChangeCallback? onTextSelectionChange;

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

    // Show empty state if no document is loaded
    if (docState.documentRef == null) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        // Main PDF viewer
        PdfViewer(
          docState.documentRef!,
          controller: controller!,
          params: PdfViewerParams(
            // Text selection configuration
            textSelectionParams: PdfTextSelectionParams(
              onTextSelectionChange: _handleTextSelectionChange,
            ),
            // Page paint callbacks for markers
            pagePaintCallbacks: PdfPageOverlay.createPaintCallbacks(ref),
            // Page overlay builder for page numbers
            pageOverlaysBuilder: (context, pageRect, page) {
              return [
                _buildPageNumberOverlay(page.pageNumber, controller.pageCount),
              ];
            },
          ),
        ),
        // Text selection toolbar (appears when text is selected)
        if (_textSelections != null && _textSelections!.isNotEmpty)
          _buildTextSelectionToolbar(),
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

  /// Convert pdfrx PdfRect to our model's PdfRect.
  model.PdfRect _convertPdfRectToModel(PdfRect pdfRect) {
    return model.PdfRect(
      x: pdfRect.left,
      y: pdfRect.bottom,
      width: pdfRect.width,
      height: pdfRect.height,
    );
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
      await markerProvider.createMarker(
        pageNumber: _selectedPageNumber!,
        color: color,
        selectedText: _selectedText,
        textRect: _selectedTextRect != null
            ? _convertPdfRectToModel(_selectedTextRect!)
            : null,
      );

      // Notify parent via callback
      widget.onTextSelectionChange?.call(
        pageNumber: _selectedPageNumber!,
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

      // Show success toast
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Marker created'),
            description: Text(
              '${color.emoji} marker added to page $_selectedPageNumber',
            ),
          ),
        );
      }
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

  /// Build page navigation controls overlay.
  Widget _buildNavigationControls(PdfViewerController? controller) {
    if (controller == null || !controller.isReady) {
      return const SizedBox.shrink();
    }

    final currentPage = controller.pageNumber ?? 1;
    final totalPages = controller.pageCount;

    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First page
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: () => controller.goToPage(pageNumber: 1),
                  tooltip: 'First page',
                ),
                const SizedBox(width: 8),
                // Previous page
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 1
                      ? () => controller.goToPage(pageNumber: currentPage - 1)
                      : null,
                  tooltip: 'Previous page',
                ),
                const SizedBox(width: 16),
                // Page info
                Text(
                  'Page $currentPage of $totalPages',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                // Next page
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages
                      ? () => controller.goToPage(pageNumber: currentPage + 1)
                      : null,
                  tooltip: 'Next page',
                ),
                const SizedBox(width: 8),
                // Last page
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: () => controller.goToPage(pageNumber: totalPages),
                  tooltip: 'Last page',
                ),
                const SizedBox(width: 16),
                const VerticalDivider(width: 1),
                const SizedBox(width: 16),
                // Zoom out
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: () => controller.zoomDown(),
                  tooltip: 'Zoom out',
                ),
                // Zoom in
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () => controller.zoomUp(),
                  tooltip: 'Zoom in',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build page number overlay widget.
  Widget _buildPageNumberOverlay(int pageNumber, int pageCount) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$pageNumber / $pageCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Build empty state when no PDF is loaded.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text('No PDF loaded', style: ShadTheme.of(context).textTheme.h3),
          const SizedBox(height: 8),
          Text(
            'Open a PDF file to start viewing and annotating',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
