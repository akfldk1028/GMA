import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_thumbnail_provider.g.dart';

/// Renders the PDF first-page thumbnail as PNG bytes, caching to disk so
/// subsequent app launches don't re-render. Cache key = SHA1 of the PDF
/// path. Cached file is invalidated when the source PDF mtime is newer
/// than the cached PNG.
///
/// `keepAlive: true` so the in-memory bytes survive list-rebuilds when
/// the user scrolls or filters the dashboard.
@Riverpod(keepAlive: true)
Future<Uint8List?> pdfThumbnail(PdfThumbnailRef ref, String pdfPath) async {
  if (kIsWeb) return null;
  try {
    final pdfFile = File(pdfPath);
    if (!await pdfFile.exists()) return null;

    final cacheFile = await _cacheFileFor(pdfPath);
    final pdfMtime = (await pdfFile.stat()).modified;

    if (await cacheFile.exists()) {
      final cacheMtime = (await cacheFile.stat()).modified;
      if (cacheMtime.isAfter(pdfMtime)) {
        return await cacheFile.readAsBytes();
      }
    }

    final bytes = await _renderThumbnail(pdfPath);
    if (bytes == null) return null;
    try {
      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('[pdfThumbnail] cache write failed: $e');
    }
    return bytes;
  } catch (e) {
    debugPrint('[pdfThumbnail] failed for $pdfPath: $e');
    return null;
  }
}

/// Render thumbnail PNG bytes for the first page of the PDF.
Future<Uint8List?> _renderThumbnail(String pdfPath) async {
  final doc = await PdfDocument.openFile(pdfPath);
  try {
    if (doc.pages.isEmpty) return null;
    final page = doc.pages[0];

    const thumbWidth = 200.0;
    final scale = thumbWidth / page.width;
    final thumbHeight = (page.height * scale).roundToDouble();

    final pdfImage = await page.render(
      fullWidth: thumbWidth,
      fullHeight: thumbHeight,
    );
    if (pdfImage == null) return null;

    ui.Image? uiImage;
    try {
      uiImage = await pdfImage.createImage();
    } finally {
      pdfImage.dispose();
    }

    final byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.png);
    uiImage.dispose();
    return byteData?.buffer.asUint8List();
  } finally {
    await doc.dispose();
  }
}

/// Resolve the on-disk cache file path for the given PDF path. Stored
/// under `<docs>/.thumb_cache/<hash>.png`.
///
/// Uses a deterministic FNV-1a 64-bit hash on the path so the same PDF
/// always maps to the same cache file. (Plain `String.hashCode` is not
/// stable across runs.)
Future<File> _cacheFileFor(String pdfPath) async {
  final docsDir = await getApplicationDocumentsDirectory();
  return File(p.join(docsDir.path, '.thumb_cache', '${_fnv1a(pdfPath)}.png'));
}

String _fnv1a(String s) {
  // 64-bit FNV-1a, returned as 16-char hex.
  const offset = 0xcbf29ce484222325;
  const prime = 0x100000001b3;
  var hash = offset;
  for (final c in s.codeUnits) {
    hash ^= c;
    hash = (hash * prime) & 0xffffffffffffffff;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
