import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gma_frontend/constants/marker_colors.dart';

part 'pdf_marker_model.freezed.dart';
part 'pdf_marker_model.g.dart';

/// Represents a rectangular region in a PDF page with coordinates.
@freezed
class PdfRect with _$PdfRect {
  const factory PdfRect({
    required double x,
    required double y,
    required double width,
    required double height,
  }) = _PdfRect;

  factory PdfRect.fromJson(Map<String, dynamic> json) =>
      _$PdfRectFromJson(json);
}

/// Custom JSON converter for optional PdfRect
class PdfRectConverter implements JsonConverter<PdfRect?, Object?> {
  const PdfRectConverter();

  @override
  PdfRect? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      return PdfRect.fromJson(json);
    }
    return null;
  }

  @override
  Object? toJson(PdfRect? object) {
    return object?.toJson();
  }
}

/// PDF marker model for page annotations linked to notes.
///
/// Markers represent highlighted text or captured regions in a PDF,
/// with associated metadata like color, selected text, and coordinates.
@freezed
class PdfMarker with _$PdfMarker {
  const factory PdfMarker({
    required String id,
    required int pageNumber,
    required MarkerColor color,
    String? selectedText,
    @PdfRectConverter() PdfRect? textRect,
    String? capturedImagePath,
  }) = _PdfMarker;

  factory PdfMarker.fromJson(Map<String, dynamic> json) =>
      _$PdfMarkerFromJson(json);
}
