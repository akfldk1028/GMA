import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
    debugPrint('[FileManager.build] scanning notes directory');
    final results = await _scanNotesDirectory();
    debugPrint('[FileManager.build] found ${results.length} notes');
    return results;
  }

  /// Manually refresh the notes list
  Future<void> refresh() async {
    debugPrint('[FileManager.refresh] refreshing notes list');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final results = await _scanNotesDirectory();
      debugPrint('[FileManager.refresh] found ${results.length} notes');
      return results;
    });
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
      String? folderId;
      bool isPinned = false;
      bool isDeleted = false;
      DateTime? deletedAt;

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

            // Parse new fields
            folderId = frontmatter['folderId']?.toString();
            isPinned = frontmatter['isPinned'] == true;
            isDeleted = frontmatter['isDeleted'] == true;
            if (frontmatter['deletedAt'] != null) {
              deletedAt = DateTime.tryParse(frontmatter['deletedAt'].toString());
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
        folderId: folderId,
        isPinned: isPinned,
        isDeleted: isDeleted,
        deletedAt: deletedAt,
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
    debugPrint('[CreateNoteMutation.call] title: $title, linkedPdfPath: $linkedPdfPath');
    // Keep this provider alive during the async mutation so AutoDispose
    // doesn't kill it mid-flight when the dialog rebuilds.
    final keepAlive = ref.keepAlive();
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
        ..writeln()
        ..writeln('::: scrapnote Scraps')
        ..writeln(':::')
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

      debugPrint('[CreateNoteMutation.call] created note: ${metadata.id}');
      state = AsyncData(metadata);
      ref.invalidate(fileManagerProvider);
      return metadata;
    } catch (e, st) {
      debugPrint('[CreateNoteMutation.call] FAILED: $e');
      state = AsyncError(e, st);
      rethrow;
    } finally {
      keepAlive.close();
    }
  }
}

/// Mutation provider for soft-deleting a note (marks isDeleted in frontmatter)
@riverpod
class DeleteNoteMutation extends _$DeleteNoteMutation {
  @override
  FutureOr<bool?> build() => null;

  Future<bool> call({required String filePath}) async {
    debugPrint('[DeleteNoteMutation.call] soft-deleting: $filePath');
    state = const AsyncLoading();
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final content = await file.readAsString();
      final updated = _updateFrontmatter(content, {
        'isDeleted': true,
        'deletedAt': DateTime.now().toIso8601String(),
      });
      await file.writeAsString(updated, flush: true);
      debugPrint('[DeleteNoteMutation.call] soft-deleted successfully: $filePath');

      await ref.read(fileManagerProvider.notifier).refresh();
      state = const AsyncData(true);
      return true;
    } catch (e, st) {
      debugPrint('[DeleteNoteMutation.call] FAILED: $e');
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Restore a soft-deleted note
@riverpod
class RestoreNoteMutation extends _$RestoreNoteMutation {
  @override
  FutureOr<bool?> build() => null;

  Future<bool> call({required String filePath}) async {
    state = const AsyncLoading();
    try {
      final file = File(filePath);
      if (!await file.exists()) throw Exception('File not found: $filePath');

      final content = await file.readAsString();
      final updated = _updateFrontmatter(content, {
        'isDeleted': false,
        'deletedAt': null,
      });
      await file.writeAsString(updated, flush: true);

      await ref.read(fileManagerProvider.notifier).refresh();
      state = const AsyncData(true);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Permanently delete a note file
@riverpod
class PermanentDeleteMutation extends _$PermanentDeleteMutation {
  @override
  FutureOr<bool?> build() => null;

  Future<bool> call({required String filePath}) async {
    debugPrint('[PermanentDeleteMutation.call] permanently deleting: $filePath');
    state = const AsyncLoading();
    try {
      final file = File(filePath);
      if (await file.exists()) {
        debugPrint('[PermanentDeleteMutation.call] file exists, deleting...');
        await file.delete();
      } else {
        debugPrint('[PermanentDeleteMutation.call] file not found: $filePath');
      }
      await ref.read(fileManagerProvider.notifier).refresh();
      state = const AsyncData(true);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Move note to a folder
@riverpod
class MoveToFolderMutation extends _$MoveToFolderMutation {
  @override
  FutureOr<bool?> build() => null;

  Future<bool> call({required String filePath, String? folderId}) async {
    state = const AsyncLoading();
    try {
      final file = File(filePath);
      if (!await file.exists()) throw Exception('File not found: $filePath');

      final content = await file.readAsString();
      final updated = _updateFrontmatter(content, {'folderId': folderId});
      await file.writeAsString(updated, flush: true);

      await ref.read(fileManagerProvider.notifier).refresh();
      state = const AsyncData(true);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Toggle pin/favorite on a note
@riverpod
class TogglePinMutation extends _$TogglePinMutation {
  @override
  FutureOr<bool?> build() => null;

  Future<bool> call({required String filePath, required bool isPinned}) async {
    state = const AsyncLoading();
    try {
      final file = File(filePath);
      if (!await file.exists()) throw Exception('File not found: $filePath');

      final content = await file.readAsString();
      final updated = _updateFrontmatter(content, {'isPinned': isPinned});
      await file.writeAsString(updated, flush: true);

      await ref.read(fileManagerProvider.notifier).refresh();
      state = const AsyncData(true);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Helper to update or insert frontmatter fields
String _updateFrontmatter(String content, Map<String, Object?> fields) {
  if (!content.startsWith('---')) {
    // No frontmatter exists, create one
    final sb = StringBuffer()..writeln('---');
    for (final entry in fields.entries) {
      if (entry.value != null) {
        sb.writeln('${entry.key}: ${entry.value}');
      }
    }
    sb.writeln('---');
    sb.write(content);
    return sb.toString();
  }

  final endIndex = content.indexOf('---', 3);
  if (endIndex == -1) return content;

  final frontmatterStr = content.substring(3, endIndex);
  final body = content.substring(endIndex + 3);

  // Parse existing lines
  final lines = frontmatterStr.trim().split('\n');
  final existingKeys = <String>{};
  final updatedLines = <String>[];

  for (final line in lines) {
    final colonIdx = line.indexOf(':');
    if (colonIdx == -1) {
      updatedLines.add(line);
      continue;
    }
    final key = line.substring(0, colonIdx).trim();
    if (fields.containsKey(key)) {
      existingKeys.add(key);
      final value = fields[key];
      // null → remove the field entirely
      if (value == null) continue;
      // all other values (including false) → write explicitly
      updatedLines.add('$key: $value');
    } else {
      updatedLines.add(line);
    }
  }

  // Add new fields not yet in frontmatter
  for (final entry in fields.entries) {
    if (!existingKeys.contains(entry.key) && entry.value != null) {
      updatedLines.add('${entry.key}: ${entry.value}');
    }
  }

  final sb = StringBuffer()
    ..writeln('---')
    ..writeln(updatedLines.join('\n'))
    ..write('---')
    ..write(body);
  return sb.toString();
}
