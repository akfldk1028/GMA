import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:gma_frontend/constants/marker_colors.dart';

part 'marker_model.freezed.dart';
part 'marker_model.g.dart';

@freezed
class Marker with _$Marker {
  const factory Marker({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _markerColorFromJson, toJson: _markerColorToJson) required MarkerColor color,
    required int pageNumber,
    String? selectedText,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: false, includeToJson: false) PdfRect? rect,
  }) = _Marker;

  factory Marker.fromJson(Map<String, dynamic> json) => _$MarkerFromJson(json);
}

// Helper functions for MarkerColor JSON serialization
MarkerColor _markerColorFromJson(String value) => MarkerColor.fromName(value);
String _markerColorToJson(MarkerColor color) => color.name;
