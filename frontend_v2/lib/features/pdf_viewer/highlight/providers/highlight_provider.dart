import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gma_app/features/scrapnote/models/element_model.dart';
import 'package:gma_app/features/scrapnote/providers/element_store.dart';
import '../models/highlight_marker_data.dart';

part 'highlight_provider.g.dart';

// @MX:ANCHOR: highlightMarkersProvider — primary data source for HighlightOverlay
// @MX:REASON: Called from PdfPageOverlay (via HighlightOverlay) for every
// visible page; fan_in scales with open page count.

/// Derives per-page [HighlightMarkerData] from the flat [ElementStoreNotifier]
/// state, filtered to [documentPath] and [ScrapElementType.highlight] only.
///
/// Returns an empty map when there are no highlights for the document.
/// Automatically updates whenever [elementStoreNotifierProvider] changes.
@riverpod
class HighlightMarkers extends _$HighlightMarkers {
  @override
  Map<int, List<HighlightMarkerData>> build(String documentPath) {
    final elements = ref.watch(elementStoreNotifierProvider);

    final grouped = <int, List<HighlightMarkerData>>{};

    for (final element in elements) {
      if (element.type != ScrapElementType.highlight) continue;
      if (element.pdfPath != documentPath) continue;

      final marker = HighlightMarkerData(
        pageNumber: element.sourcePageNumber,
        normalizedRects: [element.sourceRect],
        colorValue: element.colorValue,
        elementId: element.id,
      );

      grouped
          .putIfAbsent(element.sourcePageNumber, () => [])
          .add(marker);
    }

    return grouped;
  }
}
