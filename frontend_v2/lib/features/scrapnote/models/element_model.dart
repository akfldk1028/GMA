import 'package:freezed_annotation/freezed_annotation.dart';

part 'element_model.freezed.dart';
part 'element_model.g.dart';

/// Type of scrap element captured from a PDF.
enum ScrapElementType { highlight, capture }

/// Normalized bounding rectangle in 0-1 coordinate space.
/// All values are relative to the PDF page dimensions.
@freezed
class ElementRect with _$ElementRect {
  const factory ElementRect({
    required double left,
    required double top,
    required double right,
    required double bottom,
  }) = _ElementRect;

  factory ElementRect.fromJson(Map<String, dynamic> json) =>
      _$ElementRectFromJson(json);
}

/// A single scrap element extracted from a PDF page.
/// Represents either a text highlight or a page capture.
@freezed
class ScrapElement with _$ScrapElement {
  const factory ScrapElement({
    required String id,
    required ScrapElementType type,
    required String pdfPath,
    String? selectedText,
    String? imagePath,
    required int sourcePageNumber,
    required ElementRect sourceRect,
    @Default(0xFFFFEB3B) int colorValue,
    required DateTime createdAt,
  }) = _ScrapElement;

  factory ScrapElement.fromJson(Map<String, dynamic> json) =>
      _$ScrapElementFromJson(json);
}
