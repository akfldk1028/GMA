// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ElementRectImpl _$$ElementRectImplFromJson(Map<String, dynamic> json) =>
    _$ElementRectImpl(
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      right: (json['right'] as num).toDouble(),
      bottom: (json['bottom'] as num).toDouble(),
    );

Map<String, dynamic> _$$ElementRectImplToJson(_$ElementRectImpl instance) =>
    <String, dynamic>{
      'left': instance.left,
      'top': instance.top,
      'right': instance.right,
      'bottom': instance.bottom,
    };

_$ScrapElementImpl _$$ScrapElementImplFromJson(Map<String, dynamic> json) =>
    _$ScrapElementImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ScrapElementTypeEnumMap, json['type']),
      pdfPath: json['pdfPath'] as String,
      selectedText: json['selectedText'] as String?,
      imagePath: json['imagePath'] as String?,
      sourcePageNumber: (json['sourcePageNumber'] as num).toInt(),
      sourceRect: ElementRect.fromJson(
        json['sourceRect'] as Map<String, dynamic>,
      ),
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFFFFEB3B,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ScrapElementImplToJson(_$ScrapElementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ScrapElementTypeEnumMap[instance.type]!,
      'pdfPath': instance.pdfPath,
      'selectedText': instance.selectedText,
      'imagePath': instance.imagePath,
      'sourcePageNumber': instance.sourcePageNumber,
      'sourceRect': instance.sourceRect.toJson(),
      'colorValue': instance.colorValue,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ScrapElementTypeEnumMap = {
  ScrapElementType.highlight: 'highlight',
  ScrapElementType.capture: 'capture',
};
