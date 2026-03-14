import 'package:freezed_annotation/freezed_annotation.dart';

import 'frontmatter_model.dart';
import 'marker_model.dart';

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
    required String content,
    String? filePath,
    Frontmatter? frontmatter,
    @Default([]) List<Marker> markers,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
