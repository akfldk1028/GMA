import 'package:uuid/uuid.dart';

import '../../scrapnote/models/element_model.dart';
import '../models/scrapnote_canvas_model.dart';

const _uuid = Uuid();

/// Stateless service for calculating element positions and creating CanvasElements
/// from ScrapElements to insert into a ScrapnoteCanvas.
class ScrapInsertionService {
  static const double _elementPadding = 20.0;
  static const double _defaultElementWidth = 300.0;
  static const double _defaultCaptureHeight = 200.0;
  static const double _defaultHighlightHeight = 80.0;

  /// Calculate the Y position for the next element inserted below all existing ones.
  ///
  /// Returns [_elementPadding] when [existingElements] is empty.
  static double calculateNextY(List<CanvasElement> existingElements) {
    if (existingElements.isEmpty) return _elementPadding;
    final lastElement = existingElements.reduce(
      (a, b) => (a.y + a.height) > (b.y + b.height) ? a : b,
    );
    return lastElement.y + lastElement.height + _elementPadding;
  }

  /// Create a [CanvasElement] from a [ScrapElement] positioned at [yPosition].
  static CanvasElement createCanvasElement({
    required ScrapElement scrapElement,
    required double yPosition,
  }) {
    final isCapture = scrapElement.type == ScrapElementType.capture;
    return CanvasElement(
      id: _uuid.v4(),
      type: isCapture ? CanvasElementType.capture : CanvasElementType.highlight,
      x: _elementPadding,
      y: yPosition,
      width: _defaultElementWidth,
      height: isCapture ? _defaultCaptureHeight : _defaultHighlightHeight,
      imagePath: scrapElement.imagePath,
      selectedText: scrapElement.selectedText,
      sourcePageNumber: scrapElement.sourcePageNumber,
      colorValue: scrapElement.colorValue,
      elementId: scrapElement.id,
    );
  }
}
