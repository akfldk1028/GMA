import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_metadata_model.freezed.dart';
part 'note_metadata_model.g.dart';

@freezed
class NoteMetadata with _$NoteMetadata {
  const NoteMetadata._();

  const factory NoteMetadata({
    required String id,
    required String title,
    required String filePath,
    required DateTime createdAt,
    required DateTime modifiedAt,
    String? linkedPdfPath,
    String? previewText,
  }) = _NoteMetadata;

  factory NoteMetadata.fromJson(Map<String, dynamic> json) =>
      _$NoteMetadataFromJson(json);

  /// Computed property to check if this note has a linked PDF
  bool get hasLinkedPdf => linkedPdfPath != null && linkedPdfPath!.isNotEmpty;
}
