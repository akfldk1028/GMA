import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/note_editor/models/note_model.dart';
import 'package:gma_frontend/features/note_editor/pages/widgets/marker_line_widget.dart';
import 'package:gma_frontend/features/note_editor/utils/marker_parser.dart';
import 'package:gma_frontend/features/workspace/models/pdf_marker_model.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  group('Note to PDF Navigation Flow', () {
    // Helper to wrap widget with MaterialApp for testing
    Widget buildWidget(Widget widget) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );
    }

    test('parses marker from note and extracts navigation data', () {
      // Step 1: Create note with marker
      final note = Note(
        id: 'note-1',        content: '# Machine Learning\n\n- 🔴 P3  Dictionary-based sentiment analysis is...',
        markers: [],
      );

      // Step 2: Parse markers from note
      final markers = MarkerParser.extractMarkers(note.content);

      // Step 3: Verify marker data is extracted correctly
      expect(markers.length, 1);
      expect(markers[0].color, MarkerColor.red);
      expect(markers[0].pageNumber, 3);
      expect(markers[0].text, 'Dictionary-based sentiment analysis is...');

      // Step 4: Verify navigation parameters can be extracted
      final navigationPageNumber = markers[0].pageNumber;
      expect(navigationPageNumber, 3);
    });

    testWidgets('tapping marker widget triggers navigation callback', (WidgetTester tester) async {
      // Step 1: Setup navigation tracking
      int? navigatedToPage;

      // Step 2: Create marker widget with navigation callback
      await tester.pumpWidget(
        buildWidget(
          MarkerLineWidget(
            color: MarkerColor.red,
            pageNumber: 3,
            text: 'Important text from PDF',
            onTap: () {
              navigatedToPage = 3;
            },
          ),
        ),
      );

      // Step 3: Tap the marker widget
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Step 4: Verify navigation was triggered
      expect(navigatedToPage, 3);
    });

    testWidgets('clicking marker line navigates to correct PDF page', (WidgetTester tester) async {
      // Step 1: Create note with multiple markers
      final note = Note(
        id: 'note-multi',        content: '''# Notes

- 🔴 P1  Introduction
- 🟡 P5  Methods
- 🟢 P10  Results''',
        markers: [],
      );

      // Step 2: Parse markers
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 3);

      // Step 3: Build marker widgets with navigation
      final navigatedPages = <int>[];

      await tester.pumpWidget(
        buildWidget(
          Column(
            children: markers.map((marker) {
              return MarkerLineWidget(
                color: marker.color!,
                pageNumber: marker.pageNumber!,
                text: marker.text,
                onTap: () {
                  navigatedPages.add(marker.pageNumber!);
                },
              );
            }).toList(),
          ),
        ),
      );

      // Step 4: Tap second marker (P5)
      await tester.tap(find.text('P5'));
      await tester.pumpAndSettle();

      // Step 5: Verify correct page was targeted
      expect(navigatedPages.length, 1);
      expect(navigatedPages[0], 5);

      // Step 6: Tap first marker (P1)
      await tester.tap(find.text('P1'));
      await tester.pumpAndSettle();

      expect(navigatedPages.length, 2);
      expect(navigatedPages[1], 1);

      // Step 7: Tap third marker (P10)
      await tester.tap(find.text('P10'));
      await tester.pumpAndSettle();

      expect(navigatedPages.length, 3);
      expect(navigatedPages[2], 10);
    });

    testWidgets('marker with image navigates to PDF page', (WidgetTester tester) async {
      // Step 1: Create note with marker containing image
      final note = Note(
        id: 'note-image',        content: '''# Figures

- 🟡 P5
  ![capture](./captures/p5_capture.png)''',
        markers: [],
      );

      // Step 2: Parse marker with image
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 1);
      expect(markers[0].pageNumber, 5);
      expect(markers[0].imagePath, './captures/p5_capture.png');

      // Step 3: Build marker widget
      int? navigatedPage;

      await tester.pumpWidget(
        buildWidget(
          MarkerLineWidget(
            color: markers[0].color!,
            pageNumber: markers[0].pageNumber!,
            imagePath: markers[0].imagePath,
            onTap: () {
              navigatedPage = markers[0].pageNumber;
            },
          ),
        ),
      );

      // Step 4: Tap marker (should work even with image)
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Step 5: Verify navigation
      expect(navigatedPage, 5);
    });

    testWidgets('marker with text and image navigates correctly', (WidgetTester tester) async {
      // Step 1: Create note with marker having both text and image
      final note = Note(
        id: 'note-text-image',        content: '''# Notes

- 🔵 P7  Figure 2.1: Network Architecture
  ![figure](./captures/p7_figure.png)''',
        markers: [],
      );

      // Step 2: Parse marker
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 1);
      expect(markers[0].text, 'Figure 2.1: Network Architecture');
      expect(markers[0].imagePath, './captures/p7_figure.png');

      // Step 3: Build marker widget
      int? navigatedPage;

      await tester.pumpWidget(
        buildWidget(
          MarkerLineWidget(
            color: markers[0].color!,
            pageNumber: markers[0].pageNumber!,
            text: markers[0].text,
            imagePath: markers[0].imagePath,
            onTap: () {
              navigatedPage = markers[0].pageNumber;
            },
          ),
        ),
      );

      // Step 4: Tap on text part
      await tester.tap(find.text('Figure 2.1: Network Architecture'));
      await tester.pumpAndSettle();

      // Step 5: Verify navigation
      expect(navigatedPage, 7);
    });

    testWidgets('tapping emoji navigates to PDF page', (WidgetTester tester) async {
      // Step 1: Setup marker and navigation
      int? navigatedPage;

      await tester.pumpWidget(
        buildWidget(
          MarkerLineWidget(
            color: MarkerColor.red,
            pageNumber: 3,
            text: 'Sample text',
            onTap: () {
              navigatedPage = 3;
            },
          ),
        ),
      );

      // Step 2: Tap the emoji
      await tester.tap(find.text('🔴'));
      await tester.pumpAndSettle();

      // Step 3: Verify navigation
      expect(navigatedPage, 3);
    });

    testWidgets('tapping page number badge navigates to PDF page', (WidgetTester tester) async {
      // Step 1: Setup marker and navigation
      int? navigatedPage;

      await tester.pumpWidget(
        buildWidget(
          MarkerLineWidget(
            color: MarkerColor.blue,
            pageNumber: 15,
            onTap: () {
              navigatedPage = 15;
            },
          ),
        ),
      );

      // Step 2: Tap the page number badge
      await tester.tap(find.text('P15'));
      await tester.pumpAndSettle();

      // Step 3: Verify navigation
      expect(navigatedPage, 15);
    });

    test('navigation flow with PdfRect coordinates', () {
      // Step 1: Create PdfMarker with coordinates (simulating stored marker data)
      final marker = PdfMarker(
        id: 'marker-1',
        pageNumber: 3,
        color: MarkerColor.red,
        selectedText: 'Important text',
        textRect: PdfRect(72.0, 144.0, 372.0, 120.0),
      );

      // Step 2: Format marker as markdown
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}';

      // Step 3: Add to note
      final note = Note(
        id: 'note-rect',        content: '# Notes\n\n$markerLine',
        markers: [],
      );

      // Step 4: Parse marker from note
      final parsedMarkers = MarkerParser.extractMarkers(note.content);
      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].pageNumber, 3);

      // Step 5: Verify navigation target
      // In actual implementation, PdfViewerController.goToRectInsidePage would be called
      final targetPage = parsedMarkers[0].pageNumber;
      expect(targetPage, 3);

      // Note: PdfRect coordinates would be retrieved from a marker store/provider
      // when navigation is triggered, since they're not stored in markdown
    });

    testWidgets('multiple rapid taps navigate correctly', (WidgetTester tester) async {
      // Step 1: Setup tracking
      final navigationHistory = <int>[];

      await tester.pumpWidget(
        buildWidget(
          MarkerLineWidget(
            color: MarkerColor.green,
            pageNumber: 8,
            text: 'Test marker',
            onTap: () {
              navigationHistory.add(8);
            },
          ),
        ),
      );

      // Step 2: Perform rapid taps
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Step 3: Verify all taps were registered
      expect(navigationHistory.length, 3);
      expect(navigationHistory, [8, 8, 8]);
    });

    testWidgets('marker without text navigates correctly', (WidgetTester tester) async {
      // Step 1: Create note with text-less marker (bookmark)
      final note = Note(
        id: 'bookmark-note',        content: '''# Page References

- 🔵 P15
- 🟡 P20''',
        markers: [],
      );

      // Step 2: Parse markers
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 2);
      expect(markers[0].text, null);
      expect(markers[1].text, null);

      // Step 3: Build marker widgets
      final navigationHistory = <int>[];

      await tester.pumpWidget(
        buildWidget(
          Column(
            children: markers.map((marker) {
              return MarkerLineWidget(
                color: marker.color!,
                pageNumber: marker.pageNumber!,
                onTap: () {
                  navigationHistory.add(marker.pageNumber!);
                },
              );
            }).toList(),
          ),
        ),
      );

      // Step 4: Tap first bookmark
      await tester.tap(find.text('P15'));
      await tester.pumpAndSettle();

      expect(navigationHistory, [15]);

      // Step 5: Tap second bookmark
      await tester.tap(find.text('P20'));
      await tester.pumpAndSettle();

      expect(navigationHistory, [15, 20]);
    });

    test('note with frontmatter parses markers correctly for navigation', () {
      // Step 1: Create note with frontmatter and markers
      final note = Note(
        id: 'frontmatter-note',        content: '''---
file: research_paper.pdf
file-path: ./assets/research_paper.pdf
created: 2024-01-01
tags: [research, machine-learning]
---

# Research Paper Notes

- 🟣 P10  Key conclusion from the paper
- 🔴 P5  Important methodology''',
        markers: [],
      );

      // Step 2: Parse markers (should ignore frontmatter)
      final markers = MarkerParser.extractMarkers(note.content);

      // Step 3: Verify markers are correctly extracted
      expect(markers.length, 2);
      expect(markers[0].pageNumber, 10);
      expect(markers[0].color, MarkerColor.purple);
      expect(markers[1].pageNumber, 5);
      expect(markers[1].color, MarkerColor.red);
    });

    testWidgets('mixed content: only markers trigger navigation', (WidgetTester tester) async {
      // Step 1: Create note with mixed content
      final note = Note(
        id: 'mixed-note',        content: '''# Notes

## Chapter 1

- 🔴 P2  Definition of supervised learning

Some explanatory text.

## Chapter 2

- Regular list item 1
- Regular list item 2

- 🔵 P8  Neural network backpropagation

More text here.
''',
        markers: [],
      );

      // Step 2: Parse markers (should only get marker lines, not regular list items)
      final markers = MarkerParser.extractMarkers(note.content);

      // Step 3: Verify only marker lines are extracted
      expect(markers.length, 2);
      expect(markers[0].pageNumber, 2);
      expect(markers[1].pageNumber, 8);

      // Regular list items should not be included
      expect(markers.any((m) => m.text?.contains('Regular list item') ?? false), false);
    });

    testWidgets('all marker colors navigate correctly', (WidgetTester tester) async {
      // Step 1: Create markers with all colors
      final note = Note(
        id: 'all-colors',        content: '''# Color Test

- 🔴 P1  Red marker
- 🟡 P2  Yellow marker
- 🟢 P3  Green marker
- 🔵 P4  Blue marker
- 🟣 P5  Purple marker''',
        markers: [],
      );

      // Step 2: Parse all markers
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 5);

      // Step 3: Build all marker widgets
      final navigationHistory = <Map<String, dynamic>>[];

      await tester.pumpWidget(
        buildWidget(
          Column(
            children: markers.map((marker) {
              return MarkerLineWidget(
                color: marker.color!,
                pageNumber: marker.pageNumber!,
                text: marker.text,
                onTap: () {
                  navigationHistory.add({
                    'page': marker.pageNumber,
                    'color': marker.color,
                  });
                },
              );
            }).toList(),
          ),
        ),
      );

      // Step 4: Tap each marker
      await tester.tap(find.text('🔴'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🟡'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🟢'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🔵'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🟣'));
      await tester.pumpAndSettle();

      // Step 5: Verify all navigations
      expect(navigationHistory.length, 5);
      expect(navigationHistory[0]['page'], 1);
      expect(navigationHistory[0]['color'], MarkerColor.red);
      expect(navigationHistory[1]['page'], 2);
      expect(navigationHistory[1]['color'], MarkerColor.yellow);
      expect(navigationHistory[2]['page'], 3);
      expect(navigationHistory[2]['color'], MarkerColor.green);
      expect(navigationHistory[3]['page'], 4);
      expect(navigationHistory[3]['color'], MarkerColor.blue);
      expect(navigationHistory[4]['page'], 5);
      expect(navigationHistory[4]['color'], MarkerColor.purple);
    });

    test('roundtrip: create marker -> store in note -> parse -> navigate', () {
      // Step 1: Create original PdfMarker from PDF interaction
      final originalMarker = PdfMarker(
        id: 'marker-rt',
        pageNumber: 42,
        color: MarkerColor.yellow,
        selectedText: 'Critical finding from the research',
        textRect: PdfRect(100.0, 200.0, 500.0, 150.0),
      );

      // Step 2: Format and store in note
      final markerLine = '- ${originalMarker.color.emoji} P${originalMarker.pageNumber}  ${originalMarker.selectedText}';
      final note = Note(
        id: 'roundtrip',        content: '# Test\n\n$markerLine',
        markers: [],
      );

      // Step 3: Parse marker from note for navigation
      final parsedMarkers = MarkerParser.extractMarkers(note.content);
      expect(parsedMarkers.length, 1);

      // Step 4: Verify parsed data matches original for navigation
      expect(parsedMarkers[0].pageNumber, originalMarker.pageNumber);
      expect(parsedMarkers[0].color, originalMarker.color);
      expect(parsedMarkers[0].text, originalMarker.selectedText);

      // Step 5: Extract navigation target
      final navigationTarget = parsedMarkers[0].pageNumber;
      expect(navigationTarget, 42);
    });

    testWidgets('special characters in marker text do not break navigation', (WidgetTester tester) async {
      // Step 1: Create note with special characters
      final note = Note(
        id: 'special-chars',        content: '''# Notes

- 🔴 P5  Text with "quotes" and (parentheses) & symbols! 한글 テスト''',
        markers: [],
      );

      // Step 2: Parse marker
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 1);

      // Step 3: Build widget
      int? navigatedPage;

      await tester.pumpWidget(
        buildWidget(
          MarkerLineWidget(
            color: markers[0].color!,
            pageNumber: markers[0].pageNumber!,
            text: markers[0].text,
            onTap: () {
              navigatedPage = markers[0].pageNumber;
            },
          ),
        ),
      );

      // Step 4: Tap marker
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Step 5: Verify navigation works despite special characters
      expect(navigatedPage, 5);
    });
  });
}
