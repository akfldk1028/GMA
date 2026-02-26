// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarkerImpl _$$MarkerImplFromJson(Map<String, dynamic> json) => _$MarkerImpl(
  id: json['id'] as String,
  color: const MarkerColorConverter().fromJson(json['color'] as String),
  pageNumber: (json['pageNumber'] as num).toInt(),
  selectedText: json['selectedText'] as String?,
  rect: json['rect'] == null
      ? null
      : const _PdfRectConverter().fromJson(json['rect']),
);

Map<String, dynamic> _$$MarkerImplToJson(_$MarkerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'color': const MarkerColorConverter().toJson(instance.color),
      'pageNumber': instance.pageNumber,
      'selectedText': instance.selectedText,
      'rect': const _PdfRectConverter().toJson(instance.rect),
    };
