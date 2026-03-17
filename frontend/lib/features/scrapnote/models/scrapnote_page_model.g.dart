// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrapnote_page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScrapNotePageImpl _$$ScrapNotePageImplFromJson(Map<String, dynamic> json) =>
    _$ScrapNotePageImpl(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled',
      elementIds:
          (json['elementIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ScrapNotePageImplToJson(_$ScrapNotePageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'elementIds': instance.elementIds,
      'createdAt': instance.createdAt.toIso8601String(),
    };
