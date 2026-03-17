import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Scrap board popup shown after capture/highlight.
///
/// 기획안 슬라이드 7~9: 캡처/하이라이트 후 팝업으로 내용 작성 + 확인.
/// Replaces both MarkerEditModal and ConfirmScrapPopup.
class ScrapBoardPopup extends ConsumerStatefulWidget {
  const ScrapBoardPopup({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.capturedImagePath,
    this.highlightedText,
    this.pageNumber,
  });

  final void Function(String memo) onConfirm;
  final VoidCallback onCancel;
  final String? capturedImagePath;
  final String? highlightedText;
  final int? pageNumber;

  @override
  ConsumerState<ScrapBoardPopup> createState() => _ScrapBoardPopupState();
}

class _ScrapBoardPopupState extends ConsumerState<ScrapBoardPopup>
    with SingleTickerProviderStateMixin {
  final _memoController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

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

    // Pre-fill with highlighted text if available
    if (widget.highlightedText != null) {
      _memoController.text = widget.highlightedText!;
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Stack(
      children: [
        // Dim background
        GestureDetector(
          onTap: widget.onCancel,
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),

        // Popup card
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 500),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_add_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
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

                  // ─── Preview (capture image or highlight text) ───
                  if (widget.capturedImagePath != null)
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
                              child: Icon(Icons.broken_image, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (widget.highlightedText != null &&
                      widget.capturedImagePath == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          widget.highlightedText!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.foreground,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  // ─── Memo input ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      controller: _memoController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
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
                        // Cancel
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
                        // Confirm
                        ElevatedButton.icon(
                          onPressed: () =>
                              widget.onConfirm(_memoController.text),
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
