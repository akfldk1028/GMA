// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarkerImpl _$$MarkerImplFromJson(Map<String, dynamic> json) => _$MarkerImpl(
  id: json['id'] as String,
  color: _markerColorFromJson(json['color'] as String),
  pageNumber: (json['pageNumber'] as num).toInt(),
  selectedText: json['selectedText'] as String?,
);

Map<String, dynamic> _$$MarkerImplToJson(_$MarkerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'color': _markerColorToJson(instance.color),
      'pageNumber': instance.pageNumber,
      'selectedText': instance.selectedText,
    };
