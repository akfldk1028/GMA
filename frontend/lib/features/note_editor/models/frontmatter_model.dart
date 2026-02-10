import 'package:freezed_annotation/freezed_annotation.dart';

part 'frontmatter_model.freezed.dart';
part 'frontmatter_model.g.dart';

@freezed
class Frontmatter with _$Frontmatter {
  const factory Frontmatter({
    required String file,
    required String filePath,
    required List<String> tags,
    required DateTime created,
  }) = _Frontmatter;

  factory Frontmatter.fromJson(Map<String, dynamic> json) =>
      _$FrontmatterFromJson(json);
}
