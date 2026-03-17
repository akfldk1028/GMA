// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrapnote_canvas_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      sourcePageNumber: (json['sourcePageNumber'] as num?)?.toInt(),
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFFFFEB3B,
      elementId: json['elementId'] as String,
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
      'sourcePageNumber': instance.sourcePageNumber,
      'colorValue': instance.colorValue,
      'elementId': instance.elementId,
    };

const _$CanvasElementTypeEnumMap = {
  CanvasElementType.capture: 'capture',
  CanvasElementType.highlight: 'highlight',
};

_$ScrapnoteCanvasDataImpl _$$ScrapnoteCanvasDataImplFromJson(
  Map<String, dynamic> json,
) => _$ScrapnoteCanvasDataImpl(
  id: json['id'] as String,
  linkedPdfPath: json['linkedPdfPath'] as String,
  canvasMode: json['canvasMode'] as String? ?? 'infinite',
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
  'canvasMode': instance.canvasMode,
  'strokes': instance.strokes.map((e) => e.toJson()).toList(),
  'elements': instance.elements.map((e) => e.toJson()).toList(),
  'layerOrder': instance.layerOrder,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': instance.modifiedAt.toIso8601String(),
};
