import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/note_editor/models/note_model.dart';

void main() {
  group('Note', () {
    group('serialization with all fields', () {
      test('toJson creates valid JSON with all fields including optionals', () {
        final createdAt = DateTime(2024, 1, 15, 10, 30, 0);
        final updatedAt = DateTime(2024, 1, 16, 14, 45, 0);

        final note = Note(
          id: 'note-123',
          title: 'My Research Notes',
          content: '''---
tags: [research, pdf]
---

# My Research Notes

- 🔴 P3  Important passage
- 🟡 P5  Key diagram
''',
          filePath: './notes/research.md',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = note.toJson();

        expect(json['id'], 'note-123');
        expect(json['title'], 'My Research Notes');
        expect(json['content'], contains('Important passage'));
        expect(json['filePath'], './notes/research.md');
        expect(json['createdAt'], createdAt.toIso8601String());
        expect(json['updatedAt'], updatedAt.toIso8601String());
      });

      test('fromJson creates valid Note with all fields', () {
        final json = {
          'id': 'note-456',
          'title': 'Study Guide',
          'content': '# Study Guide\n\nKey concepts...',
          'filePath': './notes/study.md',
          'createdAt': '2024-02-01T10:00:00.000Z',
          'updatedAt': '2024-02-02T15:30:00.000Z',
        };

        final note = Note.fromJson(json);

        expect(note.id, 'note-456');
        expect(note.title, 'Study Guide');
        expect(note.content, '# Study Guide\n\nKey concepts...');
        expect(note.filePath, './notes/study.md');
        expect(note.createdAt, DateTime.parse('2024-02-01T10:00:00.000Z'));
        expect(note.updatedAt, DateTime.parse('2024-02-02T15:30:00.000Z'));
      });

      test('roundtrip serialization with all fields maintains data integrity',
          () {
        final createdAt = DateTime(2024, 3, 10, 8, 0, 0);
        final updatedAt = DateTime(2024, 3, 11, 12, 30, 0);

        final original = Note(
          id: 'note-789',
          title: 'Lecture Notes',
          content: '# Lecture 1\n\nNotes from today...',
          filePath: './notes/lecture1.md',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = original.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('serialization with minimal required fields', () {
      test('toJson creates valid JSON with only required fields', () {
        final createdAt = DateTime(2024, 1, 1, 0, 0, 0);
        final updatedAt = DateTime(2024, 1, 1, 0, 0, 0);

        final note = Note(
          id: 'note-minimal',
          title: 'Minimal Note',
          content: 'Simple content',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = note.toJson();

        expect(json['id'], 'note-minimal');
        expect(json['title'], 'Minimal Note');
        expect(json['content'], 'Simple content');
        expect(json.containsKey('filePath'), true);
        expect(json['filePath'], null);
        expect(json['createdAt'], createdAt.toIso8601String());
        expect(json['updatedAt'], updatedAt.toIso8601String());
      });

      test('fromJson creates valid Note with only required fields', () {
        final json = {
          'id': 'note-required-only',
          'title': 'Basic Note',
          'content': 'Basic content',
          'createdAt': '2024-01-15T10:00:00.000Z',
          'updatedAt': '2024-01-15T10:00:00.000Z',
        };

        final note = Note.fromJson(json);

        expect(note.id, 'note-required-only');
        expect(note.title, 'Basic Note');
        expect(note.content, 'Basic content');
        expect(note.filePath, null);
        expect(note.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
        expect(note.updatedAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
      });

      test('roundtrip serialization with minimal fields maintains data', () {
        final createdAt = DateTime(2024, 1, 1, 0, 0, 0);
        final updatedAt = DateTime(2024, 1, 1, 0, 0, 0);

        final original = Note(
          id: 'note-minimal-roundtrip',
          title: 'Roundtrip Note',
          content: 'Content',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = original.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('DateTime serialization', () {
      test('handles different DateTime formats correctly', () {
        final timestamps = [
          DateTime(2024, 1, 1, 0, 0, 0),
          DateTime(2024, 12, 31, 23, 59, 59),
          DateTime(2024, 6, 15, 12, 30, 45, 123),
          DateTime.utc(2024, 3, 10, 14, 30, 0),
        ];

        for (final timestamp in timestamps) {
          final note = Note(
            id: 'note-time-test',
            title: 'Time Test',
            content: 'Content',
            createdAt: timestamp,
            updatedAt: timestamp,
          );

          final json = note.toJson();
          final deserialized = Note.fromJson(json);

          expect(deserialized.createdAt, timestamp);
          expect(deserialized.updatedAt, timestamp);
        }
      });

      test('handles ISO8601 timestamp strings correctly', () {
        final json = {
          'id': 'note-iso-test',
          'title': 'ISO Test',
          'content': 'Content',
          'createdAt': '2024-01-15T10:30:45.123Z',
          'updatedAt': '2024-01-16T14:20:30.456Z',
        };

        final note = Note.fromJson(json);

        expect(note.createdAt.year, 2024);
        expect(note.createdAt.month, 1);
        expect(note.createdAt.day, 15);
        expect(note.updatedAt.year, 2024);
        expect(note.updatedAt.month, 1);
        expect(note.updatedAt.day, 16);
      });

      test('createdAt and updatedAt can be the same', () {
        final now = DateTime(2024, 6, 15, 10, 0, 0);

        final note = Note(
          id: 'note-same-time',
          title: 'New Note',
          content: 'Just created',
          createdAt: now,
          updatedAt: now,
        );

        expect(note.createdAt, note.updatedAt);

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.createdAt, deserialized.updatedAt);
      });

      test('updatedAt can be after createdAt', () {
        final created = DateTime(2024, 1, 1, 10, 0, 0);
        final updated = DateTime(2024, 1, 5, 15, 30, 0);

        final note = Note(
          id: 'note-updated',
          title: 'Updated Note',
          content: 'Modified content',
          createdAt: created,
          updatedAt: updated,
        );

        expect(note.updatedAt.isAfter(note.createdAt), true);

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.updatedAt.isAfter(deserialized.createdAt), true);
      });
    });

    group('content edge cases', () {
      test('handles empty content string', () {
        final note = Note(
          id: 'note-empty',
          title: 'Empty Note',
          content: '',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content, '');
        expect(deserialized, note);
      });

      test('handles very long content', () {
        final longContent = 'A' * 100000;

        final note = Note(
          id: 'note-long',
          title: 'Long Note',
          content: longContent,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content.length, 100000);
        expect(deserialized, note);
      });

      test('handles content with special characters', () {
        const specialContent = r'''
Special chars: 한글 日本語 😀 🔴 🟡
Newlines and tabs:
	- Item 1
	- Item 2
Quotes: "double" 'single'
Math: $x^2 + y^2 = z^2$
''';

        final note = Note(
          id: 'note-special',
          title: 'Special Content',
          content: specialContent,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content, specialContent);
        expect(deserialized, note);
      });

      test('handles content with frontmatter YAML', () {
        const frontmatterContent = '''---
title: My Note
tags: [research, important]
date: 2024-01-15
---

# Actual Content

Body text here.
''';

        final note = Note(
          id: 'note-frontmatter',
          title: 'Note with Frontmatter',
          content: frontmatterContent,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content, frontmatterContent);
        expect(deserialized, note);
      });

      test('handles content with PDF markers', () {
        const markerContent = '''# Research Notes

- 🔴 P3  Important passage about quantum mechanics
- 🟡 P5  Diagram showing wave function
- 🟢 P10  Conclusion section

## Analysis

More notes here...
''';

        final note = Note(
          id: 'note-markers',
          title: 'Notes with Markers',
          content: markerContent,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content, markerContent);
        expect(deserialized, note);
      });

      test('handles content with LaTeX expressions', () {
        const latexContent = r'''# Math Notes

Inline math: $E = mc^2$

Block math:
$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$

More content...
''';

        final note = Note(
          id: 'note-latex',
          title: 'LaTeX Notes',
          content: latexContent,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content, latexContent);
        expect(deserialized, note);
      });

      test('handles content with wiki-links', () {
        const wikiLinkContent = '''# Connected Notes

See [[Other Note]] for more details.
Also related: [[Research/Topic A]] and [[Ideas/Concept B]].

[[Nested/Path/Note]]
''';

        final note = Note(
          id: 'note-wikilinks',
          title: 'Note with Wiki-links',
          content: wikiLinkContent,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content, wikiLinkContent);
        expect(deserialized, note);
      });
    });

    group('title edge cases', () {
      test('handles empty title string', () {
        final note = Note(
          id: 'note-empty-title',
          title: '',
          content: 'Some content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.title, '');
        expect(deserialized, note);
      });

      test('handles very long title', () {
        final longTitle = 'T' * 1000;

        final note = Note(
          id: 'note-long-title',
          title: longTitle,
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.title.length, 1000);
        expect(deserialized, note);
      });

      test('handles title with special characters', () {
        const specialTitle = '📝 My Note [Research] 한글 日本語';

        final note = Note(
          id: 'note-special-title',
          title: specialTitle,
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.title, specialTitle);
        expect(deserialized, note);
      });
    });

    group('filePath edge cases', () {
      test('handles empty string filePath', () {
        final note = Note(
          id: 'note-empty-path',
          title: 'Note',
          content: 'Content',
          filePath: '',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.filePath, '');
        expect(deserialized, note);
      });

      test('handles Windows-style file paths', () {
        final note = Note(
          id: 'note-windows-path',
          title: 'Note',
          content: 'Content',
          filePath: r'C:\Users\Documents\notes\file.md',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.filePath, r'C:\Users\Documents\notes\file.md');
        expect(deserialized, note);
      });

      test('handles Unix-style file paths', () {
        final note = Note(
          id: 'note-unix-path',
          title: 'Note',
          content: 'Content',
          filePath: '/home/user/documents/notes/file.md',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.filePath, '/home/user/documents/notes/file.md');
        expect(deserialized, note);
      });

      test('handles relative file paths', () {
        final note = Note(
          id: 'note-relative-path',
          title: 'Note',
          content: 'Content',
          filePath: './notes/subfolder/file.md',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.filePath, './notes/subfolder/file.md');
        expect(deserialized, note);
      });
    });

    group('ID edge cases', () {
      test('handles UUID-style IDs', () {
        final note = Note(
          id: '550e8400-e29b-41d4-a716-446655440000',
          title: 'Note',
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(deserialized, note);
      });

      test('handles short IDs', () {
        final note = Note(
          id: '1',
          title: 'Note',
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.id, '1');
        expect(deserialized, note);
      });

      test('handles IDs with special characters', () {
        final note = Note(
          id: 'note-2024_01_15-v2',
          title: 'Note',
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.id, 'note-2024_01_15-v2');
        expect(deserialized, note);
      });
    });

    group('equality', () {
      test('two Notes with same values are equal', () {
        final createdAt = DateTime(2024, 1, 1);
        final updatedAt = DateTime(2024, 1, 2);

        final note1 = Note(
          id: 'same-id',
          title: 'Same Title',
          content: 'Same content',
          filePath: './same/path.md',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final note2 = Note(
          id: 'same-id',
          title: 'Same Title',
          content: 'Same content',
          filePath: './same/path.md',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(note1, equals(note2));
        expect(note1.hashCode, equals(note2.hashCode));
      });

      test('two Notes with different IDs are not equal', () {
        final timestamp = DateTime(2024, 1, 1);

        final note1 = Note(
          id: 'id-1',
          title: 'Title',
          content: 'Content',
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final note2 = Note(
          id: 'id-2',
          title: 'Title',
          content: 'Content',
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        expect(note1, isNot(equals(note2)));
      });

      test('two Notes with different titles are not equal', () {
        final timestamp = DateTime(2024, 1, 1);

        final note1 = Note(
          id: 'same-id',
          title: 'Title 1',
          content: 'Content',
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final note2 = Note(
          id: 'same-id',
          title: 'Title 2',
          content: 'Content',
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        expect(note1, isNot(equals(note2)));
      });

      test('two Notes with different content are not equal', () {
        final timestamp = DateTime(2024, 1, 1);

        final note1 = Note(
          id: 'same-id',
          title: 'Title',
          content: 'Content 1',
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final note2 = Note(
          id: 'same-id',
          title: 'Title',
          content: 'Content 2',
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        expect(note1, isNot(equals(note2)));
      });

      test('two Notes with different timestamps are not equal', () {
        final note1 = Note(
          id: 'same-id',
          title: 'Title',
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final note2 = Note(
          id: 'same-id',
          title: 'Title',
          content: 'Content',
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(note1, isNot(equals(note2)));
      });
    });

    group('copyWith', () {
      test('copyWith updates id', () {
        final note = Note(
          id: 'old-id',
          title: 'Title',
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final updated = note.copyWith(id: 'new-id');

        expect(updated.id, 'new-id');
        expect(updated.title, 'Title');
        expect(updated.content, 'Content');
      });

      test('copyWith updates title', () {
        final note = Note(
          id: 'id',
          title: 'Old Title',
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final updated = note.copyWith(title: 'New Title');

        expect(updated.id, 'id');
        expect(updated.title, 'New Title');
        expect(updated.content, 'Content');
      });

      test('copyWith updates content', () {
        final note = Note(
          id: 'id',
          title: 'Title',
          content: 'Old content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final updated = note.copyWith(content: 'New content');

        expect(updated.id, 'id');
        expect(updated.title, 'Title');
        expect(updated.content, 'New content');
      });

      test('copyWith adds filePath', () {
        final note = Note(
          id: 'id',
          title: 'Title',
          content: 'Content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final updated = note.copyWith(filePath: './notes/new.md');

        expect(updated.filePath, './notes/new.md');
      });

      test('copyWith removes filePath by setting to null', () {
        final note = Note(
          id: 'id',
          title: 'Title',
          content: 'Content',
          filePath: './old/path.md',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final updated = note.copyWith(filePath: null);

        expect(updated.filePath, null);
      });

      test('copyWith updates createdAt', () {
        final oldDate = DateTime(2024, 1, 1);
        final newDate = DateTime(2024, 2, 1);

        final note = Note(
          id: 'id',
          title: 'Title',
          content: 'Content',
          createdAt: oldDate,
          updatedAt: oldDate,
        );

        final updated = note.copyWith(createdAt: newDate);

        expect(updated.createdAt, newDate);
        expect(updated.updatedAt, oldDate);
      });

      test('copyWith updates updatedAt', () {
        final createdDate = DateTime(2024, 1, 1);
        final oldUpdatedDate = DateTime(2024, 1, 2);
        final newUpdatedDate = DateTime(2024, 1, 3);

        final note = Note(
          id: 'id',
          title: 'Title',
          content: 'Content',
          createdAt: createdDate,
          updatedAt: oldUpdatedDate,
        );

        final updated = note.copyWith(updatedAt: newUpdatedDate);

        expect(updated.createdAt, createdDate);
        expect(updated.updatedAt, newUpdatedDate);
      });

      test('copyWith updates multiple fields at once', () {
        final note = Note(
          id: 'id',
          title: 'Old Title',
          content: 'Old content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final newUpdatedAt = DateTime(2024, 1, 5);
        final updated = note.copyWith(
          title: 'New Title',
          content: 'New content',
          filePath: './new/path.md',
          updatedAt: newUpdatedAt,
        );

        expect(updated.id, 'id');
        expect(updated.title, 'New Title');
        expect(updated.content, 'New content');
        expect(updated.filePath, './new/path.md');
        expect(updated.updatedAt, newUpdatedAt);
      });

      test('copyWith with no arguments returns equal object', () {
        final note = Note(
          id: 'id',
          title: 'Title',
          content: 'Content',
          filePath: './path.md',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        final copy = note.copyWith();

        expect(copy, equals(note));
      });
    });

    group('real-world scenarios', () {
      test('new empty note created', () {
        final now = DateTime.now();

        final note = Note(
          id: 'new-note-1',
          title: 'Untitled',
          content: '',
          createdAt: now,
          updatedAt: now,
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, note);
        expect(deserialized.content, '');
        expect(deserialized.createdAt, deserialized.updatedAt);
      });

      test('note with frontmatter and markers', () {
        const content = '''---
title: Research Paper Analysis
tags: [physics, quantum-mechanics]
author: John Doe
date: 2024-01-15
---

# Research Paper Analysis

## Key Points

- 🔴 P3  The wave function represents probability amplitude
- 🟡 P5  Heisenberg uncertainty principle diagram
- 🟢 P10  Experimental verification results

## My Analysis

This paper provides compelling evidence for...
''';

        final note = Note(
          id: 'research-note-1',
          title: 'Research Paper Analysis',
          content: content,
          filePath: './notes/research/quantum-paper.md',
          createdAt: DateTime(2024, 1, 15, 9, 0, 0),
          updatedAt: DateTime(2024, 1, 15, 17, 30, 0),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, note);
        expect(deserialized.content, contains('wave function'));
        expect(deserialized.content, contains('🔴 P3'));
        expect(deserialized.updatedAt.isAfter(deserialized.createdAt), true);
      });

      test('note with LaTeX equations', () {
        const content = r'''# Calculus Notes

## Derivatives

The derivative of $f(x) = x^2$ is:

$$
\frac{d}{dx}(x^2) = 2x
$$

## Integration

$$
\int_{0}^{1} x^2 dx = \frac{1}{3}
$$
''';

        final note = Note(
          id: 'calculus-note',
          title: 'Calculus Notes',
          content: content,
          filePath: './notes/math/calculus.md',
          createdAt: DateTime(2024, 2, 1, 10, 0, 0),
          updatedAt: DateTime(2024, 2, 1, 11, 30, 0),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, note);
        expect(deserialized.content, contains(r'$f(x) = x^2$'));
        expect(deserialized.content, contains(r'\int_{0}^{1}'));
      });

      test('note with wiki-links and cross-references', () {
        const content = '''# Project Planning

See [[Project Overview]] for context.

## Related Documents

- [[Requirements/Functional Requirements]]
- [[Design/Architecture]]
- [[Tasks/Sprint 1]]

Link to [[Team/Members#john-doe]] for more info.
''';

        final note = Note(
          id: 'planning-note',
          title: 'Project Planning',
          content: content,
          filePath: './notes/projects/planning.md',
          createdAt: DateTime(2024, 3, 1, 14, 0, 0),
          updatedAt: DateTime(2024, 3, 5, 16, 45, 0),
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, note);
        expect(deserialized.content, contains('[[Project Overview]]'));
        expect(deserialized.content, contains('[[Requirements/Functional Requirements]]'));
      });

      test('list of notes from different categories', () {
        final notes = [
          Note(
            id: 'note-1',
            title: 'Daily Journal',
            content: '# Today\n\nWent to the library...',
            filePath: './notes/journal/2024-01-15.md',
            createdAt: DateTime(2024, 1, 15),
            updatedAt: DateTime(2024, 1, 15),
          ),
          Note(
            id: 'note-2',
            title: 'Meeting Notes',
            content: '# Team Meeting\n\n- Discussed project...',
            filePath: './notes/meetings/team-2024-01-16.md',
            createdAt: DateTime(2024, 1, 16),
            updatedAt: DateTime(2024, 1, 16),
          ),
          Note(
            id: 'note-3',
            title: 'Research Ideas',
            content: '# Ideas\n\n- Explore quantum computing...',
            filePath: './notes/research/ideas.md',
            createdAt: DateTime(2024, 1, 17),
            updatedAt: DateTime(2024, 1, 20),
          ),
        ];

        final jsonList = notes.map((n) => n.toJson()).toList();
        final deserialized = jsonList.map((j) => Note.fromJson(j)).toList();

        expect(deserialized.length, 3);
        expect(deserialized[0], notes[0]);
        expect(deserialized[1], notes[1]);
        expect(deserialized[2], notes[2]);
      });

      test('updating note content preserves metadata', () {
        final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
        final originalUpdatedAt = DateTime(2024, 1, 1, 10, 0, 0);

        final original = Note(
          id: 'note-update-test',
          title: 'My Note',
          content: 'Original content',
          filePath: './notes/test.md',
          createdAt: createdAt,
          updatedAt: originalUpdatedAt,
        );

        // Simulate updating the note
        final newUpdatedAt = DateTime(2024, 1, 2, 15, 30, 0);
        final updated = original.copyWith(
          content: 'Updated content with more information',
          updatedAt: newUpdatedAt,
        );

        expect(updated.id, original.id);
        expect(updated.title, original.title);
        expect(updated.filePath, original.filePath);
        expect(updated.createdAt, original.createdAt);
        expect(updated.content, 'Updated content with more information');
        expect(updated.updatedAt, newUpdatedAt);
        expect(updated.updatedAt.isAfter(updated.createdAt), true);

        // Verify serialization after update
        final json = updated.toJson();
        final deserialized = Note.fromJson(json);
        expect(deserialized, updated);
      });
    });
  });
}
