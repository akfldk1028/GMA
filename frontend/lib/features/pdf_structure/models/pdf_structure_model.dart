import 'package:pdfrx/pdfrx.dart';

/// Root result from opendataloader-pdf JSON output.
class PdfStructureResult {
  final String fileName;
  final int numberOfPages;
  final String? author;
  final String? title;
  final String? creationDate;
  final String? modificationDate;
  final List<StructureElement> kids;

  const PdfStructureResult({
    required this.fileName,
    required this.numberOfPages,
    this.author,
    this.title,
    this.creationDate,
    this.modificationDate,
    this.kids = const [],
  });

  factory PdfStructureResult.fromJson(Map<String, dynamic> json) {
    return PdfStructureResult(
      fileName: json['file name'] as String? ?? '',
      numberOfPages: json['number of pages'] as int? ?? 0,
      author: json['author'] as String?,
      title: json['title'] as String?,
      creationDate: json['creation date'] as String?,
      modificationDate: json['modification date'] as String?,
      kids: (json['kids'] as List<dynamic>?)
              ?.map((e) => StructureElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Get all elements on a specific page.
  List<StructureElement> elementsForPage(int pageNumber) =>
      kids.where((e) => e.pageNumber == pageNumber).toList();

  /// Get only headings, sorted by page then position.
  List<StructureElement> get headings =>
      kids.where((e) => e.type == 'heading').toList();
}

/// A single content element extracted from the PDF.
///
/// Maps to opendataloader-pdf's contentElement (paragraph, heading, table, etc.).
/// Bounding box is [left, bottom, right, top] in PDF coordinates.
class StructureElement {
  final String type;
  final int pageNumber;
  final List<double> boundingBox;
  final int? id;
  final String? level;
  // Text properties
  final String? content;
  final String? font;
  final double? fontSize;
  final String? textColor;
  final bool? hiddenText;
  // Heading
  final int? headingLevel;
  // Caption
  final int? linkedContentId;
  // Table
  final int? numberOfRows;
  final int? numberOfColumns;
  final List<StructureTableRow>? rows;
  // List
  final String? numberingStyle;
  final int? numberOfListItems;
  final List<StructureElement>? listItems;
  // Image
  final String? source;
  final String? data;
  final String? format;
  // Nested children
  final List<StructureElement>? kids;

  const StructureElement({
    required this.type,
    required this.pageNumber,
    required this.boundingBox,
    this.id,
    this.level,
    this.content,
    this.font,
    this.fontSize,
    this.textColor,
    this.hiddenText,
    this.headingLevel,
    this.linkedContentId,
    this.numberOfRows,
    this.numberOfColumns,
    this.rows,
    this.numberingStyle,
    this.numberOfListItems,
    this.listItems,
    this.source,
    this.data,
    this.format,
    this.kids,
  });

  factory StructureElement.fromJson(Map<String, dynamic> json) {
    return StructureElement(
      type: json['type'] as String? ?? 'unknown',
      pageNumber: json['page number'] as int? ?? 0,
      boundingBox: (json['bounding box'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0, 0, 0, 0],
      id: json['id'] as int?,
      level: json['level'] as String?,
      content: json['content'] as String?,
      font: json['font'] as String?,
      fontSize: (json['font size'] as num?)?.toDouble(),
      textColor: json['text color'] as String?,
      hiddenText: json['hidden text'] as bool?,
      headingLevel: json['heading level'] as int?,
      linkedContentId: json['linked content id'] as int?,
      numberOfRows: json['number of rows'] as int?,
      numberOfColumns: json['number of columns'] as int?,
      rows: (json['rows'] as List<dynamic>?)
          ?.map((e) => StructureTableRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      numberingStyle: json['numbering style'] as String?,
      numberOfListItems: json['number of list items'] as int?,
      listItems: (json['list items'] as List<dynamic>?)
          ?.map((e) => StructureElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      source: json['source'] as String?,
      data: json['data'] as String?,
      format: json['format'] as String?,
      kids: (json['kids'] as List<dynamic>?)
          ?.map((e) => StructureElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert opendataloader bbox [left, bottom, right, top] to pdfrx PdfRect.
  ///
  /// opendataloader: [left, bottom, right, top] (PDF coords, Y-up)
  /// pdfrx PdfRect:  (left, top, right, bottom) where top >= bottom
  PdfRect toPdfRect() {
    if (boundingBox.length < 4) return const PdfRect(0, 0, 0, 0);
    return PdfRect(boundingBox[0], boundingBox[3], boundingBox[2], boundingBox[1]);
  }

  /// Short label for display.
  String get displayLabel {
    switch (type) {
      case 'heading':
        final lvl = headingLevel ?? 1;
        final text = _truncate(content, 40);
        return 'H$lvl: $text';
      case 'paragraph':
        return _truncate(content, 50);
      case 'table':
        return 'Table ${numberOfRows ?? 0}x${numberOfColumns ?? 0}';
      case 'list':
        return 'List (${numberOfListItems ?? 0} items)';
      case 'image':
        return 'Image';
      case 'caption':
        return 'Caption: ${_truncate(content, 30)}';
      case 'formula':
        return 'Formula: ${_truncate(content, 30)}';
      default:
        return type;
    }
  }

  static String _truncate(String? text, int maxLen) {
    if (text == null || text.isEmpty) return '';
    return text.length > maxLen ? '${text.substring(0, maxLen)}...' : text;
  }
}

/// A table row from opendataloader-pdf output.
class StructureTableRow {
  final String type;
  final int rowNumber;
  final List<StructureTableCell> cells;

  const StructureTableRow({
    required this.type,
    required this.rowNumber,
    this.cells = const [],
  });

  factory StructureTableRow.fromJson(Map<String, dynamic> json) {
    return StructureTableRow(
      type: json['type'] as String? ?? 'table row',
      rowNumber: json['row number'] as int? ?? 0,
      cells: (json['cells'] as List<dynamic>?)
              ?.map((e) =>
                  StructureTableCell.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// A table cell from opendataloader-pdf output.
class StructureTableCell {
  final String type;
  final int pageNumber;
  final List<double> boundingBox;
  final int rowNumber;
  final int columnNumber;
  final int rowSpan;
  final int columnSpan;
  final List<StructureElement> kids;

  const StructureTableCell({
    required this.type,
    required this.pageNumber,
    required this.boundingBox,
    required this.rowNumber,
    required this.columnNumber,
    this.rowSpan = 1,
    this.columnSpan = 1,
    this.kids = const [],
  });

  factory StructureTableCell.fromJson(Map<String, dynamic> json) {
    return StructureTableCell(
      type: json['type'] as String? ?? 'table cell',
      pageNumber: json['page number'] as int? ?? 0,
      boundingBox: (json['bounding box'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0, 0, 0, 0],
      rowNumber: json['row number'] as int? ?? 0,
      columnNumber: json['column number'] as int? ?? 0,
      rowSpan: json['row span'] as int? ?? 1,
      columnSpan: json['column span'] as int? ?? 1,
      kids: (json['kids'] as List<dynamic>?)
              ?.map(
                  (e) => StructureElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
