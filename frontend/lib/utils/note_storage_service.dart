import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'file_system_provider.dart';

part 'note_storage_service.g.dart';

/// Service for saving note content to filesystem with debouncing.
/// Prevents excessive file I/O by delaying writes until user stops typing.
@riverpod
NoteStorageService noteStorageService(NoteStorageServiceRef ref) {
  final service = NoteStorageService(ref);
  ref.onDispose(() => service.dispose());
  return service;
}

/// Manages note file operations with automatic debouncing.
/// Uses 500ms delay to batch rapid changes into a single write operation.
class NoteStorageService {
  NoteStorageService(this.ref);

  final NoteStorageServiceRef ref;
  Timer? _debounceTimer;

  /// Default debounce duration (500ms)
  static const Duration debounceDuration = Duration(milliseconds: 500);

  /// Save note content to filesystem with debouncing.
  ///
  /// Cancels any pending save operations and schedules a new save after [debounceDuration].
  /// This ensures that rapid consecutive changes result in only one file write.
  ///
  /// Parameters:
  /// - [noteId]: Unique identifier for the note (used as filename)
  /// - [content]: Markdown content to save
  ///
  /// Throws:
  /// - [FileSystemException] if file write fails
  /// - [Exception] if noteId is empty or content is null
  Future<void> saveNote({
    required String noteId,
    required String content,
  }) async {
    // Validate parameters
    if (noteId.isEmpty) {
      throw Exception('Note ID cannot be empty');
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
        rethrow;
      }
    });
  }

  /// Immediately save note content without debouncing.
  ///
  /// Use this for explicit save operations (e.g., user clicks "Save" button).
  /// For auto-save during typing, use [saveNote] instead.
  Future<void> saveNoteImmediate({
    required String noteId,
    required String content,
  }) async {
    // Cancel any pending debounced save
    _debounceTimer?.cancel();

    await _writeNoteToFile(noteId: noteId, content: content);
  }

  /// Internal method to write note content to filesystem.
  Future<void> _writeNoteToFile({
    required String noteId,
    required String content,
  }) async {
    // Get notes root directory
    final notesDir = await ref.read(notesRootDirectoryProvider.future);

    // Create note file path (noteId.md)
    final noteFile = File('${notesDir.path}/$noteId.md');

    // Ensure parent directory exists
    final parentDir = noteFile.parent;
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }

    // Write content to file
    await noteFile.writeAsString(content, flush: true);

    debugPrint('Note saved: $noteId (${content.length} bytes)');
  }

  /// Load note content from filesystem.
  ///
  /// Returns null if note file doesn't exist.
  Future<String?> loadNote({required String noteId}) async {
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
  Future<void> deleteNote({required String noteId}) async {
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
      rethrow;
    }
  }

  /// Check if note file exists.
  Future<bool> noteExists({required String noteId}) async {
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
