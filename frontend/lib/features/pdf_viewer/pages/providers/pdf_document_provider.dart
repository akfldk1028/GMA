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
/// Caches PdfDocumentRef per file path to avoid re-parsing on tab switch.
@Riverpod(keepAlive: true)
class PdfDocument extends _$PdfDocument {
  final Map<String, PdfDocumentRef> _cache = {};

  @override
  PdfDocumentState build() {
    final controller = PdfViewerController();
    return PdfDocumentState(controller: controller);
  }

  /// Load a PDF from a file path.
  /// Uses cached PdfDocumentRef if available for the same path.
  Future<void> loadFromFile(String filePath) async {
    try {
      final documentRef = _cache.putIfAbsent(
        filePath,
        () => PdfDocumentRefFile(filePath, useProgressiveLoading: true),
      );

      state = state.copyWith(
        documentRef: documentRef,
        filePath: filePath,
      );
    } catch (e) {
      _cache.remove(filePath);
      state = PdfDocumentState(controller: state.controller);
      rethrow;
    }
  }

  /// Evict a specific path from cache (e.g. when closing a tab).
  void evict(String filePath) {
    _cache.remove(filePath);
  }

  /// Load a PDF from a Flutter asset path (e.g. 'assets/sample/sample_math.pdf').
  Future<void> loadFromAsset(String assetPath) async {
    try {
      final documentRef = _cache.putIfAbsent(
        assetPath,
        () => PdfDocumentRefAsset(assetPath),
      );
      state = state.copyWith(
        documentRef: documentRef,
        filePath: assetPath,
      );
    } catch (e) {
      _cache.remove(assetPath);
      state = PdfDocumentState(controller: state.controller);
      rethrow;
    }
  }

  /// Clear the current document while keeping the controller.
  void clearDocument() {
    _cache.clear();
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
