import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../../../utils/file_system_provider.dart';
import '../../models/note_metadata_model.dart';

part 'file_manager_provider.g.dart';

@riverpod
class FileManager extends _$FileManager {
  @override
  Future<List<NoteMetadata>> build() async {
    if (kIsWeb) return [];
    return _scanNotesDirectory();
  }

  /// Manually refresh the notes list
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _scanNotesDirectory());
  }

  /// Scans the notes directory recursively for .md files and parses metadata
  Future<List<NoteMetadata>> _scanNotesDirectory() async {
    final notesRoot = await ref.read(notesRootDirectoryProvider.future);
    final notes = <NoteMetadata>[];

    await for (final entity
        in notesRoot.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.md')) {
        try {
          final metadata = await _parseNoteMetadata(entity);
          if (metadata != null) {
            notes.add(metadata);
          }
        } catch (e) {
          // Skip files that can't be parsed
          continue;
        }
      }
    }

    // Sort by modified date (newest first)
    notes.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));

    return notes;
  }

  /// Parses a markdown file and extracts metadata
  Future<NoteMetadata?> _parseNoteMetadata(File file) async {
    try {
      final content = await file.readAsString();
      final stat = await file.stat();

      // Parse YAML frontmatter if present
      String? title;
      String? linkedPdfPath;
      DateTime? createdAt;
      DateTime? modifiedAt = stat.modified;
      String? previewText;

      if (content.startsWith('---')) {
        final endIndex = content.indexOf('---', 3);
        if (endIndex != -1) {
          final frontmatterStr = content.substring(3, endIndex).trim();
          final frontmatter = loadYaml(frontmatterStr) as Map?;

          if (frontmatter != null) {
            title = frontmatter['title']?.toString();
            linkedPdfPath = frontmatter['linkedPdfPath']?.toString();

            // Parse dates
            if (frontmatter['createdAt'] != null) {
              createdAt = DateTime.tryParse(frontmatter['createdAt'].toString());
            }
            if (frontmatter['modifiedAt'] != null) {
              modifiedAt =
                  DateTime.tryParse(frontmatter['modifiedAt'].toString()) ??
                      stat.modified;
            }
          }

          // Extract preview text from content after frontmatter
          final bodyStart = endIndex + 3;
          if (bodyStart < content.length) {
            final body = content.substring(bodyStart).trim();
            // Get first 100 characters as preview
            previewText = body.length > 100 ? body.substring(0, 100) : body;
            // Remove markdown formatting for cleaner preview
            previewText = previewText
                .replaceAll(RegExp(r'#{1,6}\s'), '')
                .replaceAll(RegExp(r'[*_~`\[\]]'), '')
                .replaceAll(RegExp(r'\n+'), ' ')
                .trim();
          }
        }
      } else {
        // No frontmatter, extract preview from content
        previewText = content.length > 100 ? content.substring(0, 100) : content;
        previewText = previewText
            .replaceAll(RegExp(r'#{1,6}\s'), '')
            .replaceAll(RegExp(r'[*_~`\[\]]'), '')
            .replaceAll(RegExp(r'\n+'), ' ')
            .trim();
      }

      // Use filename as title if not in frontmatter
      if (title == null || title.isEmpty) {
        title = file.uri.pathSegments.last.replaceAll('.md', '');
      }

      // Use filename without extension as note ID (matches noteStateProvider lookup)
      final id = path.basenameWithoutExtension(file.path);

      return NoteMetadata(
        id: id,
        title: title,
        filePath: file.path,
        createdAt: createdAt ?? stat.modified,
        modifiedAt: modifiedAt,
        linkedPdfPath: linkedPdfPath,
        previewText: previewText,
      );
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
  }
}

/// Mutation provider for creating a new note
@riverpod
class CreateNoteMutation extends _$CreateNoteMutation {
  @override
  FutureOr<NoteMetadata?> build() => null;

  Future<NoteMetadata> call({
    required String title,
    String? linkedPdfPath,
  }) async {
    if (kIsWeb) throw UnsupportedError('File creation not supported on web');
    state = const AsyncLoading();
    try {
      final notesRoot = await ref.read(notesRootDirectoryProvider.future);

      // Generate unique filename using UUID
      const uuid = Uuid();
      final noteUuid = uuid.v4();
      final filename = '$noteUuid.md';
      final filePath = path.join(notesRoot.path, filename);
      final file = File(filePath);

      // Create frontmatter with metadata
      final now = DateTime.now();
      final frontmatter = StringBuffer()
        ..writeln('---')
        ..writeln('title: $title')
        ..writeln('createdAt: ${now.toIso8601String()}')
        ..writeln('modifiedAt: ${now.toIso8601String()}');

      if (linkedPdfPath != null && linkedPdfPath.isNotEmpty) {
        frontmatter.writeln('linkedPdfPath: $linkedPdfPath');
      }

      frontmatter
        ..writeln('---')
        ..writeln()
        ..writeln('# $title')
        ..writeln();

      // Write the file
      await file.writeAsString(frontmatter.toString());

      // Create NoteMetadata for the new note
      final metadata = NoteMetadata(
        id: noteUuid,
        title: title,
        filePath: file.path,
        createdAt: now,
        modifiedAt: now,
        linkedPdfPath: linkedPdfPath,
        previewText: '# $title',
      );

      // Refresh the file manager to pick up the new note
      await ref.read(fileManagerProvider.notifier).refresh();

      state = AsyncData(metadata);
      return metadata;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Mutation provider for deleting a note
@riverpod
class DeleteNoteMutation extends _$DeleteNoteMutation {
  @override
  FutureOr<bool?> build() => null;

  Future<bool> call({required String filePath}) async {
    state = const AsyncLoading();
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      // Delete the file
      await file.delete();

      // Refresh the file manager to update the list
      await ref.read(fileManagerProvider.notifier).refresh();

      state = const AsyncData(true);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
