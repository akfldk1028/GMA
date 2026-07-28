import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/marker_colors.dart';
import '../../scrapnote/models/scrapnote_canvas_model.dart';
import '../../scrapnote/pages/providers/scrapnote_canvas_provider.dart';
import '../../scrapnote/providers/scrapnote_service_provider.dart';
import '../../scrapnote/services/scrap_insertion_service.dart';
import '../../pdf_viewer/pages/providers/pdf_marker_provider.dart';
import '../models/pdf_marker_model.dart';

/// Helper methods extracted from WorkspaceProvider.createMarker.
class MarkerCreationService {
  const MarkerCreationService._();

  /// Persist marker to Hive so PdfPageOverlay can render highlights.
  static Future<void> persistToHive(
    Ref ref, {
    required PdfMarker marker,
    required MarkerColor color,
  }) async {
    try {
      await ref.read(pdfMarkerStateProvider.notifier).createMarker(
            id: marker.id,
            pageNumber: marker.pageNumber,
            color: color,
            selectedText: marker.selectedText,
            textRect: marker.textRect,
            lineRects: marker.lineRects,
            capturedImagePath: marker.capturedImagePath,
          );
    } catch (e) {
      debugPrint('[MarkerCreationService] Hive error: $e');
    }
  }

  /// Create CanvasElement on the scrapnote canvas (fire-and-forget).
  /// Uses PdfRect for aspect ratio instead of heavy image decoding.
  static Future<void> createCanvasElement(
    Ref ref, {
    required PdfMarker marker,
    required String pdfPath,
    String? capturedImagePath,
    String? selectedText,
    required MarkerColor color,
  }) async {
    try {
      final service = await ref.read(scrapnoteServiceProvProvider.future);
      final scrapnoteId = await service.getOrCreateScrapnote(pdfPath);

      final canvasData = ref
          .read(scrapnoteCanvasStateProvider(scrapnoteId))
          .valueOrNull;
      final existingElements = canvasData?.elements ?? [];
      final pos = ScrapInsertionService.calculateAutoPosition(
        existingElements,
      );

      double cardWidth;
      double cardHeight;
      if (capturedImagePath != null) {
        if (marker.textRect != null) {
          final r = marker.textRect!;
          final rectW = (r.right - r.left).abs();
          final rectH = (r.top - r.bottom).abs();
          if (rectW > 0 && rectH > 0) {
            const maxDim = 400.0;
            if (rectW >= rectH) {
              cardWidth = maxDim;
              cardHeight = maxDim * rectH / rectW;
            } else {
              cardHeight = maxDim;
              cardWidth = maxDim * rectW / rectH;
            }
          } else {
            cardWidth = 300;
            cardHeight = 300;
          }
        } else {
          cardWidth = 300;
          cardHeight = 300;
        }
      } else {
        cardWidth = 500;
        cardHeight = 80;
      }

      final canvasElement = CanvasElement(
        id: marker.id,
        type: capturedImagePath != null
            ? CanvasElementType.capture
            : CanvasElementType.highlight,
        x: pos.x,
        y: pos.y,
        width: cardWidth,
        height: cardHeight,
        imagePath: capturedImagePath,
        selectedText: selectedText,
        colorValue: color.color.toARGB32(),
        sourcePageNumber: marker.pageNumber,
        sourcePdfPath: pdfPath,
        createdAt: DateTime.now(),
      );

      ref
          .read(scrapnoteCanvasStateProvider(scrapnoteId).notifier)
          .addElement(canvasElement);
    } catch (e) {
      debugPrint('[MarkerCreationService] CanvasElement error: $e');
    }
  }
}
