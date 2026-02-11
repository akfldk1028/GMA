// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_marker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PdfRectImpl _$$PdfRectImplFromJson(Map<String, dynamic> json) =>
    _$PdfRectImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$$PdfRectImplToJson(_$PdfRectImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };

_$PdfMarkerImpl _$$PdfMarkerImplFromJson(Map<String, dynamic> json) =>
    _$PdfMarkerImpl(
      id: json['id'] as String,
      pageNumber: (json['pageNumber'] as num).toInt(),
      color: $enumDecode(_$MarkerColorEnumMap, json['color']),
      selectedText: json['selectedText'] as String?,
      textRect: const PdfRectConverter().fromJson(json['textRect']),
      capturedImagePath: json['capturedImagePath'] as String?,
    );

Map<String, dynamic> _$$PdfMarkerImplToJson(_$PdfMarkerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageNumber': instance.pageNumber,
      'color': _$MarkerColorEnumMap[instance.color]!,
      'selectedText': instance.selectedText,
      'textRect': const PdfRectConverter().toJson(instance.textRect),
      'capturedImagePath': instance.capturedImagePath,
    };

const _$MarkerColorEnumMap = {
  MarkerColor.red: 'red',
  MarkerColor.yellow: 'yellow',
  MarkerColor.green: 'green',
  MarkerColor.blue: 'blue',
  MarkerColor.purple: 'purple',
  MarkerColor.pen: 'pen',
};
