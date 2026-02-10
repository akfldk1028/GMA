// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frontmatter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FrontmatterImpl _$$FrontmatterImplFromJson(Map<String, dynamic> json) =>
    _$FrontmatterImpl(
      file: json['file'] as String,
      filePath: json['filePath'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      created: DateTime.parse(json['created'] as String),
    );

Map<String, dynamic> _$$FrontmatterImplToJson(_$FrontmatterImpl instance) =>
    <String, dynamic>{
      'file': instance.file,
      'filePath': instance.filePath,
      'tags': instance.tags,
      'created': instance.created.toIso8601String(),
    };
