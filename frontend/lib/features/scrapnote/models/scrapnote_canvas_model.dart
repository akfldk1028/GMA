import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../workspace/models/pdf_marker_model.dart';

part 'scrapnote_canvas_model.freezed.dart';
part 'scrapnote_canvas_model.g.dart';

/// Canvas mode for scrapnote.
/// Currently only infinite mode is supported.
enum CanvasMode {
  infinite,
}

/// Type of a canvas element (e.g., a captured image or a PDF highlight).
enum CanvasElementType {
  capture,
  highlight,
}

/// Represents the full canvas state for a single scrapnote.
///
/// Uses absolute pixel coordinates (1080px width by default).
/// For infinite-height canvases, [canvasHeight] is null.
/// [strokes] reuse [DrawingStroke] directly; [pageNumber] = 0 for scrapnote infinite mode.
// @MX:ANCHOR: [AUTO] Central model for scrapnote canvas persistence. Multiple providers depend on this.
// @MX:REASON: High fan_in — ScrapnoteSerializer, ScrapnoteProvider, and future canvas widgets all depend on this model.
@freezed
class ScrapnoteCanvasData with _$ScrapnoteCanvasData {
  const factory ScrapnoteCanvasData({
    required String id,
    required String linkedPdfPath,
    @Default(CanvasMode.infinite) CanvasMode canvasMode,
    @Default(1080.0) double canvasWidth,
    // null means infinite height
    double? canvasHeight,
    @Default([]) List<DrawingStroke> strokes,
    @Default([]) List<CanvasElement> elements,
    @Default([]) List<String> layerOrder,
    required DateTime createdAt,
    required DateTime modifiedAt,
  }) = _ScrapnoteCanvasData;

  factory ScrapnoteCanvasData.fromJson(Map<String, dynamic> json) =>
      _$ScrapnoteCanvasDataFromJson(json);
}

/// A single element placed on the scrapnote canvas.
///
/// Coordinates ([x], [y], [width], [height]) are in absolute pixels
/// relative to the 1080-wide canvas — NOT normalized 0-1 like PDF drawing.
@freezed
class CanvasElement with _$CanvasElement {
  const factory CanvasElement({
    required String id,
    required CanvasElementType type,
    required double x,
    required double y,
    required double width,
    required double height,
    // Path to a captured image file (for capture-type elements)
    String? imagePath,
    // Highlighted or selected text from the PDF
    String? selectedText,
    // Color as ARGB int (e.g., 0xFFFFFF00 for yellow)
    int? colorValue,
    // Source PDF page number (1-indexed), null if unknown
    int? sourcePageNumber,
    // Path of the source PDF from which this element was extracted
    String? sourcePdfPath,
    // Source region on the PDF page (for rendering highlight rectangles on PDF)
    @PdfRectConverter() PdfRect? sourceRect,
    required DateTime createdAt,
  }) = _CanvasElement;

  factory CanvasElement.fromJson(Map<String, dynamic> json) =>
      _$CanvasElementFromJson(json);
}
