// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteImpl _$$NoteImplFromJson(Map<String, dynamic> json) => _$NoteImpl(
  id: json['id'] as String,
  content: json['content'] as String,
  filePath: json['filePath'] as String?,
  frontmatter: json['frontmatter'] == null
      ? null
      : Frontmatter.fromJson(json['frontmatter'] as Map<String, dynamic>),
  markers:
      (json['markers'] as List<dynamic>?)
          ?.map((e) => Marker.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$NoteImplToJson(_$NoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'filePath': instance.filePath,
      'frontmatter': instance.frontmatter,
      'markers': instance.markers,
    };
