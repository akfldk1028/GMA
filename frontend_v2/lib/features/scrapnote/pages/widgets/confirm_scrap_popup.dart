import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/constants/design_tokens.dart';

/// Auto-dismiss duration for the confirmation popup.
const Duration _kAutoDismissDelay = Duration(seconds: 30);

/// Floating, non-modal scrap confirmation popup.
///
/// Requirements (SPEC R6.2):
/// - Non-modal: does NOT block PDF interaction — use with [IgnorePointer]
///   wrapping the rest of the view, or position as an overlay without a barrier.
/// - Shows [previewImageBytes] thumbnail of the captured region.
/// - Accept (check icon) calls [onAccept] and removes popup.
/// - Reject (× icon) calls [onReject] and removes popup.
/// - Auto-dismisses after 30 seconds by calling [onReject].
/// - Timer is cancelled on [dispose].
///
/// Positioned at bottom-right by the parent (e.g., an [Align] or [Positioned]).
/// Compact size: ~200×150 logical pixels.
class ConfirmScrapPopup extends StatefulWidget {
  const ConfirmScrapPopup({
    super.key,
    required this.previewImageBytes,
    required this.onAccept,
    required this.onReject,
  });

  /// PNG bytes of the captured region preview.
  final Uint8List previewImageBytes;

  /// Called when the user taps the accept (check) button.
  final VoidCallback onAccept;

  /// Called when the user taps the reject (×) button, or when the
  /// 30-second auto-dismiss timer fires.
  final VoidCallback onReject;

  @override
  State<ConfirmScrapPopup> createState() => _ConfirmScrapPopupState();
}

class _ConfirmScrapPopupState extends State<ConfirmScrapPopup> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _startAutoDismissTimer();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _startAutoDismissTimer() {
    _autoDismissTimer = Timer(_kAutoDismissDelay, () {
      if (mounted) {
        widget.onReject();
      }
    });
  }

  void _accept() {
    _autoDismissTimer?.cancel();
    widget.onAccept();
  }

  void _reject() {
    _autoDismissTimer?.cancel();
    widget.onReject();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return SizedBox(
      width: 200,
      child: ShadCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.memory(
                widget.previewImageBytes,
                height: 90,
                fit: BoxFit.cover,
                semanticLabel: 'Captured PDF region preview',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject button
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  onPressed: _reject,
                  icon: Icon(
                    Icons.close,
                    size: AppIconSize.xs,
                    color: theme.colorScheme.destructive,
                  ),
                ),
                // Accept button
                ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: _accept,
                  icon: Icon(
                    Icons.check,
                    size: AppIconSize.xs,
                    color: theme.colorScheme.primaryForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
