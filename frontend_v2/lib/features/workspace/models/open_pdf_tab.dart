import 'package:freezed_annotation/freezed_annotation.dart';

part 'open_pdf_tab.freezed.dart';
part 'open_pdf_tab.g.dart';

@freezed
class OpenPdfTab with _$OpenPdfTab {
  const factory OpenPdfTab({
    required String path,
    required String title,
    @Default(0) int lastPageNumber,
    String? pdfRegistryId,
  }) = _OpenPdfTab;

  factory OpenPdfTab.fromJson(Map<String, dynamic> json) =>
      _$OpenPdfTabFromJson(json);
}
