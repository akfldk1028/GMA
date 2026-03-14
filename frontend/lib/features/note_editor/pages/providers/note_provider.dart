import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/marker_colors.dart';
import '../../../../utils/file_system_provider.dart';
import '../../../../utils/frontmatter_parser.dart';
import '../../models/frontmatter_model.dart';
import '../../models/marker_model.dart';
import '../../models/note_model.dart';
import '../../utils/marker_parser.dart';

part 'note_provider.g.dart';

/// Provider that manages a single note's state, including content.
///
/// This provider:
/// - Loads note from file system based on noteId
/// - Parses frontmatter YAML and marker lines
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
      final notesDir = await ref.read(notesRootDirectoryProvider.future);
      final noteFile = File('${notesDir.path}/$noteId.md');

      // Handle case: note file doesn't exist, create empty note
      if (!await noteFile.exists()) {
        return Note(
          id: noteId,
          content: '',
          filePath: noteFile.path,
        );
      }

      final content = await noteFile.readAsString();

      // Handle case: empty file
      if (content.trim().isEmpty) {
        return Note(
          id: noteId,
          content: '',
          filePath: noteFile.path,
        );
      }

      // Parse frontmatter and extract content
      final parsed = FrontmatterParser.parse(content);
      Frontmatter? frontmatter;

      if (parsed.hasFrontmatter && parsed.frontmatter != null) {
        final fm = parsed.frontmatter!;
        final now = DateTime.now();
        frontmatter = Frontmatter(
          title: fm['title']?.toString() ?? '',
          linkedPdfPath: fm['linkedPdfPath']?.toString(),
          tags: (fm['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
          createdAt: DateTime.tryParse(fm['createdAt']?.toString() ?? '') ?? now,
          modifiedAt: DateTime.tryParse(fm['modifiedAt']?.toString() ?? '') ?? now,
        );
      }

      final bodyContent = parsed.body;

      // Extract markers from content
      final markers = _extractMarkers(bodyContent);

      return Note(
        id: noteId,
        content: bodyContent,
        filePath: noteFile.path,
        frontmatter: frontmatter,
        markers: markers,
      );
    } catch (e, stackTrace) {
      // If any error occurs, log it and return empty note
      debugPrint('Error loading note $noteId: $e');
      debugPrint('Stack trace: $stackTrace');
      return Note(
        id: noteId,
        content: '',
      );
    }
  }

  /// Extracts markers from note content using MarkerParser.
  List<Marker> _extractMarkers(String content) {
    final parseResults = MarkerParser.extractMarkers(content);

    return parseResults.map((result) {
      return Marker(
        id: result.id ?? const Uuid().v4(),
        color: result.color ?? MarkerColor.red,
        pageNumber: result.pageNumber ?? 0,
        selectedText: result.text,
        rect: null,
      );
    }).toList();
  }

  /// Saves the note to the file system.
  Future<void> saveNote(Note note) async {
    try {
      final notesDir = await ref.read(notesRootDirectoryProvider.future);
      final noteFile = File('${notesDir.path}/${note.id}.md');

      // Generate frontmatter if present
      String fullContent;
      if (note.frontmatter != null) {
        final fm = note.frontmatter!;
        final fmMap = <String, dynamic>{
          'title': fm.title,
          if (fm.linkedPdfPath != null) 'linkedPdfPath': fm.linkedPdfPath,
          if (fm.tags.isNotEmpty) 'tags': fm.tags,
          'createdAt': fm.createdAt.toIso8601String(),
          'modifiedAt': DateTime.now().toIso8601String(),
        };
        final frontmatterYaml = FrontmatterParser.serialize(fmMap);
        fullContent = '$frontmatterYaml\n${note.content}';
      } else {
        fullContent = note.content;
      }

      // Write to file
      await noteFile.writeAsString(fullContent);

      // Update state
      state = AsyncData(note);
    } catch (e, stackTrace) {
      debugPrint('Error saving note ${note.id}: $e');
      debugPrint('Stack trace: $stackTrace');
      state = AsyncError(e, stackTrace);
    }
  }

  /// Updates the note content.
  Future<void> updateContent(String newContent) async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    // Extract markers from new content
    final markers = _extractMarkers(newContent);

    // Create updated note
    final updatedNote = currentNote.copyWith(
      content: newContent,
      markers: markers,
    );

    // Save to file system
    await saveNote(updatedNote);
  }

  /// Adds a marker to the note and updates the content.
  Future<void> addMarker(Marker marker) async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    // Create marker line in markdown format with ID
    final emoji = marker.color.emoji;
    final text = marker.selectedText ?? '';
    final markerLine = '- $emoji P${marker.pageNumber}  $text <!-- id:${marker.id} -->';

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
Future<bool> noteExists(Ref ref, String noteId) async {
  try {
    final notesDir = await ref.watch(notesRootDirectoryProvider.future);
    final noteFile = File('${notesDir.path}/$noteId.md');
    return await noteFile.exists();
  } catch (e, stackTrace) {
    debugPrint('Error checking if note exists $noteId: $e');
    debugPrint('Stack trace: $stackTrace');
    return false;
  }
}
