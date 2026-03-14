import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../services/scrap_insertion_service.dart';

/// A non-modal floating popup for confirming or rejecting scrap insertion.
///
/// This widget is overlaid on the workspace (not shown as a dialog) so it
/// does NOT block PDF interactions. The caller is responsible for positioning
/// it — typically bottom-right of the workspace.
///
/// Pass a [CaptureProposal] or [HighlightProposal] as [proposal].
class ConfirmScrapPopup extends StatelessWidget {
  const ConfirmScrapPopup({
    super.key,
    required this.proposal,
    required this.onAccept,
    required this.onReject,
  });

  /// The active proposal to display. Either [CaptureProposal] or [HighlightProposal].
  final Object proposal;

  /// Called when the user taps the accept (check) button.
  final VoidCallback onAccept;

  /// Called when the user taps the reject (close) button.
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260, minWidth: 200),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildPreview(),
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isCapture = proposal is CaptureProposal;
    return Row(
      children: [
        Icon(
          isCapture ? Icons.image_outlined : Icons.format_quote_outlined,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            isCapture ? 'Add capture to scrapnote?' : 'Add highlight to scrapnote?',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (proposal is CaptureProposal) {
      final cap = proposal as CaptureProposal;
      if (kIsWeb) {
        return Container(
          height: 100,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_outlined, color: Colors.grey),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(cap.imagePath),
          height: 100,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 100,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    if (proposal is HighlightProposal) {
      final hl = proposal as HighlightProposal;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Color(hl.colorValue).withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Color(hl.colorValue).withValues(alpha: 0.5)),
        ),
        child: Text(
          hl.selectedText,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Reject button
        IconButton(
          key: const Key('confirm_scrap_popup_reject'),
          onPressed: onReject,
          icon: const Icon(Icons.close),
          iconSize: 20,
          tooltip: 'Reject',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          color: Colors.redAccent,
        ),
        const SizedBox(width: 8),
        // Accept button
        IconButton(
          key: const Key('confirm_scrap_popup_accept'),
          onPressed: onAccept,
          icon: const Icon(Icons.check),
          iconSize: 20,
          tooltip: 'Add to scrapnote',
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          color: Colors.green,
        ),
      ],
    );
  }
}
