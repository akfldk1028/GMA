import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/marker_colors.dart';

/// Callback for PDF text selection events.
/// Called when user selects text in the PDF viewer.
typedef OnTextSelectionChangeCallback = void Function({
  required int pageNumber,
  required MarkerColor color,
  String? selectedText,
  PdfRect? textRect,
});

/// PDF Viewer panel using pdfrx.
/// Supports text selection, page navigation, marker overlay, and area capture.
class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({
    super.key,
    this.controller,
    this.onTextSelectionChange,
  });

  /// Controller for programmatic PDF navigation (e.g., goToPage, goToRectInsidePage).
  /// This is used by the workspace to navigate to markers when clicked in the note editor.
  final PdfViewerController? controller;

  /// Callback invoked when text is selected in the PDF viewer.
  /// This will be wired to the workspace provider to create markers.
  final OnTextSelectionChangeCallback? onTextSelectionChange;

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
