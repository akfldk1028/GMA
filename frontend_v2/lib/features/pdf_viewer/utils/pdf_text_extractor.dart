import 'dart:ui';

// @MX:NOTE: Coordinate conversion utility for PDF text selection.
// Normalized coordinates (0..1) allow coordinates to be stored independent
// of the rendered page size, enabling correct replay at any zoom level.

/// Utility for PDF text extraction and coordinate normalization.
///
/// Converts between absolute pixel coordinates (relative to a rendered page)
/// and normalized coordinates in the 0..1 range (relative to page dimensions).
///
/// Normalized coordinates allow selections to be stored independent of zoom
/// level or display resolution and replayed correctly at any size (AC-20).
class PdfTextExtractor {
  // @MX:NOTE: Static-only utility class — no instantiation needed.
  const PdfTextExtractor._();

  /// Converts absolute page coordinates to normalized 0..1 range.
  ///
  /// [x] and [y] are pixel coordinates relative to the top-left of the page.
  /// Result is clamped to [0.0, 1.0] to handle out-of-bounds input.
  static Offset toNormalized({
    required double x,
    required double y,
    required double pageWidth,
    required double pageHeight,
  }) {
    final nx = (x / pageWidth).clamp(0.0, 1.0);
    final ny = (y / pageHeight).clamp(0.0, 1.0);
    return Offset(nx, ny);
  }

  /// Converts normalized 0..1 coordinates back to absolute page pixel coordinates.
  ///
  /// [nx] and [ny] are normalized values in the range [0.0, 1.0].
  /// The result is the pixel position on a page of the given dimensions.
  static Offset fromNormalized({
    required double nx,
    required double ny,
    required double pageWidth,
    required double pageHeight,
  }) {
    return Offset(nx * pageWidth, ny * pageHeight);
  }
}
