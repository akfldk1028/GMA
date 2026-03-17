import 'package:freezed_annotation/freezed_annotation.dart';

import '../../drawing/models/drawing_model.dart';

part 'scrapnote_canvas_model.freezed.dart';
part 'scrapnote_canvas_model.g.dart';

/// Type of element placed on the scrapnote canvas.
enum CanvasElementType { capture, highlight }

/// A positioned element on the infinite scrapnote canvas.
/// Uses absolute pixel coordinates — not normalized (0-1).
@freezed
class CanvasElement with _$CanvasElement {
  const factory CanvasElement({
    required String id,
    required CanvasElementType type,

    /// Absolute pixel X position on the canvas.
    required double x,

    /// Absolute pixel Y position on the canvas.
    required double y,

    /// Width in pixels.
    required double width,

    /// Height in pixels.
    required double height,

    /// Absolute path to capture image file. Only set for capture elements.
    String? imagePath,

    /// Highlighted text content. Only set for highlight elements.
    String? selectedText,

    /// Source PDF page number (1-based).
    int? sourcePageNumber,

    /// ARGB color value for highlight elements.
    @Default(0xFFFFEB3B) int colorValue,

    /// Reference to the originating ScrapElement ID.
    required String elementId,
  }) = _CanvasElement;

  factory CanvasElement.fromJson(Map<String, dynamic> json) =>
      _$CanvasElementFromJson(json);
}

/// The full data model for a scrapnote canvas linked to a specific PDF.
/// Contains freehand strokes and positioned canvas elements.
@freezed
class ScrapnoteCanvasData with _$ScrapnoteCanvasData {
  const factory ScrapnoteCanvasData({
    required String id,

    /// Absolute path to the linked PDF file.
    required String linkedPdfPath,

    /// Canvas layout mode: 'infinite' (default) or 'a4'.
    @Default('infinite') String canvasMode,

    /// All freehand strokes drawn on the canvas.
    @Default([]) List<DrawingStroke> strokes,

    /// All elements placed on the canvas.
    @Default([]) List<CanvasElement> elements,

    /// Element IDs in z-order (bottom to top).
    @Default([]) List<String> layerOrder,

    required DateTime createdAt,
    required DateTime modifiedAt,
  }) = _ScrapnoteCanvasData;

  factory ScrapnoteCanvasData.fromJson(Map<String, dynamic> json) =>
      _$ScrapnoteCanvasDataFromJson(json);
}
