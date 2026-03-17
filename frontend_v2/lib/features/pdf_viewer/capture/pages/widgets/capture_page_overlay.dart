import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:gma_app/features/pdf_viewer/capture/pages/providers/capture_provider.dart';
import 'capture_overlay.dart';

/// Per-page overlay that activates capture mode interaction.
///
/// Used inside pdfrx's [pageOverlaysBuilder] (via
/// [CapturePageOverlay.createOverlaysBuilder]). Active only when
/// [CaptureNotifier.isCapturing] is true; otherwise renders nothing so that
/// normal PDF scroll and text-selection events pass through.
class CapturePageOverlay extends ConsumerWidget {
  const CapturePageOverlay({
    super.key,
    required this.page,
    required this.pageRectInViewer,
  });

  final PdfPage page;
  final Rect pageRectInViewer;

  /// Build the [PdfPageOverlaysBuilder] for [PdfViewerParams.pageOverlaysBuilder].
  ///
  /// Adds one [CapturePageOverlay] per visible page. The overlay is a
  /// no-op when capture mode is inactive, so there is no performance cost
  /// during normal PDF navigation.
  static PdfPageOverlaysBuilder createOverlaysBuilder() {
    return (BuildContext context, Rect pageRectInViewer, PdfPage page) {
      return [
        Positioned.fill(
          child: CapturePageOverlay(
            page: page,
            pageRectInViewer: pageRectInViewer,
          ),
        ),
      ];
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCapturing = ref.watch(
      captureNotifierProvider.select((s) => s.isCapturing),
    );

    if (!isCapturing) {
      return const SizedBox.shrink();
    }

    return CaptureOverlay(
      page: page,
      pageWidth: pageRectInViewer.width,
      pageHeight: pageRectInViewer.height,
    );
  }
}
