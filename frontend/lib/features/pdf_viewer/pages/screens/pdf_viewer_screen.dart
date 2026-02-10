import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// PDF Viewer panel using pdfrx.
/// Supports text selection, page navigation, marker overlay, and area capture.
class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text(
        'PDF Viewer',
        style: ShadTheme.of(context).textTheme.h3,
      ),
    );
  }
}
