import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:gma_frontend/constants/marker_colors.dart';

part 'marker_model.freezed.dart';
part 'marker_model.g.dart';

@Freezed(toJson: true, fromJson: true)
class Marker with _$Marker {
  const factory Marker({
    required String id,
    @MarkerColorConverter() required MarkerColor color,
    required int pageNumber,
    String? selectedText,
    @_PdfRectConverter() @Default(null) PdfRect? rect,
  }) = _Marker;

  factory Marker.fromJson(Map<String, dynamic> json) => _$MarkerFromJson(json);
}

// Custom converter for MarkerColor JSON serialization
class MarkerColorConverter implements JsonConverter<MarkerColor, String> {
  const MarkerColorConverter();

  @override
  MarkerColor fromJson(String json) => MarkerColor.fromName(json);

  @override
  String toJson(MarkerColor color) => color.name;
}

// Custom converter to ignore PdfRect in JSON serialization
class _PdfRectConverter implements JsonConverter<PdfRect?, Object?> {
  const _PdfRectConverter();

  @override
  PdfRect? fromJson(Object? json) => null;

  @override
  Object? toJson(PdfRect? object) => null;
}
