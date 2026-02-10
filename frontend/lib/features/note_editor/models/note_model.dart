import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

/// Note model for markdown notes with PDF marker linkage.
///
/// Notes contain markdown content with optional frontmatter YAML,
/// wiki-links, LaTeX expressions, and embedded PDF marker references.
@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String title,
    required String content,
    String? filePath,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
