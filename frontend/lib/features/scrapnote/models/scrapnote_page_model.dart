import 'package:freezed_annotation/freezed_annotation.dart';

part 'scrapnote_page_model.freezed.dart';
part 'scrapnote_page_model.g.dart';

/// A page within a ScrapNote. Each page holds a list of element IDs.
///
/// 기획안 슬라이드 16: 스크랩 노트 페이지 (드롭다운, 스크랩 개수, 이름 변경)
@freezed
class ScrapNotePage with _$ScrapNotePage {
  const factory ScrapNotePage({
    required String id,
    @Default('Untitled') String name,
    @Default([]) List<String> elementIds,
    required DateTime createdAt,
  }) = _ScrapNotePage;

  factory ScrapNotePage.fromJson(Map<String, dynamic> json) =>
      _$ScrapNotePageFromJson(json);
}
