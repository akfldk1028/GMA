import 'dart:io';
import 'dart:ui' as ui;

import 'package:pdfrx/pdfrx.dart';

import 'ocr_registry.dart';

/// Orchestration layer: file/page → image bytes → backend → text.
class OcrService {
  /// Run OCR on an existing image file.
  static Future<String> recognizeFile(
    String imagePath, {
    String? backendId,
    String? baseUrl,
    String? model,
    String? prompt,
  }) async {
    final backend = lookupOcrBackend(backendId ?? 'ollama');
    if (backend == null) {
      throw Exception('OCR backend not found: ${backendId ?? "ollama"}');
    }

    final bytes = await File(imagePath).readAsBytes();
    return backend.recognize(
      bytes,
      baseUrl: baseUrl,
      model: model,
      prompt: prompt,
    );
  }

  /// Render a full PDF page to PNG in memory, then run OCR.
  static Future<String> recognizePage(
    PdfPage page,
    int pageNumber, {
    String? backendId,
    String? baseUrl,
    String? model,
    String? prompt,
  }) async {
    // Render full page at 2x for quality
    const renderScale = 2.0;
    final fullW = (page.width * renderScale).toInt();
    final fullH = (page.height * renderScale).toInt();

    final pdfImage = await page.render(
      x: 0,
      y: 0,
      width: fullW,
      height: fullH,
      fullWidth: fullW.toDouble(),
      fullHeight: fullH.toDouble(),
    );
    if (pdfImage == null) {
      throw Exception('Failed to render PDF page $pageNumber');
    }

    final uiImage = await pdfImage.createImage();
    pdfImage.dispose();

    final byteData = await uiImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    uiImage.dispose();

    if (byteData == null) {
      throw Exception('Failed to encode page $pageNumber as PNG');
    }

    final imageBytes = byteData.buffer.asUint8List();

    final backend = lookupOcrBackend(backendId ?? 'ollama');
    if (backend == null) {
      throw Exception('OCR backend not found: ${backendId ?? "ollama"}');
    }

    return backend.recognize(
      imageBytes,
      baseUrl: baseUrl,
      model: model,
      prompt: prompt,
    );
  }
}
