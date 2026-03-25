import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/pdf_structure_model.dart';

/// Service wrapping the opendataloader-pdf CLI (Java jar).
///
/// Calls `java -jar opendataloader-pdf-cli.jar <pdf> --format json --quiet`
/// via [Process.run] and parses the JSON output into [PdfStructureResult].
///
/// Jar location strategy (in order):
/// 1. Custom path set via [setCustomJarPath] (user settings)
/// 2. `bin/opendataloader-pdf-cli.jar` next to the running executable
/// 3. `vendor/opendataloader-pdf/java/opendataloader-pdf-cli/target/*.jar`
///    (development: directly from submodule Maven build output)
class PdfStructureService {
  PdfStructureService._();

  static String? _customJarPath;

  /// In-memory cache: PDF path → parsed result.
  static final Map<String, PdfStructureResult> _cache = {};

  /// Resolved absolute path to java executable (cached after first lookup).
  static String? _javaPath;

  /// Resolve the java executable path.
  /// On Windows, `Process.run('java', ...)` can fail when launched from
  /// certain shells (e.g. Git Bash) that don't inherit the system PATH.
  /// We try `java` first, then fall back to `where java` (Windows) /
  /// `which java` (Unix) to resolve the absolute path.
  /// Public accessor for other services that also need java.
  static Future<String?> resolveJavaPath() => _resolveJavaPath();

  static Future<String?> _resolveJavaPath() async {
    if (_javaPath != null) return _javaPath;

    // Try direct invocation first
    try {
      final result = await Process.run('java', ['-version']);
      if (result.exitCode == 0) {
        _javaPath = 'java';
        return _javaPath;
      }
    } catch (_) {}

    // Fall back: resolve absolute path via where/which
    try {
      final locator = Platform.isWindows ? 'where' : 'which';
      final result = await Process.run(locator, ['java']);
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim().split('\n').first.trim();
        if (path.isNotEmpty) {
          _javaPath = path;
          debugPrint('[PdfStructureService] resolved java at: $path');
          return _javaPath;
        }
      }
    } catch (_) {}

    // Last resort: check JAVA_HOME environment variable
    final javaHome = Platform.environment['JAVA_HOME'];
    if (javaHome != null && javaHome.isNotEmpty) {
      final javaBin = p.join(javaHome, 'bin', Platform.isWindows ? 'java.exe' : 'java');
      if (await File(javaBin).exists()) {
        _javaPath = javaBin;
        debugPrint('[PdfStructureService] resolved java via JAVA_HOME: $javaBin');
        return _javaPath;
      }
    }

    return null;
  }

  /// Check if Java is available on this system.
  static Future<bool> isJavaAvailable() async {
    return await _resolveJavaPath() != null;
  }

  /// Resolve the jar path. Tries multiple locations.
  ///
  /// Public so [PdfToMarkdownService] can reuse the same jar path.
  static Future<String> ensureJarExtracted() async {
    // 1. Custom path from user settings
    if (_customJarPath != null && await File(_customJarPath!).exists()) {
      return _customJarPath!;
    }

    // 2. Next to executable: <exe_dir>/bin/opendataloader-pdf-cli.jar
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final prodJar = p.join(exeDir, 'bin', 'opendataloader-pdf-cli.jar');
    if (await File(prodJar).exists()) {
      debugPrint('[PdfStructureService] jar found at: $prodJar');
      return prodJar;
    }

    // 3. Development: submodule Maven build output
    //    frontend/vendor/opendataloader-pdf/java/opendataloader-pdf-cli/target/
    final projectRoot = _findProjectRoot(exeDir);
    if (projectRoot != null) {
      final targetDir = Directory(p.join(
        projectRoot,
        'vendor',
        'opendataloader-pdf',
        'java',
        'opendataloader-pdf-cli',
        'target',
      ));
      if (await targetDir.exists()) {
        final jars = await targetDir
            .list()
            .where((f) =>
                f is File &&
                f.path.endsWith('.jar') &&
                !f.path.contains('sources') &&
                !f.path.contains('javadoc'))
            .toList();
        if (jars.isNotEmpty) {
          final jarPath = jars.first.path;
          debugPrint('[PdfStructureService] dev jar found at: $jarPath');
          return jarPath;
        }
      }
    }

    throw PdfStructureException(
      'opendataloader-pdf-cli.jar not found. '
      'Run scripts/build_opendataloader to build it, '
      'or set the path in Settings.',
    );
  }

  /// Try to find the Flutter project root (where pubspec.yaml lives).
  /// Walks up from the given directory.
  static String? _findProjectRoot(String from) {
    var dir = Directory(from);
    for (var i = 0; i < 10; i++) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) return dir.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return null;
  }

  /// Allow setting a custom jar path (e.g. from user settings).
  static void setCustomJarPath(String? path) {
    if (path != null && path.isNotEmpty) {
      _customJarPath = path;
      debugPrint('[PdfStructureService] custom jar path: $path');
    }
  }

  /// Convert a PDF file to structured JSON using opendataloader-pdf.
  ///
  /// [pdfPath] — absolute path to the PDF file.
  /// [pages] — optional page range (e.g. "1", "1,3,5-7"). Null = all pages.
  /// [useCache] — if true, returns cached result if available.
  ///
  /// Returns parsed [PdfStructureResult] or throws on failure.
  static Future<PdfStructureResult> convert(
    String pdfPath, {
    String? pages,
    bool useCache = true,
  }) async {
    final cacheKey = '$pdfPath:${pages ?? "all"}';

    if (useCache && _cache.containsKey(cacheKey)) {
      debugPrint('[PdfStructureService.convert] cache hit: $cacheKey');
      return _cache[cacheKey]!;
    }

    final jarPath = await ensureJarExtracted();

    // CLI always writes to files, so use a temp directory for output.
    final tempDir = await Directory.systemTemp.createTemp('gma_pdf_json_');
    try {
      final args = <String>[
        '-jar',
        jarPath,
        pdfPath,
        '--format',
        'json',
        '--quiet',
        '--output-dir',
        tempDir.path,
      ];

      if (pages != null) {
        args.addAll(['--pages', pages]);
      }

      final javaExe = await _resolveJavaPath();
      if (javaExe == null) {
        throw PdfStructureException(
          'Java not found. Install Java 21+ and ensure it is on PATH, '
          'or set JAVA_HOME environment variable.',
        );
      }

      debugPrint('[PdfStructureService.convert] running: $javaExe ${args.join(' ')}');

      final result = await Process.run(
        javaExe,
        args,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      if (result.exitCode != 0) {
        final stderr = (result.stderr as String).trim();
        debugPrint('[PdfStructureService.convert] error (exit ${result.exitCode}): $stderr');
        throw PdfStructureException(
          'opendataloader-pdf failed (exit ${result.exitCode}): $stderr',
        );
      }

      // Output file: {pdfName without .pdf}.json
      final pdfBaseName = p.basenameWithoutExtension(pdfPath);
      final jsonFile = File(p.join(tempDir.path, '$pdfBaseName.json'));

      if (!await jsonFile.exists()) {
        throw PdfStructureException(
          'opendataloader-pdf did not produce expected output file: ${jsonFile.path}',
        );
      }

      final jsonString = await jsonFile.readAsString(encoding: utf8);

      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final parsed = PdfStructureResult.fromJson(json);
        _cache[cacheKey] = parsed;
        debugPrint(
          '[PdfStructureService.convert] success: ${parsed.numberOfPages} pages, '
          '${parsed.kids.length} elements',
        );
        return parsed;
      } catch (e) {
        debugPrint('[PdfStructureService.convert] JSON parse error: $e');
        throw PdfStructureException('Failed to parse opendataloader-pdf output: $e');
      }
    } finally {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  }

  /// Convert a single page (convenience wrapper).
  static Future<PdfStructureResult> convertPage(
    String pdfPath,
    int pageNumber,
  ) =>
      convert(pdfPath, pages: '$pageNumber');

  /// Clear the in-memory cache (e.g. when closing a PDF).
  static void clearCache([String? pdfPath]) {
    if (pdfPath != null) {
      _cache.removeWhere((key, _) => key.startsWith(pdfPath));
    } else {
      _cache.clear();
    }
  }
}

/// Exception thrown when opendataloader-pdf CLI fails.
class PdfStructureException implements Exception {
  final String message;
  const PdfStructureException(this.message);

  @override
  String toString() => 'PdfStructureException: $message';
}
