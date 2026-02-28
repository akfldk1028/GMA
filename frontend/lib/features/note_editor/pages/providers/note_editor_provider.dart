import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../constants/marker_colors.dart';
import 'note_provider.dart';

part 'note_editor_provider.g.dart';

/// Provider that manages the text editing controller for a note editor.
///
/// This provider:
/// - Creates and manages a TextEditingController initialized with note content
/// - Provides insertMarker() method to add marker lines at cursor position
/// - Handles text truncation (150 chars max with ellipsis)
/// - Provides saveContent() method to persist changes to noteProvider
///
/// Usage:
/// ```dart
/// final controller = ref.watch(noteEditorProvider('note-id-123'));
/// controller?.text // access text
///
/// // Insert marker
/// await ref.read(noteEditorProvider('note-id-123').notifier)
///   .insertMarker(color: MarkerColor.red, pageNumber: 3, text: 'selected text...');
/// ```
@riverpod
class NoteEditor extends _$NoteEditor {
  TextEditingController? _controller;

  @override
  TextEditingController? build(String noteId) {
    // Load initial note content
    final noteState = ref.watch(noteStateProvider(noteId));

    // Initialize controller when note is loaded
    noteState.whenData((note) {
      if (_controller == null) {
        _controller = TextEditingController(text: note.content);
      } else if (_controller!.text != note.content) {
        // Update controller if content changed externally
        // Preserve cursor position if possible
        final currentSelection = _controller!.selection;
        _controller!.text = note.content;

        // Restore selection if still valid
        if (currentSelection.isValid &&
            currentSelection.end <= note.content.length) {
          _controller!.selection = currentSelection;
        }
      }
    });

    // Cleanup when provider is disposed
    ref.onDispose(() {
      try {
        _controller?.dispose();
      } catch (e) {
        debugPrint('Failed to dispose TextEditingController: $e');
      } finally {
        _controller = null;
      }
    });

    return _controller;
  }

  /// Inserts a marker line at the current cursor position.
  ///
  /// Format: `- 🔴 P3 selected text...`
  ///
  /// Handles:
  /// - Text truncation: truncates to 150 chars with ellipsis if longer
  /// - Smart newline insertion: adds newlines before/after as needed
  /// - Cursor positioning: moves cursor after inserted marker
  ///
  /// Example:
  /// ```dart
  /// await ref.read(noteEditorProvider('note-123').notifier)
  ///   .insertMarker(
  ///     color: MarkerColor.red,
  ///     pageNumber: 3,
  ///     text: 'This is the selected text from PDF',
  ///   );
  /// // Result: - 🔴 P3 This is the selected text from PDF
  /// ```
  Future<void> insertMarker({
    required MarkerColor color,
    required int pageNumber,
    required String text,
  }) async {
    if (_controller == null) return;

    // Compute sequential sub-number for this page (P1-1, P1-2, ...)
    final subNumber = _computeSubNumber(_controller!.text, pageNumber);

    // Create marker line in format: - 🔴 P3-2  [text] (double space before text)
    final emoji = color.emoji;
    final String markerLine;
    if (text.isEmpty) {
      markerLine = '- $emoji P$pageNumber-$subNumber';
    } else {
      // Truncate text to 150 chars with ellipsis
      final truncatedText =
          text.length > 150 ? '${text.substring(0, 150)}...' : text;
      markerLine = '- $emoji P$pageNumber-$subNumber  $truncatedText';
    }

    // Get current text and cursor position
    final currentText = _controller!.text;
    final selection = _controller!.selection;

    // Insert at cursor position, or at end if no valid selection
    final insertPosition =
        selection.isValid && selection.baseOffset >= 0
            ? selection.baseOffset
            : currentText.length;

    // Build new text with smart newline handling
    final beforeCursor = currentText.substring(0, insertPosition);
    final afterCursor = currentText.substring(insertPosition);

    // Add newlines appropriately
    final needsNewlineBefore =
        beforeCursor.isNotEmpty && !beforeCursor.endsWith('\n');
    final needsNewlineAfter =
        afterCursor.isNotEmpty && !afterCursor.startsWith('\n');

    final newText = beforeCursor +
        (needsNewlineBefore ? '\n' : '') +
        markerLine +
        (needsNewlineAfter ? '\n' : '') +
        afterCursor;

    // Calculate new cursor position (after the marker line)
    final newCursorOffset = insertPosition +
        (needsNewlineBefore ? 1 : 0) +
        markerLine.length +
        (needsNewlineAfter ? 1 : 0);

    // Update controller with new text and cursor position
    _controller!.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  /// Inserts a captured image reference at the current cursor position.
  ///
  /// Format:
  /// ```
  /// - 🟡 P5
  ///   ![P5 capture](file:///path/to/captures/p5_1234567890.png)
  /// ```
  Future<void> insertCapture({
    required int pageNumber,
    required String filename,
    String? capturesDir,
    String? contextText,
  }) async {
    if (_controller == null) return;

    // Compute sequential sub-number for this page
    final subNumber = _computeSubNumber(_controller!.text, pageNumber);

    // Use absolute file URI if capturesDir is provided, else relative path
    final imgPath = capturesDir != null
        ? 'file:///${path.join(capturesDir, filename).replaceAll('\\', '/')}'
        : path.join('captures', filename);
    // Include context text if available (truncated to 100 chars)
    final textPart = contextText != null && contextText.isNotEmpty
        ? '  ${contextText.length > 100 ? '${contextText.substring(0, 100)}...' : contextText}'
        : '';
    final markerLine =
        '- 🟡 P$pageNumber-$subNumber$textPart\n  ![P$pageNumber-$subNumber capture]($imgPath)';

    final currentText = _controller!.text;
    final selection = _controller!.selection;

    final insertPosition =
        selection.isValid && selection.baseOffset >= 0
            ? selection.baseOffset
            : currentText.length;

    final beforeCursor = currentText.substring(0, insertPosition);
    final afterCursor = currentText.substring(insertPosition);

    final needsNewlineBefore =
        beforeCursor.isNotEmpty && !beforeCursor.endsWith('\n');
    final needsNewlineAfter =
        afterCursor.isNotEmpty && !afterCursor.startsWith('\n');

    final newText = beforeCursor +
        (needsNewlineBefore ? '\n' : '') +
        markerLine +
        (needsNewlineAfter ? '\n' : '') +
        afterCursor;

    final newCursorOffset = insertPosition +
        (needsNewlineBefore ? 1 : 0) +
        markerLine.length +
        (needsNewlineAfter ? 1 : 0);

    _controller!.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  /// Compute the next sub-number for a given page.
  ///
  /// Scans existing markers in the note content and returns max+1.
  /// Handles both new format (P3-2) and legacy format (P3, treated as P3-1).
  int _computeSubNumber(String content, int pageNumber) {
    // Match markers on this specific page: any emoji + P{pageNumber} or P{pageNumber}-{sub}
    // Use word boundary after page number to avoid P1 matching P10, P11, etc.
    final regex = RegExp(
      r'P' + pageNumber.toString() + r'(?:-(\d+))?(?:\s|$)',
      multiLine: true,
    );
    final matches = regex.allMatches(content);

    int maxSub = 0;
    for (final match in matches) {
      if (match.group(1) != null) {
        final sub = int.tryParse(match.group(1)!) ?? 0;
        if (sub > maxSub) maxSub = sub;
      } else {
        // Legacy P3 format without sub-number, treat as 1
        if (maxSub < 1) maxSub = 1;
      }
    }
    return maxSub + 1;
  }

  /// Saves the current editor content to the note provider.
  ///
  /// This persists the changes to the file system and updates
  /// the note's markers by re-parsing the content.
  Future<void> saveContent(String noteId) async {
    if (_controller == null) return;

    final content = _controller!.text;
    await ref.read(noteStateProvider(noteId).notifier).updateContent(content);
  }

  /// Gets the current text from the controller.
  String? getCurrentText() {
    return _controller?.text;
  }

  /// Clears all text in the editor.
  void clear() {
    _controller?.clear();
  }

  /// Sets the text in the editor.
  void setText(String text) {
    if (_controller == null) return;
    _controller!.text = text;
  }
}
