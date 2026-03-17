import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/element_model.dart';
import '../pages/providers/scrapnote_canvas_provider.dart';
import '../services/scrap_insertion_service.dart';
import 'element_store.dart';

part 'scrap_orchestrator_provider.g.dart';

const _uuid = Uuid();

// @MX:ANCHOR: Central insertion point for all scrap elements — called by PdfViewerScreen and future capture flows
// @MX:REASON: fan_in >= 3 callers expected across pdf viewer, context menu, and future capture UI
/// Central orchestrator for creating and storing ScrapElements.
/// Acts as the single entry point for all scrap insertion workflows.
@Riverpod(keepAlive: true)
class ScrapOrchestrator extends _$ScrapOrchestrator {
  @override
  void build() {}

  /// Creates a text highlight ScrapElement and persists it.
  ///
  /// [pdfPath] - absolute path to the source PDF
  /// [selectedText] - the highlighted text content
  /// [pageNumber] - 1-based page number of the highlight
  /// [sourceRect] - normalized (0-1) bounding rect on the page
  /// [colorValue] - ARGB color, defaults to yellow 0xFFFFEB3B
  Future<ScrapElement> createHighlight({
    required String pdfPath,
    required String selectedText,
    required int pageNumber,
    required ElementRect sourceRect,
    int? colorValue,
  }) async {
    final element = ScrapElement(
      id: _uuid.v4(),
      type: ScrapElementType.highlight,
      pdfPath: pdfPath,
      selectedText: selectedText,
      sourcePageNumber: pageNumber,
      sourceRect: sourceRect,
      colorValue: colorValue ?? 0xFFFFEB3B,
      createdAt: DateTime.now(),
    );

    await ref.read(elementStoreNotifierProvider.notifier).addElement(element);
    await _insertIntoCanvas(element);
    return element;
  }

  /// Creates a page capture ScrapElement and persists it.
  ///
  /// [pdfPath] - absolute path to the source PDF
  /// [imagePath] - absolute path to the saved capture image
  /// [pageNumber] - 1-based page number of the capture
  /// [sourceRect] - normalized (0-1) bounding rect on the page
  Future<ScrapElement> createCapture({
    required String pdfPath,
    required String imagePath,
    required int pageNumber,
    required ElementRect sourceRect,
  }) async {
    final element = ScrapElement(
      id: _uuid.v4(),
      type: ScrapElementType.capture,
      pdfPath: pdfPath,
      imagePath: imagePath,
      sourcePageNumber: pageNumber,
      sourceRect: sourceRect,
      createdAt: DateTime.now(),
    );

    await ref.read(elementStoreNotifierProvider.notifier).addElement(element);
    await _insertIntoCanvas(element);
    return element;
  }

  /// Insert [element] into the linked scrapnote canvas at the next available Y.
  Future<void> _insertIntoCanvas(ScrapElement element) async {
    final canvasNotifier = ref.read(
      scrapnoteCanvasProvider(element.pdfPath).notifier,
    );
    final canvasData = ref
        .read(scrapnoteCanvasProvider(element.pdfPath))
        .valueOrNull;
    if (canvasData == null) return;

    final yPosition =
        ScrapInsertionService.calculateNextY(canvasData.elements);
    final canvasElement = ScrapInsertionService.createCanvasElement(
      scrapElement: element,
      yPosition: yPosition,
    );
    canvasNotifier.addElement(canvasElement);
  }
}
