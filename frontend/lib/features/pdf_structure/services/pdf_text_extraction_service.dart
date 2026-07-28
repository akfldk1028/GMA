import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/pdf_structure_model.dart';
import 'pdf_structure_service.dart';

/// Text extraction using opendataloader-pdf submodule.
///
/// Uses the structured JSON output to extract text from specific pages
/// or regions (bounding box filtering).
class PdfTextExtractionService {
  PdfTextExtractionService._();

  /// Extract all text from a specific page.
  static Future<String?> extractPageText(
    String pdfPath,
    int pageNumber,
  ) async {
    final result = await PdfStructureService.convertPage(pdfPath, pageNumber);
    final elements = result.elementsForPage(pageNumber);
    if (elements.isEmpty) return null;

    final buffer = StringBuffer();
    for (final el in elements) {
      _collectText(el, buffer);
    }
    final text = buffer.toString().trim();
    debugPrint('[PdfTextExtraction] page $pageNumber: ${text.length} chars');
    return text.isEmpty ? null : text;
  }

  /// Extract text within a bounding box on a specific page.
  ///
  /// [rect] is in PDF coordinates (pdfrx PdfRect).
  /// Elements whose bbox overlaps the rect are included.
  static Future<String?> extractTextInRect(
    String pdfPath,
    int pageNumber,
    PdfRect rect,
  ) async {
    final result = await PdfStructureService.convertPage(pdfPath, pageNumber);
    final elements = result.elementsForPage(pageNumber);
    if (elements.isEmpty) return null;

    final buffer = StringBuffer();
    for (final el in elements) {
      _collectTextInRect(el, rect, buffer);
    }
    final text = buffer.toString().trim();
    debugPrint(
      '[PdfTextExtraction] page $pageNumber rect '
      '(${rect.left.toInt()},${rect.bottom.toInt()})-(${rect.right.toInt()},${rect.top.toInt()}): '
      '${text.length} chars',
    );
    return text.isEmpty ? null : text;
  }

  /// Check if Java + jar are available for text extraction.
  static Future<bool> isAvailable() async {
    try {
      final javaOk = await PdfStructureService.isJavaAvailable();
      if (!javaOk) return false;
      await PdfStructureService.ensureJarExtracted();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Recursively collect text content from an element and its children.
  static void _collectText(StructureElement el, StringBuffer buffer) {
    if (el.content != null && el.content!.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(el.content!);
    }
    if (el.kids != null) {
      for (final child in el.kids!) {
        _collectText(child, buffer);
      }
    }
    if (el.listItems != null) {
      for (final item in el.listItems!) {
        _collectText(item, buffer);
      }
    }
  }

  /// Recursively collect text from elements whose bbox overlaps [rect].
  static void _collectTextInRect(
    StructureElement el,
    PdfRect rect,
    StringBuffer buffer,
  ) {
    final elRect = el.toPdfRect();
    if (elRect.overlaps(rect)) {
      if (el.content != null && el.content!.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(el.content!);
      }
      // Also check nested children
      if (el.kids != null) {
        for (final child in el.kids!) {
          _collectTextInRect(child, rect, buffer);
        }
      }
      if (el.listItems != null) {
        for (final item in el.listItems!) {
          _collectTextInRect(item, rect, buffer);
        }
      }
    }
  }

}
