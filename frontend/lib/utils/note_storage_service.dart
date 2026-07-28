import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'file_system_provider.dart';

part 'note_storage_service.g.dart';

/// Service for saving note content to filesystem with debouncing.
/// Prevents excessive file I/O by delaying writes until user stops typing.
@riverpod
NoteStorageService noteStorageService(Ref ref) {
  final service = NoteStorageService(ref);
  ref.onDispose(() => service.dispose());
  return service;
}

/// Manages note file operations with automatic debouncing.
/// Uses 500ms delay to batch rapid changes into a single write operation.
class NoteStorageService {
  NoteStorageService(this.ref);

  final Ref ref;
  Timer? _debounceTimer;

  /// Default debounce duration (500ms)
  static const Duration debounceDuration = Duration(milliseconds: 500);

  /// Save note content to filesystem with debouncing.
  ///
  /// Cancels any pending save operations and schedules a new save after [debounceDuration].
  /// This ensures that rapid consecutive changes result in only one file write.
  ///
  /// On web, this is a no-op (filesystem not available).
  ///
  /// Parameters:
  /// - [noteId]: Unique identifier for the note (used as filename)
  /// - [content]: Markdown content to save
  ///
  /// Errors are logged via debugPrint and handled gracefully.
  Future<void> saveNote({
    required String noteId,
    required String content,
  }) async {
    // Web platform does not support dart:io file operations
    if (kIsWeb) return;

    // Validate parameters
    if (noteId.isEmpty) {
      debugPrint('Note ID cannot be empty');
      return;
    }

    // Cancel any pending save operation
    _debounceTimer?.cancel();

    // Schedule new save operation after debounce delay
    _debounceTimer = Timer(debounceDuration, () async {
      try {
        await _writeNoteToFile(noteId: noteId, content: content);
      } catch (e, stackTrace) {
        debugPrint('Error saving note $noteId: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    });
  }

  /// Immediately save note content without debouncing.
  ///
  /// Use this for explicit save operations (e.g., user clicks "Save" button).
  /// For auto-save during typing, use [saveNote] instead.
  /// On web, this is a no-op (filesystem not available).
  Future<void> saveNoteImmediate({
    required String noteId,
    required String content,
  }) async {
    if (kIsWeb) return;

    // Cancel any pending debounced save
    _debounceTimer?.cancel();

    await _writeNoteToFile(noteId: noteId, content: content);
  }

  /// Internal method to write note content to filesystem.
  ///
  /// Frontmatter preservation: callers (e.g. the note editor controller)
  /// often pass body-only content because [note_provider] strips the YAML
  /// frontmatter when loading [Note.content]. To prevent silent frontmatter
  /// loss, if [content] does not start with `---` and the existing file on
  /// disk has frontmatter, the frontmatter is re-attached before writing.
  Future<void> _writeNoteToFile({
    required String noteId,
    required String content,
  }) async {
    final notesDir = await ref.read(notesRootDirectoryProvider.future);
    final noteFile = File('${notesDir.path}/$noteId.md');

    final parentDir = noteFile.parent;
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }

    final finalContent =
        await _mergeFrontmatterIfNeeded(noteFile, content);

    await noteFile.writeAsString(finalContent, flush: true);

    debugPrint('Note saved: $noteId (${finalContent.length} bytes)');
  }

  /// If [content] is body-only (no `---` opening) and the existing file has
  /// YAML frontmatter, re-attach the frontmatter so it survives the save.
  Future<String> _mergeFrontmatterIfNeeded(
      File noteFile, String content) async {
    if (content.startsWith('---')) return content;
    if (!await noteFile.exists()) return content;
    try {
      final existing = await noteFile.readAsString();
      if (!existing.startsWith('---')) return content;
      final fmEnd = existing.indexOf('\n---', 3);
      if (fmEnd < 0) return content;
      // Closing marker spans 4 chars: \n---. Include it then a separator
      // newline before the body.
      final fm = existing.substring(0, fmEnd + 4);
      final body = content.startsWith('\n') ? content : '\n$content';
      return '$fm$body';
    } catch (e) {
      debugPrint('[NoteStorage] frontmatter merge failed: $e');
      return content;
    }
  }

  /// Load note content from filesystem.
  ///
  /// Returns null if note file doesn't exist or on web.
  Future<String?> loadNote({required String noteId}) async {
    if (kIsWeb) return null;

    try {
      final notesDir = await ref.read(notesRootDirectoryProvider.future);
      final noteFile = File('${notesDir.path}/$noteId.md');

      if (!await noteFile.exists()) {
        return null;
      }

      return await noteFile.readAsString();
    } catch (e, stackTrace) {
      debugPrint('Error loading note $noteId: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Delete note file from filesystem.
  /// On web, this is a no-op.
  Future<void> deleteNote({required String noteId}) async {
    if (kIsWeb) return;

    try {
      final notesDir = await ref.read(notesRootDirectoryProvider.future);
      final noteFile = File('${notesDir.path}/$noteId.md');

      if (await noteFile.exists()) {
        await noteFile.delete();
        debugPrint('Note deleted: $noteId');
      }
    } catch (e, stackTrace) {
      debugPrint('Error deleting note $noteId: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Check if note file exists.
  /// Returns false on web (filesystem not available).
  Future<bool> noteExists({required String noteId}) async {
    if (kIsWeb) return false;

    try {
      final notesDir = await ref.read(notesRootDirectoryProvider.future);
      final noteFile = File('${notesDir.path}/$noteId.md');
      return await noteFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources and cancel any pending operations.
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
