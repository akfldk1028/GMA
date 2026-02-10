import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/note_editor/models/note_model.dart';

void main() {
  group('Note', () {
    group('serialization', () {
      test('toJson creates valid JSON with required fields', () {
        final note = Note(
          id: 'note-123',
          frontmatter: null,
          content: '''# My Research Notes

- 🔴 P3  Important passage
- 🟡 P5  Key diagram
''',
          markers: [],
        );

        final json = note.toJson();

        expect(json['id'], 'note-123');
        expect(json['content'], contains('Important passage'));
        expect(json['markers'], isList);
      });

      test('fromJson creates valid Note', () {
        final json = {
          'id': 'note-456',
          'content': '# Study Guide\n\nKey concepts...',
          'markers': [],
        };

        final note = Note.fromJson(json);

        expect(note.id, 'note-456');
        expect(note.content, '# Study Guide\n\nKey concepts...');
        expect(note.frontmatter, null);
        expect(note.markers, isEmpty);
      });

      test('roundtrip serialization maintains data integrity', () {
        final original = Note(
          id: 'note-789',
          frontmatter: null,
          content: '# Lecture 1\n\nNotes from today...',
          markers: [],
        );

        final json = original.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('content edge cases', () {
      test('handles empty content string', () {
        final note = Note(
          id: 'note-empty',
          frontmatter: null,
          content: '',
          markers: [],
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
          frontmatter: null,
          content: longContent,
          markers: [],
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
          frontmatter: null,
          content: specialContent,
          markers: [],
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content, specialContent);
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
          frontmatter: null,
          content: markerContent,
          markers: [],
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
          frontmatter: null,
          content: latexContent,
          markers: [],
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
          frontmatter: null,
          content: wikiLinkContent,
          markers: [],
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.content, wikiLinkContent);
        expect(deserialized, note);
      });
    });

    group('ID edge cases', () {
      test('handles UUID-style IDs', () {
        final note = Note(
          id: '550e8400-e29b-41d4-a716-446655440000',
          frontmatter: null,
          content: 'Content',
          markers: [],
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(deserialized, note);
      });

      test('handles short IDs', () {
        final note = Note(
          id: '1',
          frontmatter: null,
          content: 'Content',
          markers: [],
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.id, '1');
        expect(deserialized, note);
      });

      test('handles IDs with special characters', () {
        final note = Note(
          id: 'note-2024_01_15-v2',
          frontmatter: null,
          content: 'Content',
          markers: [],
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.id, 'note-2024_01_15-v2');
        expect(deserialized, note);
      });
    });

    group('equality', () {
      test('two Notes with same values are equal', () {
        final note1 = Note(
          id: 'same-id',
          frontmatter: null,
          content: 'Same content',
          markers: [],
        );

        final note2 = Note(
          id: 'same-id',
          frontmatter: null,
          content: 'Same content',
          markers: [],
        );

        expect(note1, equals(note2));
        expect(note1.hashCode, equals(note2.hashCode));
      });

      test('two Notes with different IDs are not equal', () {
        final note1 = Note(
          id: 'id-1',
          frontmatter: null,
          content: 'Content',
          markers: [],
        );

        final note2 = Note(
          id: 'id-2',
          frontmatter: null,
          content: 'Content',
          markers: [],
        );

        expect(note1, isNot(equals(note2)));
      });

      test('two Notes with different content are not equal', () {
        final note1 = Note(
          id: 'same-id',
          frontmatter: null,
          content: 'Content 1',
          markers: [],
        );

        final note2 = Note(
          id: 'same-id',
          frontmatter: null,
          content: 'Content 2',
          markers: [],
        );

        expect(note1, isNot(equals(note2)));
      });
    });

    group('copyWith', () {
      test('copyWith updates id', () {
        final note = Note(
          id: 'old-id',
          frontmatter: null,
          content: 'Content',
          markers: [],
        );

        final updated = note.copyWith(id: 'new-id');

        expect(updated.id, 'new-id');
        expect(updated.content, 'Content');
      });

      test('copyWith updates content', () {
        final note = Note(
          id: 'id',
          frontmatter: null,
          content: 'Old content',
          markers: [],
        );

        final updated = note.copyWith(content: 'New content');

        expect(updated.id, 'id');
        expect(updated.content, 'New content');
      });

      test('copyWith with no arguments returns equal object', () {
        final note = Note(
          id: 'id',
          frontmatter: null,
          content: 'Content',
          markers: [],
        );

        final copy = note.copyWith();

        expect(copy, equals(note));
      });
    });

    group('real-world scenarios', () {
      test('new empty note created', () {
        final note = Note(
          id: 'new-note-1',
          frontmatter: null,
          content: '',
          markers: [],
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, note);
        expect(deserialized.content, '');
      });

      test('note with markers', () {
        const content = '''# Research Paper Analysis

## Key Points

- 🔴 P3  The wave function represents probability amplitude
- 🟡 P5  Heisenberg uncertainty principle diagram
- 🟢 P10  Experimental verification results

## My Analysis

This paper provides compelling evidence for...
''';

        final note = Note(
          id: 'research-note-1',
          frontmatter: null,
          content: content,
          markers: [],
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, note);
        expect(deserialized.content, contains('wave function'));
        expect(deserialized.content, contains('🔴 P3'));
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
          frontmatter: null,
          content: content,
          markers: [],
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
          frontmatter: null,
          content: content,
          markers: [],
        );

        final json = note.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized, note);
        expect(deserialized.content, contains('[[Project Overview]]'));
        expect(deserialized.content, contains('[[Requirements/Functional Requirements]]'));
      });

      test('updating note content', () {
        final original = Note(
          id: 'note-update-test',
          frontmatter: null,
          content: 'Original content',
          markers: [],
        );

        final updated = original.copyWith(
          content: 'Updated content with more information',
        );

        expect(updated.id, original.id);
        expect(updated.content, 'Updated content with more information');

        // Verify serialization after update
        final json = updated.toJson();
        final deserialized = Note.fromJson(json);
        expect(deserialized, updated);
      });
    });
  });
}
