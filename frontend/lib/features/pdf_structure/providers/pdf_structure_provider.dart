import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/pdf_structure_model.dart';
import '../services/pdf_structure_service.dart';

part 'pdf_structure_provider.g.dart';

/// State for the PDF structure analysis feature.
class PdfStructureState {
  final PdfStructureResult? result;
  final bool isAnalyzing;
  final String? error;
  final bool isAvailable;

  const PdfStructureState({
    this.result,
    this.isAnalyzing = false,
    this.error,
    this.isAvailable = true,
  });

  PdfStructureState copyWith({
    PdfStructureResult? Function()? result,
    bool? isAnalyzing,
    String? Function()? error,
    bool? isAvailable,
  }) =>
      PdfStructureState(
        result: result != null ? result() : this.result,
        isAnalyzing: isAnalyzing ?? this.isAnalyzing,
        error: error != null ? error() : this.error,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}

/// Provider managing PDF structure analysis state.
///
/// Integrates with WorkspaceProvider: call [analyze] when a PDF is loaded,
/// then use [elementsForPage] to get structure data for overlays/sidebar.
@Riverpod(keepAlive: true)
class PdfStructure extends _$PdfStructure {
  @override
  PdfStructureState build() {
    return const PdfStructureState();
  }

  /// Analyze a PDF file in the background.
  ///
  /// Called from WorkspaceProvider.loadPdf() after the PDF document is loaded.
  /// Non-blocking: sets isAnalyzing=true, runs conversion, updates state.
  Future<void> analyze(String pdfPath) async {
    debugPrint('[PdfStructureProvider.analyze] starting: $pdfPath');
    state = state.copyWith(isAnalyzing: true, error: () => null);

    // Check Java availability first
    final javaOk = await PdfStructureService.isJavaAvailable();
    if (!javaOk) {
      debugPrint('[PdfStructureProvider.analyze] Java not available');
      state = state.copyWith(
        isAnalyzing: false,
        isAvailable: false,
        error: () => 'Java 11+ required for PDF structure analysis',
      );
      return;
    }

    try {
      final parsed = await PdfStructureService.convert(pdfPath);
      state = state.copyWith(
        result: () => parsed,
        isAnalyzing: false,
        isAvailable: true,
        error: () => null,
      );
      debugPrint(
        '[PdfStructureProvider.analyze] done: '
        '${parsed.kids.length} elements, '
        '${parsed.headings.length} headings',
      );
    } on PdfStructureException catch (e) {
      debugPrint('[PdfStructureProvider.analyze] error: $e');
      state = state.copyWith(
        isAnalyzing: false,
        error: () => e.message,
      );
    } catch (e) {
      debugPrint('[PdfStructureProvider.analyze] unexpected error: $e');
      state = state.copyWith(
        isAnalyzing: false,
        error: () => 'Unexpected error: $e',
      );
    }
  }

  /// Get all structure elements for a specific page.
  List<StructureElement> elementsForPage(int pageNumber) {
    return state.result?.elementsForPage(pageNumber) ?? [];
  }

  /// Get the heading tree (all headings sorted by page/position).
  List<StructureElement> get headings => state.result?.headings ?? [];

  /// Clear state (e.g. when closing a PDF).
  void clear() {
    PdfStructureService.clearCache();
    state = const PdfStructureState();
  }
}

/// Convenience provider: elements for a specific page.
@riverpod
List<StructureElement> structureElementsForPage(
  StructureElementsForPageRef ref,
  int pageNumber,
) {
  final structureState = ref.watch(pdfStructureProvider);
  return structureState.result?.elementsForPage(pageNumber) ?? [];
}

/// Convenience provider: heading list for sidebar tree.
@riverpod
List<StructureElement> structureHeadings(StructureHeadingsRef ref) {
  final structureState = ref.watch(pdfStructureProvider);
  return structureState.result?.headings ?? [];
}
