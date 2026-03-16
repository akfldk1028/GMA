import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../workspace/models/pdf_marker_model.dart';

part 'element_model.freezed.dart';
part 'element_model.g.dart';

/// Type of scrapnote element
enum ElementType {
  highlight,
  capture,
  drawing,
}

/// ScrapElement represents an element in a scrapnote (renamed to avoid dart:core Element conflict)
@freezed
class ScrapElement with _$ScrapElement {
  const factory ScrapElement({
    required String id,
    required String pdfId,
    required int pageNumber,
    required ElementType type,
    @PdfRectConverter() PdfRect? rect,
    String? selectedText,
    String? imagePath,
    required DateTime createdAt,
  }) = _ScrapElement;

  factory ScrapElement.fromJson(Map<String, dynamic> json) =>
      _$ScrapElementFromJson(json);
}
