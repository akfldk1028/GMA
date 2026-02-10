import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../constants/marker_colors.dart';

part 'pdf_marker_model.freezed.dart';
part 'pdf_marker_model.g.dart';

/// Converter for PdfRect to/from JSON
class PdfRectConverter implements JsonConverter<PdfRect?, Map<String, dynamic>?> {
  const PdfRectConverter();

  @override
  PdfRect? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PdfRect(
      json['left'] as double,
      json['top'] as double,
      json['right'] as double,
      json['bottom'] as double,
    );
  }

  @override
  Map<String, dynamic>? toJson(PdfRect? rect) {
    if (rect == null) return null;
    return {
      'left': rect.left,
      'top': rect.top,
      'right': rect.right,
      'bottom': rect.bottom,
    };
  }
}

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
