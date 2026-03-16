// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DrawingStrokeImpl _$$DrawingStrokeImplFromJson(Map<String, dynamic> json) =>
    _$DrawingStrokeImpl(
      id: json['id'] as String,
      pageNumber: (json['pageNumber'] as num).toInt(),
      points: (json['points'] as List<dynamic>)
          .map((e) => StrokePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolId: json['toolId'] as String,
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF000000,
      size: (json['size'] as num?)?.toDouble() ?? 3.0,
    );

Map<String, dynamic> _$$DrawingStrokeImplToJson(_$DrawingStrokeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageNumber': instance.pageNumber,
      'points': instance.points,
      'toolId': instance.toolId,
      'colorValue': instance.colorValue,
      'size': instance.size,
    };

_$StrokePointImpl _$$StrokePointImplFromJson(Map<String, dynamic> json) =>
    _$StrokePointImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$StrokePointImplToJson(_$StrokePointImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'pressure': instance.pressure,
    };
