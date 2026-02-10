// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteImpl _$$NoteImplFromJson(Map<String, dynamic> json) => _$NoteImpl(
  id: json['id'] as String,
  frontmatter: json['frontmatter'] == null
      ? null
      : Frontmatter.fromJson(json['frontmatter'] as Map<String, dynamic>),
  content: json['content'] as String,
  markers: (json['markers'] as List<dynamic>)
      .map((e) => Marker.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$NoteImplToJson(_$NoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'frontmatter': instance.frontmatter,
      'content': instance.content,
      'markers': instance.markers,
    };
