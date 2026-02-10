import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/marker_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../models/marker_model.dart';
import '../../models/note_model.dart';
import '../../utils/marker_parser.dart';

part 'note_provider.g.dart';

/// Provider that manages a single note's state, including content.
///
/// This provider:
/// - Loads note from file system based on noteId
/// - Handles edge cases: empty note, non-existent file
///
/// Usage:
/// ```dart
/// final note = ref.watch(noteStateProvider('note-id-123'));
/// ```
@riverpod
class NoteState extends _$NoteState {
  @override
  FutureOr<Note> build(String noteId) async {
    return await _loadNote(noteId);
  }

  /// Loads a note from the file system.
  Future<Note> _loadNote(String noteId) async {
    try {
      final notesDir = await ref.watch(notesRootDirectoryProvider.future);
      final noteFile = File('${notesDir.path}/$noteId.md');

      // Handle case: note file doesn't exist, create empty note
      if (!await noteFile.exists()) {
        return Note(
          id: noteId,
          title: 'Untitled',
          content: '',
          filePath: noteFile.path,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final content = await noteFile.readAsString();
      final stat = await noteFile.stat();

      // Handle case: empty file
      if (content.trim().isEmpty) {
        return Note(
          id: noteId,
          title: 'Untitled',
          content: '',
          filePath: noteFile.path,
          createdAt: stat.modified,
          updatedAt: stat.modified,
        );
      }

      // Extract title from first line (assuming # Title format) or use filename
      final title = _extractTitle(content, noteId);

      return Note(
        id: noteId,
        title: title,
        content: content,
        filePath: noteFile.path,
        createdAt: stat.modified,
        updatedAt: stat.modified,
      );
    } catch (e) {
      // If any error occurs, return empty note
      return Note(
        id: noteId,
        title: 'Untitled',
        content: '',
        filePath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Extracts title from markdown content (first # heading) or uses noteId as fallback.
  String _extractTitle(String content, String noteId) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#')) {
        // Remove # symbols and trim
        return trimmed.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      }
    }
    return noteId; // Fallback to noteId if no heading found
  }

  /// Extracts markers from note content using MarkerParser.
  /// Returns a list of markers found in the content.
  List<Marker> extractMarkers() {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return [];

    final parseResults = MarkerParser.extractMarkers(currentNote.content);

    return parseResults.map((result) {
      return Marker(
        id: const Uuid().v4(),
        color: result.color ?? MarkerColor.red,
        pageNumber: result.pageNumber ?? 0,
        selectedText: result.text,
        rect: null, // rect is not stored in markdown, only in memory during PDF interaction
      );
    }).toList();
  }

  /// Saves the note to the file system.
  ///
  /// This updates the note content and persists it to disk.
  Future<void> saveNote(Note note) async {
    try {
      final notesDir = await ref.watch(notesRootDirectoryProvider.future);
      final noteFile = File('${notesDir.path}/${note.id}.md');

      // Write content to file
      await noteFile.writeAsString(note.content);

      // Update state with new timestamp
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      state = AsyncData(updatedNote);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// Updates the note content.
  Future<void> updateContent(String newContent) async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    // Create updated note
    final updatedNote = currentNote.copyWith(
      content: newContent,
    );

    // Save to file system
    await saveNote(updatedNote);
  }

  /// Adds a marker to the note and updates the content.
  Future<void> addMarker(Marker marker) async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    // Create marker line in markdown format
    final emoji = marker.color.emoji;
    final text = marker.selectedText ?? '';
    final markerLine = '- $emoji P${marker.pageNumber}  $text';

    // Append marker line to content
    final newContent = currentNote.content.isEmpty
        ? markerLine
        : '${currentNote.content}\n$markerLine';

    // Update content
    await updateContent(newContent);
  }
}

/// Helper provider to check if a note exists.
@riverpod
Future<bool> noteExists(NoteExistsRef ref, String noteId) async {
  final notesDir = await ref.watch(notesRootDirectoryProvider.future);
  final noteFile = File('${notesDir.path}/$noteId.md');
  return await noteFile.exists();
}
