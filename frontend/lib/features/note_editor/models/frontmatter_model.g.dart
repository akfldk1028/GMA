// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frontmatter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FrontmatterImpl _$$FrontmatterImplFromJson(Map<String, dynamic> json) =>
    _$FrontmatterImpl(
      title: json['title'] as String,
      linkedPdfPath: json['linkedPdfPath'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );

Map<String, dynamic> _$$FrontmatterImplToJson(_$FrontmatterImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'linkedPdfPath': instance.linkedPdfPath,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
    };
