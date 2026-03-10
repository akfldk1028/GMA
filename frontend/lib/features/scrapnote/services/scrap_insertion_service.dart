import 'dart:async';

import '../models/scrapnote_canvas_model.dart';

// @MX:ANCHOR: [AUTO] ScrapInsertionService — coordinates async confirm/reject flow for scrap insertion.
// @MX:REASON: High fan_in — WorkspaceProvider and ConfirmScrapPopup both depend on this service.

/// Data passed when proposing a capture insertion.
class CaptureProposal {
  final String imagePath;
  final int sourcePageNumber;
  final String sourcePdfPath;

  const CaptureProposal({
    required this.imagePath,
    required this.sourcePageNumber,
    required this.sourcePdfPath,
  });
}

/// Data passed when proposing a highlight insertion.
class HighlightProposal {
  final String selectedText;
  final int colorValue;
  final int sourcePageNumber;
  final String sourcePdfPath;

  const HighlightProposal({
    required this.selectedText,
    required this.colorValue,
    required this.sourcePageNumber,
    required this.sourcePdfPath,
  });
}

/// Result of a confirm/reject proposal.
enum InsertionResult { accepted, rejected, timeout }

/// Service managing the scrap insertion flow with confirm/reject UI.
///
/// Emits proposals on the [proposals] stream for the UI to display popups.
/// The popup calls [accept] or [reject] to resolve the pending [Future].
/// A 30-second timer auto-rejects if the user does not respond.
class ScrapInsertionService {
  /// Stream of active proposals (either [CaptureProposal] or [HighlightProposal]).
  Stream<Object> get proposals => _proposalController.stream;
  final _proposalController = StreamController<Object>.broadcast();

  Completer<InsertionResult>? _activeCompleter;
  Timer? _timeoutTimer;

  /// Propose a capture image for insertion onto the scrapnote canvas.
  ///
  /// Returns [InsertionResult.accepted] if the user confirms, [InsertionResult.rejected]
  /// if they dismiss, or [InsertionResult.timeout] after 30 seconds of inactivity.
  Future<InsertionResult> proposeCapture(CaptureProposal proposal) async {
    _cancelPrevious();
    final completer = Completer<InsertionResult>();
    _activeCompleter = completer;
    _proposalController.add(proposal);
    _startTimeout(completer);
    return completer.future;
  }

  /// Propose a highlight for insertion onto the scrapnote canvas.
  Future<InsertionResult> proposeHighlight(HighlightProposal proposal) async {
    _cancelPrevious();
    final completer = Completer<InsertionResult>();
    _activeCompleter = completer;
    _proposalController.add(proposal);
    _startTimeout(completer);
    return completer.future;
  }

  /// Accept the current proposal.
  void accept() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(InsertionResult.accepted);
    }
  }

  /// Reject the current proposal.
  void reject() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(InsertionResult.rejected);
    }
  }

  /// Calculate the auto-position for a new element placed below existing ones.
  ///
  /// Returns `(x: 50.0, y: 100.0)` if [existingElements] is empty.
  /// Otherwise returns `(x: 50.0, y: bottomOfLastElement + 30)`.
  static ({double x, double y}) calculateAutoPosition(
    List<CanvasElement> existingElements,
  ) {
    const defaultX = 50.0;
    const defaultY = 100.0;
    const elementGap = 30.0;

    if (existingElements.isEmpty) return (x: defaultX, y: defaultY);

    double maxBottom = 0;
    for (final e in existingElements) {
      final bottom = e.y + e.height;
      if (bottom > maxBottom) maxBottom = bottom;
    }

    return (x: defaultX, y: maxBottom + elementGap);
  }

  /// Clean up timers and close the stream.
  void dispose() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _proposalController.close();
  }

  // ─── Private helpers ──────────────────────────────────────

  void _cancelPrevious() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(InsertionResult.rejected);
    }
    _activeCompleter = null;
  }

  void _startTimeout(Completer<InsertionResult> completer) {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.complete(InsertionResult.timeout);
      }
    });
  }
}
