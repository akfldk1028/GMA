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
    String? folderId,
    @Default(false) bool isPinned,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
    /// Path to the first capture/lasso image referenced in the note body.
    /// Used as a thumbnail fallback when the note has no linked PDF.
    String? coverImagePath,
  }) = _NoteMetadata;

  factory NoteMetadata.fromJson(Map<String, dynamic> json) =>
      _$NoteMetadataFromJson(json);

  bool get hasLinkedPdf => linkedPdfPath != null && linkedPdfPath!.isNotEmpty;
  bool get hasCoverImage =>
      coverImagePath != null && coverImagePath!.isNotEmpty;
}
