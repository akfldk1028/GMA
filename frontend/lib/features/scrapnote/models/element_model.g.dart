// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScrapElementImpl _$$ScrapElementImplFromJson(Map<String, dynamic> json) =>
    _$ScrapElementImpl(
      id: json['id'] as String,
      pdfId: json['pdfId'] as String,
      pageNumber: (json['pageNumber'] as num).toInt(),
      type: $enumDecode(_$ElementTypeEnumMap, json['type']),
      rect: const PdfRectConverter().fromJson(
        json['rect'] as Map<String, dynamic>?,
      ),
      selectedText: json['selectedText'] as String?,
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ScrapElementImplToJson(_$ScrapElementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pdfId': instance.pdfId,
      'pageNumber': instance.pageNumber,
      'type': _$ElementTypeEnumMap[instance.type]!,
      'rect': const PdfRectConverter().toJson(instance.rect),
      'selectedText': instance.selectedText,
      'imagePath': instance.imagePath,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ElementTypeEnumMap = {
  ElementType.highlight: 'highlight',
  ElementType.capture: 'capture',
  ElementType.drawing: 'drawing',
  ElementType.lasso: 'lasso',
};
