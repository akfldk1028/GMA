import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/note_editor/models/note_model.dart';
import 'package:gma_frontend/features/note_editor/utils/marker_parser.dart';
import 'package:gma_frontend/features/pdf_viewer/models/pdf_marker_model.dart';

void main() {
  group('PDF to Note Marker Creation Flow', () {
    test('creates text selection marker and adds to note', () {
      // Step 1: Simulate PDF text selection - create marker
      final marker = PdfMarker(
        id: 'marker-1',
        pageNumber: 3,
        color: MarkerColor.red,
        selectedText: 'Dictionary-based sentiment analysis is...',
        textRect: const PdfRect(x: 72.0, y: 144.0, width: 300.0, height: 24.0),
      );

      // Step 2: Format marker as markdown line
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}';

      // Step 3: Add marker to note content
      final note = Note(
        id: 'note-1',        content: '# Machine Learning\n\n$markerLine',
        markers: [],
      );

      // Step 4: Verify marker line is in note content
      expect(note.content, contains(markerLine));
      expect(note.content, contains('🔴'));
      expect(note.content, contains('P3'));
      expect(note.content, contains('Dictionary-based sentiment analysis is...'));

      // Step 5: Parse marker back from note content
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].isMarkerLine, true);
      expect(parsedMarkers[0].color, MarkerColor.red);
      expect(parsedMarkers[0].pageNumber, 3);
      expect(parsedMarkers[0].text, 'Dictionary-based sentiment analysis is...');
    });

    test('creates image capture marker and adds to note', () {
      // Step 1: Simulate PDF region capture - create marker with image
      final marker = PdfMarker(
        id: 'marker-2',
        pageNumber: 5,
        color: MarkerColor.yellow,
        capturedImagePath: './captures/p5_capture.png',
        textRect: const PdfRect(x: 100.0, y: 200.0, width: 400.0, height: 300.0),
      );

      // Step 2: Format marker as markdown with image embed
      final markerLines = '''- ${marker.color.emoji} P${marker.pageNumber}
  ![capture](${marker.capturedImagePath})''';

      // Step 3: Add marker to note content
      final note = Note(
        id: 'note-2',        content: '# Notes\n\n$markerLines',
        markers: [],
      );

      // Step 4: Verify marker and image are in note content
      expect(note.content, contains('🟡'));
      expect(note.content, contains('P5'));
      expect(note.content, contains('![capture](./captures/p5_capture.png)'));

      // Step 5: Parse marker with image from note content
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].color, MarkerColor.yellow);
      expect(parsedMarkers[0].pageNumber, 5);
      expect(parsedMarkers[0].imagePath, './captures/p5_capture.png');
    });

    test('creates multiple markers and adds to note', () {
      // Step 1: Create multiple markers from different pages
      final markers = [
        PdfMarker(
          id: 'marker-1',
          pageNumber: 1,
          color: MarkerColor.red,
          selectedText: 'Introduction to machine learning',
        ),
        PdfMarker(
          id: 'marker-2',
          pageNumber: 3,
          color: MarkerColor.yellow,
          selectedText: 'Supervised learning algorithms',
        ),
        PdfMarker(
          id: 'marker-3',
          pageNumber: 5,
          color: MarkerColor.green,
          selectedText: 'Neural network architectures',
        ),
      ];

      // Step 2: Format all markers as markdown lines
      final markerLines = markers
          .map((m) => '- ${m.color.emoji} P${m.pageNumber}  ${m.selectedText}')
          .join('\n');

      // Step 3: Create note with all markers
      final note = Note(
        id: 'note-3',        content: '# Machine Learning Course\n\n$markerLines',
        markers: [],
      );

      // Step 4: Verify all markers are in note
      expect(note.content, contains('🔴 P1'));
      expect(note.content, contains('🟡 P3'));
      expect(note.content, contains('🟢 P5'));

      // Step 5: Parse all markers from note
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 3);
      expect(parsedMarkers[0].pageNumber, 1);
      expect(parsedMarkers[1].pageNumber, 3);
      expect(parsedMarkers[2].pageNumber, 5);
    });

    test('creates marker with text and image and adds to note', () {
      // Step 1: Create marker with both text and image
      final marker = PdfMarker(
        id: 'marker-4',
        pageNumber: 7,
        color: MarkerColor.blue,
        selectedText: 'Figure 2.1: Network Architecture',
        textRect: const PdfRect(x: 100.0, y: 200.0, width: 400.0, height: 300.0),
        capturedImagePath: './captures/p7_figure_2_1.png',
      );

      // Step 2: Format marker with text and image
      final markerLines = '''- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}
  ![figure](${marker.capturedImagePath})''';

      // Step 3: Add to note
      final note = Note(
        id: 'note-4',        content: '# Important Figures\n\n$markerLines',
        markers: [],
      );

      // Step 4: Verify content
      expect(note.content, contains('🔵 P7'));
      expect(note.content, contains('Figure 2.1: Network Architecture'));
      expect(note.content, contains('![figure](./captures/p7_figure_2_1.png)'));

      // Step 5: Parse and verify
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].color, MarkerColor.blue);
      expect(parsedMarkers[0].pageNumber, 7);
      expect(parsedMarkers[0].text, 'Figure 2.1: Network Architecture');
      expect(parsedMarkers[0].imagePath, './captures/p7_figure_2_1.png');
    });

    test('creates note with frontmatter and markers', () {
      // Step 1: Create marker
      final marker = PdfMarker(
        id: 'marker-5',
        pageNumber: 10,
        color: MarkerColor.purple,
        selectedText: 'Key conclusion from the paper',
      );

      // Step 2: Format marker line
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}';

      // Step 3: Create note with frontmatter
      final frontmatter = '''---
file: research_paper.pdf
file-path: ./assets/research_paper.pdf
created: 2024-01-01
tags: [research, machine-learning]
---''';

      final note = Note(
        id: 'note-5',        content: '$frontmatter\n\n# Research Paper Notes\n\n$markerLine',
        markers: [],
      );

      // Step 4: Verify frontmatter and marker are both present
      expect(note.content, contains('---'));
      expect(note.content, contains('file: research_paper.pdf'));
      expect(note.content, contains('🟣 P10'));
      expect(note.content, contains('Key conclusion from the paper'));

      // Step 5: Parse markers (should work even with frontmatter)
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].color, MarkerColor.purple);
      expect(parsedMarkers[0].pageNumber, 10);
    });

    test('appends new marker to existing note content', () {
      // Step 1: Start with note containing existing markers
      final existingNote = Note(
        id: 'note-6',        content: '''# Notes

- 🔴 P1  First marker
- 🟡 P2  Second marker''',
        markers: [],
      );

      // Step 2: Create new marker from PDF
      final newMarker = PdfMarker(
        id: 'marker-new',
        pageNumber: 3,
        color: MarkerColor.green,
        selectedText: 'Newly selected text',
      );

      // Step 3: Format and append new marker
      final newMarkerLine = '- ${newMarker.color.emoji} P${newMarker.pageNumber}  ${newMarker.selectedText}';
      final updatedContent = '${existingNote.content}\n$newMarkerLine';

      final updatedNote = existingNote.copyWith(
        content: updatedContent,
        markers: [],
      );

      // Step 4: Verify all markers are present
      expect(updatedNote.content, contains('🔴 P1'));
      expect(updatedNote.content, contains('🟡 P2'));
      expect(updatedNote.content, contains('🟢 P3'));

      // Step 5: Parse all markers
      final parsedMarkers = MarkerParser.extractMarkers(updatedNote.content);

      expect(parsedMarkers.length, 3);
      expect(parsedMarkers[0].pageNumber, 1);
      expect(parsedMarkers[1].pageNumber, 2);
      expect(parsedMarkers[2].pageNumber, 3);
    });

    test('handles marker with special characters in selected text', () {
      // Step 1: Create marker with special characters
      final marker = PdfMarker(
        id: 'marker-special',
        pageNumber: 5,
        color: MarkerColor.red,
        selectedText: 'Text with "quotes" and (parentheses) & symbols! 한글 テスト',
      );

      // Step 2: Format marker line
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}';

      // Step 3: Add to note
      final note = Note(
        id: 'note-special',        content: markerLine,
        markers: [],
      );

      // Step 4: Parse and verify special characters are preserved
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].text, 'Text with "quotes" and (parentheses) & symbols! 한글 テスト');
    });

    test('creates marker without text (page bookmark)', () {
      // Step 1: Create marker without selected text (just a page reference)
      final marker = PdfMarker(
        id: 'bookmark-1',
        pageNumber: 15,
        color: MarkerColor.blue,
      );

      // Step 2: Format marker line without text
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}';

      // Step 3: Add to note
      final note = Note(
        id: 'note-bookmark',        content: '# Page References\n\n$markerLine',
        markers: [],
      );

      // Step 4: Verify marker line is present
      expect(note.content, contains('🔵 P15'));
      expect(note.content, isNot(contains('P15  '))); // No double space when no text

      // Step 5: Parse and verify
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].color, MarkerColor.blue);
      expect(parsedMarkers[0].pageNumber, 15);
      expect(parsedMarkers[0].text, null);
    });

    test('roundtrip: marker -> note -> parse -> reconstruct', () {
      // Step 1: Create original markers
      final originalMarkers = [
        PdfMarker(
          id: 'm1',
          pageNumber: 3,
          color: MarkerColor.red,
          selectedText: 'First important text',
          textRect: const PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0),
        ),
        PdfMarker(
          id: 'm2',
          pageNumber: 5,
          color: MarkerColor.yellow,
          capturedImagePath: './captures/p5.png',
        ),
        PdfMarker(
          id: 'm3',
          pageNumber: 7,
          color: MarkerColor.green,
          selectedText: 'Second important text',
        ),
      ];

      // Step 2: Format as markdown
      final markerLines = originalMarkers.map((m) {
        if (m.capturedImagePath != null) {
          return '- ${m.color.emoji} P${m.pageNumber}\n  ![capture](${m.capturedImagePath})';
        } else if (m.selectedText != null) {
          return '- ${m.color.emoji} P${m.pageNumber}  ${m.selectedText}';
        } else {
          return '- ${m.color.emoji} P${m.pageNumber}';
        }
      }).join('\n');

      // Step 3: Create note
      final note = Note(
        id: 'roundtrip-note',        content: '# Test\n\n$markerLines',
        markers: [],
      );

      // Step 4: Parse markers from note
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      // Step 5: Verify parsed markers match original data
      expect(parsedMarkers.length, 3);

      expect(parsedMarkers[0].color, originalMarkers[0].color);
      expect(parsedMarkers[0].pageNumber, originalMarkers[0].pageNumber);
      expect(parsedMarkers[0].text, originalMarkers[0].selectedText);

      expect(parsedMarkers[1].color, originalMarkers[1].color);
      expect(parsedMarkers[1].pageNumber, originalMarkers[1].pageNumber);
      expect(parsedMarkers[1].imagePath, originalMarkers[1].capturedImagePath);

      expect(parsedMarkers[2].color, originalMarkers[2].color);
      expect(parsedMarkers[2].pageNumber, originalMarkers[2].pageNumber);
      expect(parsedMarkers[2].text, originalMarkers[2].selectedText);
    });

    test('mixed content: markers, headings, regular text, lists', () {
      // Step 1: Create markers
      final marker1 = PdfMarker(
        id: 'm1',
        pageNumber: 2,
        color: MarkerColor.red,
        selectedText: 'Definition of supervised learning',
      );

      final marker2 = PdfMarker(
        id: 'm2',
        pageNumber: 8,
        color: MarkerColor.blue,
        selectedText: 'Neural network backpropagation',
      );

      // Step 2: Create complex note with mixed content
      final markerLine1 = '- ${marker1.color.emoji} P${marker1.pageNumber}  ${marker1.selectedText}';
      final markerLine2 = '- ${marker2.color.emoji} P${marker2.pageNumber}  ${marker2.selectedText}';

      final note = Note(
        id: 'mixed-note',        content: '''# Machine Learning Notes

## Chapter 1: Introduction

$markerLine1

Some regular text explaining the concept.

## Chapter 2: Deep Learning

- Regular list item 1
- Regular list item 2

$markerLine2

More explanatory text here.

See also: [[related-note]]
''',
        markers: [],
      );

      // Step 3: Parse markers (should only extract marker lines, not regular lists)
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 2);
      expect(parsedMarkers[0].pageNumber, 2);
      expect(parsedMarkers[1].pageNumber, 8);

      // Verify regular list items are not parsed as markers
      expect(note.content, contains('Regular list item 1'));
      expect(note.content, contains('Regular list item 2'));
    });

    test('all marker colors are supported', () {
      // Step 1: Create markers with all available colors
      final markers = [
        PdfMarker(id: 'm1', pageNumber: 1, color: MarkerColor.red, selectedText: 'Red marker'),
        PdfMarker(id: 'm2', pageNumber: 2, color: MarkerColor.yellow, selectedText: 'Yellow marker'),
        PdfMarker(id: 'm3', pageNumber: 3, color: MarkerColor.green, selectedText: 'Green marker'),
        PdfMarker(id: 'm4', pageNumber: 4, color: MarkerColor.blue, selectedText: 'Blue marker'),
        PdfMarker(id: 'm5', pageNumber: 5, color: MarkerColor.purple, selectedText: 'Purple marker'),
      ];

      // Step 2: Format all markers
      final markerLines = markers
          .map((m) => '- ${m.color.emoji} P${m.pageNumber}  ${m.selectedText}')
          .join('\n');

      // Step 3: Create note
      final note = Note(
        id: 'color-test',        content: markerLines,
        markers: [],
      );

      // Step 4: Verify all colors are in content
      expect(note.content, contains('🔴'));
      expect(note.content, contains('🟡'));
      expect(note.content, contains('🟢'));
      expect(note.content, contains('🔵'));
      expect(note.content, contains('🟣'));

      // Step 5: Parse and verify all colors
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 5);
      expect(parsedMarkers[0].color, MarkerColor.red);
      expect(parsedMarkers[1].color, MarkerColor.yellow);
      expect(parsedMarkers[2].color, MarkerColor.green);
      expect(parsedMarkers[3].color, MarkerColor.blue);
      expect(parsedMarkers[4].color, MarkerColor.purple);
    });
  });
}
