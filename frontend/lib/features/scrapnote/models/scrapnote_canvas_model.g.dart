// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrapnote_canvas_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScrapnoteCanvasDataImpl _$$ScrapnoteCanvasDataImplFromJson(
  Map<String, dynamic> json,
) => _$ScrapnoteCanvasDataImpl(
  id: json['id'] as String,
  linkedPdfPath: json['linkedPdfPath'] as String,
  canvasMode:
      $enumDecodeNullable(_$CanvasModeEnumMap, json['canvasMode']) ??
      CanvasMode.infinite,
  canvasWidth: (json['canvasWidth'] as num?)?.toDouble() ?? 1080.0,
  canvasHeight: (json['canvasHeight'] as num?)?.toDouble(),
  strokes:
      (json['strokes'] as List<dynamic>?)
          ?.map((e) => DrawingStroke.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => CanvasElement.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  layerOrder:
      (json['layerOrder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  modifiedAt: DateTime.parse(json['modifiedAt'] as String),
);

Map<String, dynamic> _$$ScrapnoteCanvasDataImplToJson(
  _$ScrapnoteCanvasDataImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'linkedPdfPath': instance.linkedPdfPath,
  'canvasMode': _$CanvasModeEnumMap[instance.canvasMode]!,
  'canvasWidth': instance.canvasWidth,
  'canvasHeight': instance.canvasHeight,
  'strokes': instance.strokes.map((e) => e.toJson()).toList(),
  'elements': instance.elements.map((e) => e.toJson()).toList(),
  'layerOrder': instance.layerOrder,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': instance.modifiedAt.toIso8601String(),
};

const _$CanvasModeEnumMap = {CanvasMode.infinite: 'infinite'};

_$CanvasElementImpl _$$CanvasElementImplFromJson(Map<String, dynamic> json) =>
    _$CanvasElementImpl(
      id: json['id'] as String,
      type: $enumDecode(_$CanvasElementTypeEnumMap, json['type']),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      imagePath: json['imagePath'] as String?,
      selectedText: json['selectedText'] as String?,
      colorValue: (json['colorValue'] as num?)?.toInt(),
      sourcePageNumber: (json['sourcePageNumber'] as num?)?.toInt(),
      sourcePdfPath: json['sourcePdfPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CanvasElementImplToJson(_$CanvasElementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$CanvasElementTypeEnumMap[instance.type]!,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'imagePath': instance.imagePath,
      'selectedText': instance.selectedText,
      'colorValue': instance.colorValue,
      'sourcePageNumber': instance.sourcePageNumber,
      'sourcePdfPath': instance.sourcePdfPath,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$CanvasElementTypeEnumMap = {
  CanvasElementType.capture: 'capture',
  CanvasElementType.highlight: 'highlight',
};
