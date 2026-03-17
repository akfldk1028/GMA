// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight_marker_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HighlightMarkerDataImpl _$$HighlightMarkerDataImplFromJson(
  Map<String, dynamic> json,
) => _$HighlightMarkerDataImpl(
  pageNumber: (json['pageNumber'] as num).toInt(),
  normalizedRects: (json['normalizedRects'] as List<dynamic>)
      .map((e) => ElementRect.fromJson(e as Map<String, dynamic>))
      .toList(),
  colorValue: (json['colorValue'] as num).toInt(),
  elementId: json['elementId'] as String,
);

Map<String, dynamic> _$$HighlightMarkerDataImplToJson(
  _$HighlightMarkerDataImpl instance,
) => <String, dynamic>{
  'pageNumber': instance.pageNumber,
  'normalizedRects': instance.normalizedRects.map((e) => e.toJson()).toList(),
  'colorValue': instance.colorValue,
  'elementId': instance.elementId,
};
