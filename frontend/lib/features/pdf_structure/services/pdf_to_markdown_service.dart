import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'pdf_structure_service.dart';

/// Converts a PDF to Markdown using opendataloader-pdf's markdown output.
///
/// Uses the same CLI jar as [PdfStructureService] but with `--format markdown`.
/// The resulting Markdown can be inserted into a GMA note.
class PdfToMarkdownService {
  PdfToMarkdownService._();

  /// Convert a PDF to Markdown string.
  ///
  /// [pdfPath] — absolute path to the PDF file.
  /// [pages] — optional page range (e.g. "1-5"). Null = all pages.
  ///
  /// Returns the Markdown string or throws [PdfStructureException].
  static Future<String> convert(
    String pdfPath, {
    String? pages,
  }) async {
    final jarPath = await PdfStructureService.ensureJarExtracted();

    // CLI always writes to files, so use a temp directory for output.
    final tempDir = await Directory.systemTemp.createTemp('gma_pdf_md_');
    try {
      final args = <String>[
        '-jar',
        jarPath,
        pdfPath,
        '--format',
        'markdown',
        '--quiet',
        '--output-dir',
        tempDir.path,
      ];

      if (pages != null) {
        args.addAll(['--pages', pages]);
      }

      final javaExe = await PdfStructureService.resolveJavaPath();
      if (javaExe == null) {
        throw PdfStructureException(
          'Java not found. Install Java 21+ and ensure it is on PATH, '
          'or set JAVA_HOME environment variable.',
        );
      }

      debugPrint('[PdfToMarkdownService.convert] running: $javaExe ${args.join(' ')}');

      final result = await Process.run(
        javaExe,
        args,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      if (result.exitCode != 0) {
        final stderr = (result.stderr as String).trim();
        throw PdfStructureException(
          'Markdown conversion failed (exit ${result.exitCode}): $stderr',
        );
      }

      // Output file: {pdfName without .pdf}.md
      final pdfBaseName = p.basenameWithoutExtension(pdfPath);
      final mdFile = File(p.join(tempDir.path, '$pdfBaseName.md'));

      if (!await mdFile.exists()) {
        throw PdfStructureException(
          'opendataloader-pdf did not produce expected output file: ${mdFile.path}',
        );
      }

      final markdown = await mdFile.readAsString(encoding: utf8);
      debugPrint(
        '[PdfToMarkdownService.convert] output: ${markdown.length} chars',
      );
      return markdown;
    } finally {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  }
}
