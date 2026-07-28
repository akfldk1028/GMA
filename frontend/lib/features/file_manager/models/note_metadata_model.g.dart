// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_metadata_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteMetadataImpl _$$NoteMetadataImplFromJson(Map<String, dynamic> json) =>
    _$NoteMetadataImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      linkedPdfPath: json['linkedPdfPath'] as String?,
      previewText: json['previewText'] as String?,
      folderId: json['folderId'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      coverImagePath: json['coverImagePath'] as String?,
    );

Map<String, dynamic> _$$NoteMetadataImplToJson(_$NoteMetadataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'filePath': instance.filePath,
      'createdAt': instance.createdAt.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'linkedPdfPath': instance.linkedPdfPath,
      'previewText': instance.previewText,
      'folderId': instance.folderId,
      'isPinned': instance.isPinned,
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'coverImagePath': instance.coverImagePath,
    };
