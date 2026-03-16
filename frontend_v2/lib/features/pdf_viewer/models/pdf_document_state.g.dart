// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_document_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PdfDocumentStateImpl _$$PdfDocumentStateImplFromJson(
  Map<String, dynamic> json,
) => _$PdfDocumentStateImpl(
  document: const _PdfDocumentConverter().fromJson(
    json['document'] as Map<String, dynamic>?,
  ),
  currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
  isLoading: json['isLoading'] as bool? ?? false,
  error: json['error'] as String?,
);

Map<String, dynamic> _$$PdfDocumentStateImplToJson(
  _$PdfDocumentStateImpl instance,
) => <String, dynamic>{
  'document': const _PdfDocumentConverter().toJson(instance.document),
  'currentPage': instance.currentPage,
  'totalPages': instance.totalPages,
  'isLoading': instance.isLoading,
  'error': instance.error,
};
