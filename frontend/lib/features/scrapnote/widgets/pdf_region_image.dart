import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../pdf_viewer/drawing/models/drawing_model.dart';
import '../../pdf_viewer/drawing/pages/widgets/stroke_painter.dart';

/// Cache: renders each PDF page ONCE as a full-page image.
/// All scrap entries on the same page share the cached image.
/// This turns 44 render calls into ~3 (one per page).
class PdfPageImageCache {
  PdfPageImageCache(this.controller, {this.renderScale = 2.0});

  final PdfViewerController controller;
  final double renderScale;

  // page number → rendered full-page image
  final Map<int, ui.Image> _cache = {};
  // page number → in-flight future (prevents duplicate renders)
  final Map<int, Future<ui.Image?>> _pending = {};
  // page number → page dimensions in PDF points
  final Map<int, Size> _pageSizes = {};

  /// Get (or render) a full page image. Returns cached if available.
  Future<ui.Image?> getPageImage(int pageNumber) async {
    if (_cache.containsKey(pageNumber)) return _cache[pageNumber];
    if (_pending.containsKey(pageNumber)) return _pending[pageNumber];

    final future = _renderPage(pageNumber);
    _pending[pageNumber] = future;
    final result = await future;
    _pending.remove(pageNumber);
    if (result != null) _cache[pageNumber] = result;
    return result;
  }

  /// Get the PDF page size in points (for coordinate conversion).
  Size? getPageSize(int pageNumber) => _pageSizes[pageNumber];

  Future<ui.Image?> _renderPage(int pageNumber) async {
    try {
      // Wait for controller to be ready (document loaded)
      if (!controller.isReady) {
        for (var i = 0; i < 20; i++) {
          await Future.delayed(const Duration(milliseconds: 200));
          if (controller.isReady) break;
        }
        if (!controller.isReady) return null;
      }
      return await controller.useDocument<ui.Image?>((doc) async {
        if (pageNumber < 1 || pageNumber > doc.pages.length) return null;
        final page = doc.pages[pageNumber - 1];
        _pageSizes[pageNumber] = Size(page.width, page.height);

        final fullW = page.width * renderScale;
        final fullH = page.height * renderScale;

        final pdfImg = await page.render(
          fullWidth: fullW,
          fullHeight: fullH,
        );
        if (pdfImg == null) return null;
        try {
          return await pdfImg.createImage();
        } finally {
          pdfImg.dispose();
        }
      });
    } catch (e) {
      debugPrint('[PdfPageImageCache] page $pageNumber render: $e');
      return null;
    }
  }

  void dispose() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
    _pending.clear();
  }
}

/// Shows a cropped region of a cached full-page PDF image.
///
/// Uses [PdfPageImageCache] to render the page once, then clips the
/// PdfRect region in Flutter — zero extra render calls per scrap.
class PdfRegionImage extends StatefulWidget {
  const PdfRegionImage({
    super.key,
    required this.cache,
    required this.pageNumber,
    required this.rect,
    this.capturePath,
    this.annotations,
    this.maxHeight = 100.0,
  });

  final PdfPageImageCache cache;
  final int pageNumber;
  final PdfRect rect;
  final String? capturePath;
  final List<DrawingStroke>? annotations;
  final double maxHeight;

  @override
  State<PdfRegionImage> createState() => _PdfRegionImageState();
}

class _PdfRegionImageState extends State<PdfRegionImage> {
  ui.Image? _pageImage;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(PdfRegionImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _pageImage = null;
      _load();
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    try {
      final img = await widget.cache.getPageImage(widget.pageNumber);
      if (mounted) {
        setState(() {
          _pageImage = img;
          _failed = img == null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _failed = true);
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pageImage == null) {
      if (_failed) {
        // Cross-PDF fallback: show capture image directly if available
        if (widget.capturePath != null && !kIsWeb) {
          final file = File(widget.capturePath!);
          if (file.existsSync()) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.maxHeight),
                child: Image.file(file, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackText()),
              ),
            );
          }
        }
        return _fallbackText();
      }
      return Container(height: 20, color: Colors.grey.shade50,
          child: const Center(child: SizedBox(width: 10, height: 10,
              child: CircularProgressIndicator(strokeWidth: 1))));
    }

    // Calculate crop rect in pixel coordinates
    final pageSize = widget.cache.getPageSize(widget.pageNumber);
    if (pageSize == null) return const SizedBox.shrink();
    final scale = widget.cache.renderScale;
    final imgW = _pageImage!.width.toDouble();
    final imgH = _pageImage!.height.toDouble();

    // PdfRect (bottom-left, Y up) → pixel (top-left, Y down)
    final selTop = (pageSize.height - widget.rect.top) * scale;
    final selBottom = (pageSize.height - widget.rect.bottom) * scale;
    final selLeft = widget.rect.left * scale;
    final selRight = widget.rect.right * scale;

    // Crop to actual selection area with small padding for context
    final selWidth = (selRight - selLeft).abs();
    final selHeight = (selBottom - selTop).abs();
    final hPad = selWidth * 0.08; // 8% horizontal padding
    final vPad = selHeight * 0.08; // 8% vertical padding

    final cropRect = Rect.fromLTRB(
      (selLeft - hPad).clamp(0, imgW),
      (selTop - vPad).clamp(0, imgH),
      (selRight + hPad).clamp(0, imgW),
      (selBottom + vPad).clamp(0, imgH),
    );

    if (cropRect.width <= 0 || cropRect.height <= 0) {
      return const SizedBox.shrink();
    }

    final ar = cropRect.width / cropRect.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        child: AspectRatio(
          aspectRatio: ar,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base: cropped PDF page region (full width + context)
              CustomPaint(
                painter: _CropPainter(
                  image: _pageImage!,
                  srcRect: cropRect,
                ),
              ),
              // Overlay: user's pen strokes / highlights
              if (widget.capturePath != null && !kIsWeb)
                _CaptureOverlay(path: widget.capturePath!),
              // Annotation strokes overlay
              if (widget.annotations != null && widget.annotations!.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: StrokePainter(
                        strokes: widget.annotations!,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackText() {
    return SizedBox(height: 20, child: Text('P${widget.pageNumber}',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade400)));
  }
}

/// Paints a cropped region of a full-page image with optional highlight.
class _CropPainter extends CustomPainter {
  _CropPainter({
    required this.image,
    required this.srcRect,
  });
  final ui.Image image;
  final Rect srcRect;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      srcRect,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.image != image || old.srcRect != srcRect;
}

/// Overlays capture image (pen strokes) on top of PDF region.
class _CaptureOverlay extends StatelessWidget {
  const _CaptureOverlay({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (!file.existsSync()) return const SizedBox.shrink();
    return Opacity(
      opacity: 0.5,
      child: Image.file(file, fit: BoxFit.fill,
          errorBuilder: (_, __, ___) => const SizedBox.shrink()),
    );
  }
}
