import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gma_app/features/scrapnote/models/element_model.dart';

part 'highlight_marker_data.freezed.dart';
part 'highlight_marker_data.g.dart';

// @MX:NOTE: HighlightMarkerData is the rendering DTO for a single highlight
// scrap element. It carries only the data needed by HighlightOverlay /
// _HighlightPainter and is grouped by page number in highlightMarkersProvider.

/// Rendering data for a single highlight annotation on a PDF page.
///
/// [normalizedRects] contains bounding rectangles in 0-1 coordinate space
/// (relative to page width/height). The painter scales them to pixels using
/// [pageWidth] / [pageHeight] supplied by [HighlightOverlay].
///
/// [elementId] links back to the originating [ScrapElement] so that the UI
/// can trigger deletion without re-querying the store.
@freezed
class HighlightMarkerData with _$HighlightMarkerData {
  const factory HighlightMarkerData({
    required int pageNumber,
    required List<ElementRect> normalizedRects,
    required int colorValue,
    required String elementId,
  }) = _HighlightMarkerData;

  factory HighlightMarkerData.fromJson(Map<String, dynamic> json) =>
      _$HighlightMarkerDataFromJson(json);
}
