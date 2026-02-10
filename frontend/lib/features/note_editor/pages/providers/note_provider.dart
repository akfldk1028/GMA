import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../../../utils/file_system_provider.dart';
import '../../models/frontmatter_model.dart';
import '../../models/marker_model.dart';
import '../../models/note_model.dart';
import '../../utils/marker_parser.dart';

part 'note_provider.g.dart';

/// Provider that manages a single note's state, including content, markers, and frontmatter.
///
/// This provider:
/// - Loads note from file system based on noteId
/// - Parses frontmatter YAML from the note content
/// - Extracts markers from content using MarkerParser
/// - Handles edge cases: empty note, corrupted frontmatter
///
/// Usage:
/// ```dart
/// final note = ref.watch(noteProvider('note-id-123'));
/// ```
@riverpod
class NoteState extends _$NoteState {
  @override
  FutureOr<Note> build(String noteId) async {
    return await _loadNote(noteId);
  }

  /// Loads a note from the file system and parses its content.
  Future<Note> _loadNote(String noteId) async {
    try {
      final notesDir = await ref.watch(notesRootDirectoryProvider.future);
      final noteFile = File('${notesDir.path}/$noteId.md');

      // Handle case: note file doesn't exist, create empty note
      if (!await noteFile.exists()) {
        return Note(
          id: noteId,
          title: '',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      final content = await noteFile.readAsString();

      // Handle case: empty file
      if (content.trim().isEmpty) {
        return Note(
          id: noteId,
          title: '',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      // Parse frontmatter and extract content
      final parsedData = _parseFrontmatter(content);
      final frontmatter = parsedData['frontmatter'] as Frontmatter?;
      final bodyContent = parsedData['content'] as String;

      return Note(
        id: noteId,
        title: frontmatter?.file ?? '',
        content: bodyContent,
        createdAt: frontmatter?.created ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      // If any error occurs, return empty note
      return Note(
        id: noteId,
        title: '',
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Parses frontmatter YAML from markdown content.
  ///
  /// Frontmatter is expected to be between `---` delimiters at the start of the file:
  /// ```
  /// ---
  /// file: note.md
  /// file-path: /path/to/note.md
  /// tags: [tag1, tag2]
  /// created: 2024-01-01T00:00:00.000Z
  /// ---
  /// # Content here
  /// ```
  ///
  /// Returns a map with:
  /// - 'frontmatter': Frontmatter object or null if not found/corrupted
  /// - 'content': The content after frontmatter
  Map<String, dynamic> _parseFrontmatter(String content) {
    // Check if content starts with frontmatter delimiter
    if (!content.trim().startsWith('---')) {
      return {
        'frontmatter': null,
        'content': content,
      };
    }

    // Find the closing delimiter
    final lines = content.split('\n');
    var endIndex = -1;
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].trim() == '---') {
        endIndex = i;
        break;
      }
    }

    // If no closing delimiter found, treat entire content as body
    if (endIndex == -1) {
      return {
        'frontmatter': null,
        'content': content,
      };
    }

    // Extract frontmatter YAML and body content
    final frontmatterLines = lines.sublist(1, endIndex);
    final bodyLines = lines.sublist(endIndex + 1);

    final yamlContent = frontmatterLines.join('\n');
    final bodyContent = bodyLines.join('\n');

    // Parse YAML
    try {
      final yamlDoc = loadYaml(yamlContent) as Map;

      // Convert YAML to Frontmatter model
      final frontmatter = Frontmatter(
        file: yamlDoc['file'] as String? ?? '',
        filePath: yamlDoc['file-path'] as String? ?? '',
        tags: (yamlDoc['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        created: yamlDoc['created'] != null
            ? DateTime.parse(yamlDoc['created'].toString())
            : DateTime.now(),
      );

      return {
        'frontmatter': frontmatter,
        'content': bodyContent,
      };
    } catch (e) {
      // Handle corrupted frontmatter: return null frontmatter but preserve content
      return {
        'frontmatter': null,
        'content': bodyContent,
      };
    }
  }

  /// Extracts markers from note content using MarkerParser.
  List<Marker> _extractMarkers(String content) {
    final parseResults = MarkerParser.extractMarkers(content);

    return parseResults.map((result) {
      return Marker(
        id: const Uuid().v4(),
        color: result.color!,
        pageNumber: result.pageNumber!,
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

      // Generate frontmatter YAML
      final frontmatter = Frontmatter(
        file: note.title,
        filePath: note.filePath ?? '',
        tags: [],
        created: note.createdAt,
      );
      final frontmatterYaml = _generateFrontmatterYaml(frontmatter);

      // Combine frontmatter and content
      final fullContent = '$frontmatterYaml\n${note.content}';

      // Write to file
      await noteFile.writeAsString(fullContent);

      // Update state with updated timestamp
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      state = AsyncData(updatedNote);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// Generates frontmatter YAML string from Frontmatter model.
  String _generateFrontmatterYaml(Frontmatter frontmatter) {
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('file: ${frontmatter.file}');
    buffer.writeln('file-path: ${frontmatter.filePath}');
    buffer.writeln('tags: [${frontmatter.tags.join(', ')}]');
    buffer.writeln('created: ${frontmatter.created.toIso8601String()}');
    buffer.writeln('---');
    return buffer.toString();
  }

  /// Updates the note content and re-extracts markers.
  Future<void> updateContent(String newContent) async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    // Extract markers from new content (stored in memory, not in Note model)
    _extractMarkers(newContent);

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
    final markerLine = '- $emoji P${marker.pageNumber} $text';

    // Append marker line to content
    final newContent = currentNote.content.isEmpty
        ? markerLine
        : '${currentNote.content}\n$markerLine';

    // Update content (this will also re-extract markers)
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
