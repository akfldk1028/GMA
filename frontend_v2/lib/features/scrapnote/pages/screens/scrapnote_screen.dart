import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../drawing/pages/widgets/drawing_toolbar.dart';
import '../widgets/scrapnote_canvas.dart';

/// Full-screen scrapnote canvas view linked to a specific PDF file.
///
/// Displays the DrawingToolbar at the top and the ScrapnoteCanvas below.
/// Navigate here via GoRouter with a `pdfPath` query parameter.
class ScrapnoteScreen extends ConsumerWidget {
  const ScrapnoteScreen({super.key, required this.pdfPath});

  final String pdfPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrapnote'),
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // TODO(U2): currentPageNumber is hardcoded to 1. To fix this properly,
          // the scrapnote view needs access to a page-tracking provider that
          // reflects the current page of the associated PDF. This requires
          // coordination with the PDF viewer state (e.g. pdfDocumentNotifierProvider)
          // when the scrapnote is linked to an open PDF document.
          DrawingToolbar(
            activeDocumentPath: pdfPath,
            currentPageNumber: 1,
          ),
          Expanded(
            child: ScrapnoteCanvas(pdfPath: pdfPath),
          ),
        ],
      ),
    );
  }
}
