import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_document_provider.g.dart';

/// State holding the current PDF document and viewer controller.
class PdfDocumentState {
  const PdfDocumentState({
    this.documentRef,
    this.controller,
    this.filePath,
  });

  final PdfDocumentRef? documentRef;
  final PdfViewerController? controller;
  final String? filePath;

  PdfDocumentState copyWith({
    PdfDocumentRef? documentRef,
    PdfViewerController? controller,
    String? filePath,
  }) {
    return PdfDocumentState(
      documentRef: documentRef ?? this.documentRef,
      controller: controller ?? this.controller,
      filePath: filePath ?? this.filePath,
    );
  }
}

/// Provider for managing PDF document loading state and PdfViewerController.
/// Handles PDF file loading and controller lifecycle.
@Riverpod(keepAlive: true)
class PdfDocument extends _$PdfDocument {
  @override
  PdfDocumentState build() {
    // Initialize with a controller but no document
    final controller = PdfViewerController();
    return PdfDocumentState(controller: controller);
  }

  /// Load a PDF from a file path.
  /// Creates a new PdfDocumentRef and associates it with the controller.
  Future<void> loadFromFile(String filePath) async {
    try {
      // Create document reference from file path
      final documentRef = PdfDocumentRefFile(
        filePath,
        useProgressiveLoading: true,
      );

      state = state.copyWith(
        documentRef: documentRef,
        filePath: filePath,
      );
    } catch (e) {
      // On error, clear the document but keep the controller
      state = PdfDocumentState(
        controller: state.controller,
      );
      rethrow;
    }
  }

  /// Load a PDF from a Flutter asset path (e.g. 'assets/sample/sample_math.pdf').
  Future<void> loadFromAsset(String assetPath) async {
    try {
      final documentRef = PdfDocumentRefAsset(assetPath);
      state = state.copyWith(
        documentRef: documentRef,
        filePath: assetPath,
      );
    } catch (e) {
      state = PdfDocumentState(controller: state.controller);
      rethrow;
    }
  }

  /// Clear the current document while keeping the controller.
  void clearDocument() {
    state = PdfDocumentState(
      controller: state.controller,
    );
  }

  /// Get the current page number from the controller.
  int? get currentPage => state.controller?.pageNumber;

  /// Get the total page count.
  int? get pageCount => state.controller?.pageCount;
}

/// Helper provider to check if a document is loaded.
@riverpod
bool isPdfLoaded(Ref ref) {
  final docState = ref.watch(pdfDocumentProvider);
  return docState.documentRef != null;
}

/// Helper provider to get the current page number.
@riverpod
int? currentPdfPage(Ref ref) {
  final docState = ref.watch(pdfDocumentProvider);
  return docState.controller?.pageNumber;
}
