import 'package:pdfrx/pdfrx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/pdf_document_state.dart';

part 'pdf_document_provider.g.dart';

// @MX:ANCHOR: Primary PDF document state provider accessed by PdfViewerScreen and DrawingOverlay
// @MX:REASON: fan_in >= 3 — PdfViewerScreen, DrawingOverlay, PdfPageOverlay all read this provider
@Riverpod(keepAlive: true)
class PdfDocumentNotifier extends _$PdfDocumentNotifier {
  PdfViewerController? _controller;

  @override
  PdfDocumentState build() {
    _controller = PdfViewerController();

    ref.onDispose(() {
      _controller = null;
    });

    return const PdfDocumentState();
  }

  /// Get the active PdfViewerController for use in PdfViewer widget.
  PdfViewerController? get controller => _controller;

  /// Load a PDF document from a file path.
  Future<void> loadDocument(String path) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final doc = await PdfDocument.openFile(path);
      final totalPages = doc.pages.length;

      state = state.copyWith(
        document: doc,
        totalPages: totalPages,
        currentPage: 1,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        document: null,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Navigate to a specific page.
  void goToPage(int page) {
    final clampedPage = page < 1 ? 1 : page;
    state = state.copyWith(currentPage: clampedPage);
    // Guard: controller.goToPage requires an attached widget state
    try {
      _controller?.goToPage(pageNumber: clampedPage);
    } catch (_) {
      // Controller not yet attached to a widget — state already updated above
    }
  }

  /// Clear the current document and reset state.
  void clearDocument() {
    state = const PdfDocumentState();
  }
}
