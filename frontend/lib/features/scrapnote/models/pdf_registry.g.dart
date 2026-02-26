// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_registry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PdfRegistryEntryImpl _$$PdfRegistryEntryImplFromJson(
  Map<String, dynamic> json,
) => _$PdfRegistryEntryImpl(
  id: json['id'] as String,
  path: json['path'] as String,
  registeredAt: DateTime.parse(json['registeredAt'] as String),
);

Map<String, dynamic> _$$PdfRegistryEntryImplToJson(
  _$PdfRegistryEntryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'path': instance.path,
  'registeredAt': instance.registeredAt.toIso8601String(),
};
