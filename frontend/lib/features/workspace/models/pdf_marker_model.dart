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
      (json['left'] as num).toDouble(),
      (json['top'] as num).toDouble(),
      (json['right'] as num).toDouble(),
      (json['bottom'] as num).toDouble(),
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

/// Converter for List<PdfRect> to/from JSON (per-line highlight rects).
class PdfRectListConverter
    implements JsonConverter<List<PdfRect>?, List<dynamic>?> {
  const PdfRectListConverter();

  @override
  List<PdfRect>? fromJson(List<dynamic>? json) {
    if (json == null) return null;
    return json
        .whereType<Map>()
        .map((m) {
          final j = Map<String, dynamic>.from(m);
          return PdfRect(
            (j['left'] as num).toDouble(),
            (j['top'] as num).toDouble(),
            (j['right'] as num).toDouble(),
            (j['bottom'] as num).toDouble(),
          );
        })
        .toList();
  }

  @override
  List<dynamic>? toJson(List<PdfRect>? rects) {
    if (rects == null) return null;
    return rects
        .map((r) => {
              'left': r.left,
              'top': r.top,
              'right': r.right,
              'bottom': r.bottom,
            })
        .toList();
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
    @PdfRectListConverter() List<PdfRect>? lineRects,
    String? capturedImagePath,
  }) = _PdfMarker;

  factory PdfMarker.fromJson(Map<String, dynamic> json) =>
      _$PdfMarkerFromJson(json);
}
