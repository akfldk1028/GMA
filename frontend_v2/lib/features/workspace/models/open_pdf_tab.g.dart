// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_pdf_tab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OpenPdfTabImpl _$$OpenPdfTabImplFromJson(Map<String, dynamic> json) =>
    _$OpenPdfTabImpl(
      path: json['path'] as String,
      title: json['title'] as String,
      lastPageNumber: (json['lastPageNumber'] as num?)?.toInt() ?? 0,
      pdfRegistryId: json['pdfRegistryId'] as String?,
    );

Map<String, dynamic> _$$OpenPdfTabImplToJson(_$OpenPdfTabImpl instance) =>
    <String, dynamic>{
      'path': instance.path,
      'title': instance.title,
      'lastPageNumber': instance.lastPageNumber,
      'pdfRegistryId': instance.pdfRegistryId,
    };
