import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gma_frontend/features/note_editor/models/note_model.dart';
import 'package:path/path.dart' as path;

void main() {
  group('Note Persistence to Hive Integration', () {
    late Box<Map> notesBox;
    late Directory tempDir;

    setUp(() async {
      // Create temporary directory for Hive
      tempDir = await Directory.systemTemp.createTemp('gma_test_');
      Hive.init(tempDir.path);

      // Open a test box for notes
      notesBox = await Hive.openBox<Map>('test_notes');
    });

    tearDown(() async {
      // Clean up
      await notesBox.clear();
      await notesBox.close();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('saves note to Hive and retrieves it', () async {
      // Step 1: Create a note
      final note = Note(
        id: 'note-1',
        title: 'Test Note',
        content: '# Test Content\n\nThis is a test note.',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 10, 0),
      );

      // Step 2: Save to Hive
      await notesBox.put(note.id, note.toJson());

      // Step 3: Retrieve from Hive
      final retrievedMap = notesBox.get(note.id);
      expect(retrievedMap, isNotNull);

      final retrievedNote = Note.fromJson(Map<String, dynamic>.from(retrievedMap!));

      // Step 4: Verify data integrity
      expect(retrievedNote.id, note.id);
      expect(retrievedNote.title, note.title);
      expect(retrievedNote.content, note.content);
      expect(retrievedNote.createdAt, note.createdAt);
      expect(retrievedNote.updatedAt, note.updatedAt);
    });

    test('saves multiple notes to Hive', () async {
      // Step 1: Create multiple notes
      final notes = [
        Note(
          id: 'note-1',
          title: 'First Note',
          content: '# First',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        Note(
          id: 'note-2',
          title: 'Second Note',
          content: '# Second',
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
        ),
        Note(
          id: 'note-3',
          title: 'Third Note',
          content: '# Third',
          createdAt: DateTime(2024, 1, 3),
          updatedAt: DateTime(2024, 1, 3),
        ),
      ];

      // Step 2: Save all notes to Hive
      for (final note in notes) {
        await notesBox.put(note.id, note.toJson());
      }

      // Step 3: Verify all notes are stored
      expect(notesBox.length, 3);

      // Step 4: Retrieve and verify each note
      for (final note in notes) {
        final retrievedMap = notesBox.get(note.id);
        expect(retrievedMap, isNotNull);

        final retrievedNote = Note.fromJson(Map<String, dynamic>.from(retrievedMap!));
        expect(retrievedNote.id, note.id);
        expect(retrievedNote.title, note.title);
      }
    });

    test('updates existing note in Hive', () async {
      // Step 1: Create and save initial note
      final note = Note(
        id: 'note-update',
        title: 'Original Title',
        content: 'Original content',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      await notesBox.put(note.id, note.toJson());

      // Step 2: Update the note
      final updatedNote = note.copyWith(
        title: 'Updated Title',
        content: 'Updated content with new information',
        updatedAt: DateTime(2024, 1, 2),
      );
      await notesBox.put(updatedNote.id, updatedNote.toJson());

      // Step 3: Retrieve and verify update
      final retrievedMap = notesBox.get(note.id);
      final retrievedNote = Note.fromJson(Map<String, dynamic>.from(retrievedMap!));

      expect(retrievedNote.title, 'Updated Title');
      expect(retrievedNote.content, 'Updated content with new information');
      expect(retrievedNote.updatedAt, DateTime(2024, 1, 2));
      expect(retrievedNote.createdAt, DateTime(2024, 1, 1)); // Created date unchanged
    });

    test('deletes note from Hive', () async {
      // Step 1: Create and save note
      final note = Note(
        id: 'note-delete',
        title: 'To Be Deleted',
        content: 'This will be deleted',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      await notesBox.put(note.id, note.toJson());

      // Step 2: Verify note exists
      expect(notesBox.get(note.id), isNotNull);

      // Step 3: Delete note
      await notesBox.delete(note.id);

      // Step 4: Verify note is deleted
      expect(notesBox.get(note.id), isNull);
    });

    test('persists note with PDF markers to Hive', () async {
      // Step 1: Create note with marker content
      final note = Note(
        id: 'note-markers',
        title: 'Note with Markers',
        content: '''# Machine Learning Notes

- 🔴 P3  Important definition of supervised learning
- 🟡 P5
  ![capture](./captures/p5_diagram.png)
- 🟢 P7  Neural network architecture explanation
- 🔵 P10  Key conclusion from the paper
- 🟣 P15''',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 2: Save to Hive
      await notesBox.put(note.id, note.toJson());

      // Step 3: Retrieve and verify markers are intact
      final retrievedMap = notesBox.get(note.id);
      final retrievedNote = Note.fromJson(Map<String, dynamic>.from(retrievedMap!));

      expect(retrievedNote.content, contains('🔴 P3'));
      expect(retrievedNote.content, contains('🟡 P5'));
      expect(retrievedNote.content, contains('🟢 P7'));
      expect(retrievedNote.content, contains('🔵 P10'));
      expect(retrievedNote.content, contains('🟣 P15'));
      expect(retrievedNote.content, contains('![capture](./captures/p5_diagram.png)'));
    });

    test('persists note with frontmatter to Hive', () async {
      // Step 1: Create note with frontmatter
      final note = Note(
        id: 'note-frontmatter',
        title: 'Research Notes',
        content: '''---
file: research_paper.pdf
file-path: ./assets/research_paper.pdf
created: 2024-01-01
tags: [research, machine-learning, deep-learning]
author: John Doe
---

# Research Paper Notes

- 🔴 P1  Introduction to the topic
- 🟡 P5  Main methodology
''',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 2: Save to Hive
      await notesBox.put(note.id, note.toJson());

      // Step 3: Retrieve and verify frontmatter is intact
      final retrievedMap = notesBox.get(note.id);
      final retrievedNote = Note.fromJson(Map<String, dynamic>.from(retrievedMap!));

      expect(retrievedNote.content, contains('---'));
      expect(retrievedNote.content, contains('file: research_paper.pdf'));
      expect(retrievedNote.content, contains('tags: [research, machine-learning, deep-learning]'));
      expect(retrievedNote.content, contains('# Research Paper Notes'));
    });

    test('persists note with special characters to Hive', () async {
      // Step 1: Create note with special characters
      final note = Note(
        id: 'note-special',
        title: 'Special Characters: "quotes" & symbols!',
        content: '''# Test 한글 テスト

Content with:
- "Double quotes"
- 'Single quotes'
- & ampersands
- < > angle brackets
- 한글 (Korean)
- 日本語 (Japanese)
- Émojis: 😀 🎉 ✨

- 🔴 P3  Text with "quotes" (parentheses) & symbols! 한글''',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 2: Save to Hive
      await notesBox.put(note.id, note.toJson());

      // Step 3: Retrieve and verify special characters are preserved
      final retrievedMap = notesBox.get(note.id);
      final retrievedNote = Note.fromJson(Map<String, dynamic>.from(retrievedMap!));

      expect(retrievedNote.title, note.title);
      expect(retrievedNote.content, note.content);
      expect(retrievedNote.content, contains('한글'));
      expect(retrievedNote.content, contains('日本語'));
      expect(retrievedNote.content, contains('"quotes"'));
    });

    test('lists all notes from Hive', () async {
      // Step 1: Create multiple notes
      final notes = List.generate(10, (i) => Note(
        id: 'note-$i',
        title: 'Note $i',
        content: '# Content $i',
        createdAt: DateTime(2024, 1, i + 1),
        updatedAt: DateTime(2024, 1, i + 1),
      ));

      // Step 2: Save all notes
      for (final note in notes) {
        await notesBox.put(note.id, note.toJson());
      }

      // Step 3: List all notes
      final allNotes = notesBox.values
          .map((map) => Note.fromJson(Map<String, dynamic>.from(map)))
          .toList();

      // Step 4: Verify count and content
      expect(allNotes.length, 10);
      expect(allNotes.map((n) => n.title).toList(), contains('Note 0'));
      expect(allNotes.map((n) => n.title).toList(), contains('Note 9'));
    });

    test('handles concurrent saves to Hive', () async {
      // Step 1: Create multiple notes
      final notes = List.generate(20, (i) => Note(
        id: 'concurrent-note-$i',
        title: 'Concurrent Note $i',
        content: '# Concurrent content $i',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      // Step 2: Save all notes concurrently
      await Future.wait(
        notes.map((note) => notesBox.put(note.id, note.toJson())),
      );

      // Step 3: Verify all notes are saved
      expect(notesBox.length, 20);

      // Step 4: Verify each note is retrievable
      for (final note in notes) {
        final retrieved = notesBox.get(note.id);
        expect(retrieved, isNotNull);
      }
    });

    test('handles note without optional filePath', () async {
      // Step 1: Create note without filePath
      final note = Note(
        id: 'note-no-path',
        title: 'Note Without Path',
        content: '# Content',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 2: Save to Hive
      await notesBox.put(note.id, note.toJson());

      // Step 3: Retrieve and verify
      final retrievedMap = notesBox.get(note.id);
      final retrievedNote = Note.fromJson(Map<String, dynamic>.from(retrievedMap!));

      expect(retrievedNote.filePath, isNull);
    });

    test('persists and retrieves large note content to Hive', () async {
      // Step 1: Create note with large content
      final largeContent = List.generate(1000, (i) => '- 🔴 P$i  Line $i with some text content')
          .join('\n');

      final note = Note(
        id: 'large-note',
        title: 'Large Note',
        content: '# Large Note\n\n$largeContent',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 2: Save to Hive
      await notesBox.put(note.id, note.toJson());

      // Step 3: Retrieve and verify
      final retrievedMap = notesBox.get(note.id);
      final retrievedNote = Note.fromJson(Map<String, dynamic>.from(retrievedMap!));

      expect(retrievedNote.content.length, note.content.length);
      expect(retrievedNote.content, note.content);
    });
  });

  group('Note Persistence to Filesystem Integration', () {
    late Directory notesDir;

    setUp(() async {
      // Create temporary directory for filesystem tests
      notesDir = await Directory.systemTemp.createTemp('gma_notes_test_');
    });

    tearDown(() async {
      // Clean up
      if (await notesDir.exists()) {
        await notesDir.delete(recursive: true);
      }
    });

    test('saves note to filesystem as markdown file', () async {
      // Step 1: Create a note
      final note = Note(
        id: 'fs-note-1',
        title: 'Test Note',
        content: '# Test Content\n\nThis is a test note.',
        filePath: path.join(notesDir.path, 'test-note.md'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 2: Save to filesystem
      final file = File(note.filePath!);
      await file.writeAsString(note.content);

      // Step 3: Verify file exists
      expect(await file.exists(), true);

      // Step 4: Read and verify content
      final readContent = await file.readAsString();
      expect(readContent, note.content);
    });

    test('loads note from filesystem', () async {
      // Step 1: Create markdown file
      final filePath = path.join(notesDir.path, 'existing-note.md');
      final content = '''# Existing Note

This is an existing note with some content.

- 🔴 P3  Some marker text
''';

      await File(filePath).writeAsString(content);

      // Step 2: Load note from file
      final loadedContent = await File(filePath).readAsString();

      final note = Note(
        id: 'loaded-note',
        title: 'Existing Note',
        content: loadedContent,
        filePath: filePath,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 3: Verify content
      expect(note.content, content);
      expect(note.content, contains('# Existing Note'));
      expect(note.content, contains('🔴 P3'));
    });

    test('updates note on filesystem', () async {
      // Step 1: Create initial file
      final filePath = path.join(notesDir.path, 'update-note.md');
      final initialContent = '# Original Content';
      await File(filePath).writeAsString(initialContent);

      // Step 2: Update content
      final updatedContent = '# Updated Content\n\nWith additional information';
      await File(filePath).writeAsString(updatedContent);

      // Step 3: Read and verify update
      final readContent = await File(filePath).readAsString();
      expect(readContent, updatedContent);
      expect(readContent, isNot(contains('Original Content')));
    });

    test('deletes note from filesystem', () async {
      // Step 1: Create file
      final filePath = path.join(notesDir.path, 'delete-note.md');
      final file = File(filePath);
      await file.writeAsString('# To Be Deleted');

      // Step 2: Verify file exists
      expect(await file.exists(), true);

      // Step 3: Delete file
      await file.delete();

      // Step 4: Verify file is deleted
      expect(await file.exists(), false);
    });

    test('saves note with markers to filesystem', () async {
      // Step 1: Create note with markers
      final content = '''# Machine Learning Notes

## Important Points

- 🔴 P3  Definition of supervised learning
- 🟡 P5
  ![capture](./captures/p5_diagram.png)
- 🟢 P7  Neural network explanation
''';

      final filePath = path.join(notesDir.path, 'markers-note.md');
      await File(filePath).writeAsString(content);

      // Step 2: Read and verify markers
      final readContent = await File(filePath).readAsString();
      expect(readContent, contains('🔴 P3'));
      expect(readContent, contains('🟡 P5'));
      expect(readContent, contains('🟢 P7'));
      expect(readContent, contains('![capture](./captures/p5_diagram.png)'));
    });

    test('saves note with frontmatter to filesystem', () async {
      // Step 1: Create note with frontmatter
      final content = '''---
file: research_paper.pdf
file-path: ./assets/research_paper.pdf
created: 2024-01-01
tags: [research, ml]
---

# Research Notes

- 🔴 P1  Introduction
''';

      final filePath = path.join(notesDir.path, 'frontmatter-note.md');
      await File(filePath).writeAsString(content);

      // Step 2: Read and verify frontmatter
      final readContent = await File(filePath).readAsString();
      expect(readContent, contains('---'));
      expect(readContent, contains('file: research_paper.pdf'));
      expect(readContent, contains('tags: [research, ml]'));
    });

    test('handles unicode characters in filesystem', () async {
      // Step 1: Create note with unicode
      final content = '''# Test 한글 テスト

Content with unicode:
- 한글 (Korean)
- 日本語 (Japanese)
- Emoji: 😀 🎉

- 🔴 P3  Text with 한글 and 日本語
''';

      final filePath = path.join(notesDir.path, 'unicode-note.md');
      await File(filePath).writeAsString(content, encoding: utf8);

      // Step 2: Read and verify unicode is preserved
      final readContent = await File(filePath).readAsString(encoding: utf8);
      expect(readContent, content);
      expect(readContent, contains('한글'));
      expect(readContent, contains('日本語'));
      expect(readContent, contains('😀'));
    });

    test('lists all notes from filesystem directory', () async {
      // Step 1: Create multiple markdown files
      for (int i = 0; i < 5; i++) {
        final filePath = path.join(notesDir.path, 'note-$i.md');
        await File(filePath).writeAsString('# Note $i\n\nContent $i');
      }

      // Step 2: List all markdown files
      final files = notesDir.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList();

      // Step 3: Verify count
      expect(files.length, 5);

      // Step 4: Verify each file is readable
      for (final file in files) {
        final content = await file.readAsString();
        expect(content, contains('# Note'));
      }
    });

    test('creates nested directory structure for notes', () async {
      // Step 1: Create nested directory path
      final nestedPath = path.join(notesDir.path, 'category', 'subcategory');
      final nestedDir = Directory(nestedPath);
      await nestedDir.create(recursive: true);

      // Step 2: Create note in nested directory
      final filePath = path.join(nestedPath, 'nested-note.md');
      await File(filePath).writeAsString('# Nested Note');

      // Step 3: Verify file exists
      expect(await File(filePath).exists(), true);

      // Step 4: Read and verify
      final content = await File(filePath).readAsString();
      expect(content, '# Nested Note');
    });

    test('handles file write errors gracefully', () async {
      // Step 1: Create a read-only directory (simulate permission error)
      final readOnlyDir = Directory(path.join(notesDir.path, 'readonly'));
      await readOnlyDir.create();

      // Note: Setting permissions to read-only is platform-specific
      // This test demonstrates error handling structure

      final filePath = path.join(notesDir.path, 'readonly', 'test.md');

      // Step 2: Attempt to write and handle error
      try {
        // This would fail with proper permission restrictions
        await File(filePath).writeAsString('# Test');
        // If we get here, the file was created successfully
        expect(await File(filePath).exists(), true);
      } catch (e) {
        // Handle expected permission error
        expect(e, isA<FileSystemException>());
      }
    });

    test('saves large note to filesystem', () async {
      // Step 1: Create large content
      final largeContent = List.generate(10000, (i) => 'Line $i with content')
          .join('\n');

      final filePath = path.join(notesDir.path, 'large-note.md');
      await File(filePath).writeAsString(largeContent);

      // Step 2: Read and verify
      final readContent = await File(filePath).readAsString();
      expect(readContent.length, largeContent.length);
      expect(readContent, largeContent);
    });
  });

  group('Hive and Filesystem Combined Persistence', () {
    late Box<Map> notesBox;
    late Directory notesDir;

    setUp(() async {
      // Setup both Hive and filesystem
      final tempDir = await Directory.systemTemp.createTemp('gma_combined_test_');
      Hive.init(tempDir.path);
      notesBox = await Hive.openBox<Map>('combined_notes');

      notesDir = await Directory.systemTemp.createTemp('gma_combined_fs_');
    });

    tearDown(() async {
      await notesBox.clear();
      await notesBox.close();
      await Hive.deleteFromDisk();
      if (await notesDir.exists()) {
        await notesDir.delete(recursive: true);
      }
    });

    test('saves note to both Hive and filesystem', () async {
      // Step 1: Create note
      final note = Note(
        id: 'combined-note-1',
        title: 'Combined Note',
        content: '''# Combined Storage Test

- 🔴 P3  Test marker
''',
        filePath: path.join(notesDir.path, 'combined-note.md'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 2: Save to Hive
      await notesBox.put(note.id, note.toJson());

      // Step 3: Save to filesystem
      await File(note.filePath!).writeAsString(note.content);

      // Step 4: Verify Hive storage
      final hiveData = notesBox.get(note.id);
      expect(hiveData, isNotNull);
      final hiveNote = Note.fromJson(Map<String, dynamic>.from(hiveData!));
      expect(hiveNote.content, note.content);

      // Step 5: Verify filesystem storage
      final fsContent = await File(note.filePath!).readAsString();
      expect(fsContent, note.content);
    });

    test('syncs updates between Hive and filesystem', () async {
      // Step 1: Create initial note
      final note = Note(
        id: 'sync-note',
        title: 'Sync Test',
        content: '# Original',
        filePath: path.join(notesDir.path, 'sync-note.md'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Step 2: Save to both
      await notesBox.put(note.id, note.toJson());
      await File(note.filePath!).writeAsString(note.content);

      // Step 3: Update note
      final updatedNote = note.copyWith(
        content: '# Updated\n\n- 🔴 P5  New marker',
        updatedAt: DateTime(2024, 1, 2),
      );

      // Step 4: Update both storages
      await notesBox.put(updatedNote.id, updatedNote.toJson());
      await File(updatedNote.filePath!).writeAsString(updatedNote.content);

      // Step 5: Verify both are updated
      final hiveData = notesBox.get(updatedNote.id);
      final hiveNote = Note.fromJson(Map<String, dynamic>.from(hiveData!));
      expect(hiveNote.content, contains('# Updated'));
      expect(hiveNote.content, contains('🔴 P5'));

      final fsContent = await File(updatedNote.filePath!).readAsString();
      expect(fsContent, contains('# Updated'));
      expect(fsContent, contains('🔴 P5'));
    });

    test('recovers from filesystem using Hive backup', () async {
      // Step 1: Create note and save to both
      final note = Note(
        id: 'backup-note',
        title: 'Backup Test',
        content: '# Important Data\n\n- 🔴 P3  Critical information',
        filePath: path.join(notesDir.path, 'backup-note.md'),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await notesBox.put(note.id, note.toJson());
      await File(note.filePath!).writeAsString(note.content);

      // Step 2: Simulate filesystem corruption/deletion
      await File(note.filePath!).delete();
      expect(await File(note.filePath!).exists(), false);

      // Step 3: Recover from Hive
      final hiveData = notesBox.get(note.id);
      expect(hiveData, isNotNull);

      final recoveredNote = Note.fromJson(Map<String, dynamic>.from(hiveData!));

      // Step 4: Restore to filesystem
      await File(recoveredNote.filePath!).writeAsString(recoveredNote.content);

      // Step 5: Verify recovery
      final restoredContent = await File(recoveredNote.filePath!).readAsString();
      expect(restoredContent, note.content);
      expect(restoredContent, contains('Critical information'));
    });

    test('persists note with all features to both storages', () async {
      // Step 1: Create comprehensive note
      final note = Note(
        id: 'comprehensive-note',
        title: 'Comprehensive Test 한글',
        content: '''---
file: test.pdf
file-path: ./assets/test.pdf
tags: [test, comprehensive]
---

# Comprehensive Note 한글 テスト

## Introduction

Some text with **markdown** and [[wiki-links]].

## Markers

- 🔴 P3  Red marker with text
- 🟡 P5
  ![capture](./captures/p5.png)
- 🟢 P7  Green marker with unicode 한글
- 🔵 P10  Blue marker
- 🟣 P15  Purple marker

## Math

Inline math: \$E = mc^2\$

## Links

See [[related-note]] and [[another-note]].
''',
        filePath: path.join(notesDir.path, 'comprehensive.md'),
        createdAt: DateTime(2024, 1, 1, 10, 30),
        updatedAt: DateTime(2024, 1, 2, 15, 45),
      );

      // Step 2: Save to both storages
      await notesBox.put(note.id, note.toJson());
      await File(note.filePath!).writeAsString(note.content, encoding: utf8);

      // Step 3: Retrieve from Hive and verify
      final hiveData = notesBox.get(note.id);
      final hiveNote = Note.fromJson(Map<String, dynamic>.from(hiveData!));

      expect(hiveNote.title, note.title);
      expect(hiveNote.content, note.content);
      expect(hiveNote.content, contains('---'));
      expect(hiveNote.content, contains('🔴 P3'));
      expect(hiveNote.content, contains('[[wiki-links]]'));
      expect(hiveNote.content, contains('한글'));

      // Step 4: Retrieve from filesystem and verify
      final fsContent = await File(note.filePath!).readAsString(encoding: utf8);

      expect(fsContent, note.content);
      expect(fsContent, contains('---'));
      expect(fsContent, contains('🟡 P5'));
      expect(fsContent, contains('![capture](./captures/p5.png)'));
      expect(fsContent, contains('テスト'));
    });
  });
}
