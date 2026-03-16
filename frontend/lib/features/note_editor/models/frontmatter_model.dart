import 'package:freezed_annotation/freezed_annotation.dart';

part 'frontmatter_model.freezed.dart';
part 'frontmatter_model.g.dart';

@freezed
class Frontmatter with _$Frontmatter {
  const factory Frontmatter({
    required String title,
    String? linkedPdfPath,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime modifiedAt,
  }) = _Frontmatter;

  factory Frontmatter.fromJson(Map<String, dynamic> json) =>
      _$FrontmatterFromJson(json);
}
