import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../pdf_structure/services/pdf_text_extraction_service.dart';

/// Scrap board popup shown after capture/highlight.
///
/// Text field always starts EMPTY and is editable.
/// OCR checkbox extracts text via opendataloader-pdf submodule.
class ScrapBoardPopup extends ConsumerStatefulWidget {
  const ScrapBoardPopup({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.capturedImagePath,
    this.pageNumber,
    this.pdfPath,
    this.textRect,
  });

  final void Function(String memo) onConfirm;
  final VoidCallback onCancel;
  final String? capturedImagePath;
  final int? pageNumber;
  final String? pdfPath;
  final PdfRect? textRect;

  @override
  ConsumerState<ScrapBoardPopup> createState() => _ScrapBoardPopupState();
}

class _ScrapBoardPopupState extends ConsumerState<ScrapBoardPopup>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  bool _ocrRunning = false;
  bool _ocrDone = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
    // Text field starts empty — user types or uses OCR
  }

  @override
  void dispose() {
    _textController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _runOcr() async {
    final pdfPath = widget.pdfPath;
    final pageNumber = widget.pageNumber;
    if (pdfPath == null || pageNumber == null) return;

    setState(() => _ocrRunning = true);
    try {
      String? text;
      if (widget.textRect != null) {
        text = await PdfTextExtractionService.extractTextInRect(
          pdfPath,
          pageNumber,
          widget.textRect!,
        );
      } else {
        text = await PdfTextExtractionService.extractPageText(
          pdfPath,
          pageNumber,
        );
      }
      if (mounted && text != null && text.isNotEmpty) {
        _textController.text = text;
        setState(() => _ocrDone = true);
      } else if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('No text found'),
            description: Text('Could not extract text from this area.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Text extraction failed'),
            description: Text('$e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _ocrRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final hasImage = widget.capturedImagePath != null;

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onCancel,
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 520),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Header ───
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note_add_rounded,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Scrap Board',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                        const Spacer(),
                        if (widget.pageNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'P${widget.pageNumber}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ─── Capture image preview ───
                  if (hasImage)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(widget.capturedImagePath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 80,
                            color: theme.colorScheme.muted,
                            child: const Center(
                                child: Icon(Icons.broken_image, size: 24)),
                          ),
                        ),
                      ),
                    ),

                  // ─── OCR toggle ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: _ocrRunning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Checkbox(
                                  value: _ocrDone,
                                  onChanged: _ocrDone ? null : (_) => _runOcr(),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: (_ocrRunning || _ocrDone) ? null : _runOcr,
                          child: Text(
                            _ocrRunning
                                ? 'Extracting...'
                                : _ocrDone
                                    ? 'Text extracted'
                                    : 'Extract text from PDF',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Text input (starts empty, editable) ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      controller: _textController,
                      maxLines: 4,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Type or extract text...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: theme.colorScheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: theme.colorScheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),

                  // ─── Actions ───
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: widget.onCancel,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: theme.colorScheme.mutedForeground,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _ocrRunning
                              ? null
                              : () =>
                                  widget.onConfirm(_textController.text),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Save Scrap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor:
                                theme.colorScheme.primaryForeground,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
