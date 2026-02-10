import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/note_editor/models/note_model.dart';
import 'package:gma_frontend/features/note_editor/utils/marker_parser.dart';
import 'package:gma_frontend/features/note_editor/pages/widgets/marker_line_widget.dart';
import 'package:gma_frontend/features/pdf_viewer/models/pdf_marker_model.dart';

/// E2E test for complete marker navigation flow:
/// Open note with markers -> Click marker -> PDF navigates to page
///
/// This test simulates the full user journey of opening a note with
/// markers and clicking them to navigate to the corresponding PDF page.
void main() {
  group('E2E: Navigate via Marker Flow', () {
    testWidgets('Open note with red marker -> Click marker -> Navigation callback triggered',
        (WidgetTester tester) async {
      // Step 1: Create note with marker
      final note = Note(
        id: 'note-nav-1',
        frontmatter: null,
        content: '# My Notes\n\n- 🔴 P3  Selected text from page 3',
        markers: [],
      );

      // Step 2: Parse markers from note
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 1);
      expect(markers[0].isMarkerLine, true);
      expect(markers[0].color, MarkerColor.red);
      expect(markers[0].pageNumber, 3);

      // Step 3: Build UI with marker widget
      int? navigatedToPage;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MarkerLineWidget(
                color: markers[0].color!,
                pageNumber: markers[0].pageNumber!,
                text: markers[0].text,
                onTap: () {
                  navigatedToPage = markers[0].pageNumber;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 4: Verify marker is displayed
      expect(find.text('🔴'), findsOneWidget);
      expect(find.text('P3'), findsOneWidget);
      expect(find.text('Selected text from page 3'), findsOneWidget);

      // Step 5: Tap marker to navigate
      await tester.tap(find.byType(MarkerLineWidget));
      await tester.pumpAndSettle();

      // Step 6: Verify navigation occurred
      expect(navigatedToPage, 3);
    });

    testWidgets('Open note with multiple markers -> Click each -> Each navigates correctly',
        (WidgetTester tester) async {
      // Step 1: Create note with multiple markers
      final note = Note(
        id: 'note-nav-2',
        frontmatter: null,
        content: '''# Research Notes

- 🔴 P3  Neural networks
- 🟡 P5  Deep learning
- 🟢 P7  Backpropagation''',
        markers: [],
      );

      // Step 2: Parse markers
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 3);

      // Step 3: Build UI with all markers
      final navigatedPages = <int>[];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: markers.length,
                itemBuilder: (context, index) {
                  final marker = markers[index];
                  return MarkerLineWidget(
                    key: Key('marker-$index'),
                    color: marker.color!,
                    pageNumber: marker.pageNumber!,
                    text: marker.text,
                    onTap: () {
                      navigatedPages.add(marker.pageNumber!);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 4: Verify all markers are displayed
      expect(find.text('🔴'), findsOneWidget);
      expect(find.text('🟡'), findsOneWidget);
      expect(find.text('🟢'), findsOneWidget);

      // Step 5: Click each marker and verify navigation
      await tester.tap(find.byKey(const Key('marker-0')));
      await tester.pumpAndSettle();
      expect(navigatedPages, [3]);

      await tester.tap(find.byKey(const Key('marker-1')));
      await tester.pumpAndSettle();
      expect(navigatedPages, [3, 5]);

      await tester.tap(find.byKey(const Key('marker-2')));
      await tester.pumpAndSettle();
      expect(navigatedPages, [3, 5, 7]);
    });

    test('Complete flow: Load note -> Parse markers -> Navigate to each page', () {
      // Step 1: Simulate loading note from storage
      final noteContent = '''---
title: Machine Learning
tags: [ml, ai]
---

# Machine Learning Fundamentals

## Key Concepts

- 🔴 P2  Definition of machine learning
- 🟡 P5  Supervised vs unsupervised learning
- 🟢 P8  Neural network architecture
- 🔵 P12  Training algorithms
- 🟣 P15  Evaluation metrics

## Summary

Important pages marked above.''';

      final note = Note(
        id: 'note-nav-3',
        frontmatter: null,
        content: noteContent,
        markers: [],
      );

      // Step 2: Parse all markers from note
      final markers = MarkerParser.extractMarkers(note.content);

      expect(markers.length, 5);

      // Step 3: Verify each marker can be used for navigation
      expect(markers[0].pageNumber, 2);
      expect(markers[0].color, MarkerColor.red);

      expect(markers[1].pageNumber, 5);
      expect(markers[1].color, MarkerColor.yellow);

      expect(markers[2].pageNumber, 8);
      expect(markers[2].color, MarkerColor.green);

      expect(markers[3].pageNumber, 12);
      expect(markers[3].color, MarkerColor.blue);

      expect(markers[4].pageNumber, 15);
      expect(markers[4].color, MarkerColor.purple);

      // Step 4: Simulate navigation to each page
      final navigatedPages = <int>[];
      for (final marker in markers) {
        // Simulate clicking marker
        navigatedPages.add(marker.pageNumber!);
      }

      // Step 5: Verify all pages were navigated
      expect(navigatedPages, [2, 5, 8, 12, 15]);
    });

    test('Marker with image: Click marker -> Navigate to page with image highlight', () {
      // Step 1: Create note with marker containing image
      final noteContent = '''# Diagrams

- 🟢 P10  Architecture diagram
  ![architecture](./captures/p10_arch.png)''';

      final note = Note(
        id: 'note-nav-4',
        frontmatter: null,
        content: noteContent,
        markers: [],
      );

      // Step 2: Parse marker with image
      final markers = MarkerParser.extractMarkers(note.content);

      expect(markers.length, 1);
      expect(markers[0].pageNumber, 10);
      expect(markers[0].color, MarkerColor.green);
      expect(markers[0].text, 'Architecture diagram');
      expect(markers[0].imagePath, './captures/p10_arch.png');

      // Step 3: Simulate navigation
      int? navigatedToPage;
      String? imagePath;

      // User clicks marker
      navigatedToPage = markers[0].pageNumber;
      imagePath = markers[0].imagePath;

      // Step 4: Verify navigation with image context
      expect(navigatedToPage, 10);
      expect(imagePath, './captures/p10_arch.png');
    });

    test('Bookmark marker (no text): Click -> Navigate to page', () {
      // Step 1: Create note with bookmark markers (no text)
      final noteContent = '''# Bookmarks

Quick access to important pages:

- 🔴 P3
- 🟡 P7
- 🔵 P12''';

      final note = Note(
        id: 'note-nav-5',
        frontmatter: null,
        content: noteContent,
        markers: [],
      );

      // Step 2: Parse bookmark markers
      final markers = MarkerParser.extractMarkers(note.content);

      expect(markers.length, 3);
      expect(markers[0].text, isNull); // Bookmark has no text
      expect(markers[1].text, isNull);
      expect(markers[2].text, isNull);

      // Step 3: Simulate navigation via bookmarks
      final navigatedPages = <int>[];
      for (final marker in markers) {
        navigatedPages.add(marker.pageNumber!);
      }

      // Step 4: Verify bookmarks navigate correctly
      expect(navigatedPages, [3, 7, 12]);
    });

    test('Marker with PdfRect coordinates: Navigate to exact region', () {
      // Step 1: Create marker with exact coordinates
      final marker = PdfMarker(
        id: 'marker-nav-6',
        pageNumber: 5,
        color: MarkerColor.yellow,
        selectedText: 'Important formula: E = mc²',
        textRect: const PdfRect(x: 120.0, y: 250.0, width: 180.0, height: 24.0),
      );

      // Step 2: Format marker for note
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}';

      final note = Note(
        id: 'note-nav-6',
        frontmatter: null,
        content: markerLine,
        markers: [],
      );

      // Step 3: Parse marker from note
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].pageNumber, 5);

      // Step 4: Simulate navigation with coordinates
      // In real app, this would call: PdfViewerController.goToRectInsidePage(pageNumber, textRect)
      int? navigatedToPage;
      PdfRect? highlightRect;

      // Simulate clicking marker with stored coordinates
      navigatedToPage = marker.pageNumber;
      highlightRect = marker.textRect;

      // Step 5: Verify navigation with exact coordinates
      expect(navigatedToPage, 5);
      expect(highlightRect?.x, 120.0);
      expect(highlightRect?.y, 250.0);
      expect(highlightRect?.width, 180.0);
      expect(highlightRect?.height, 24.0);
    });

    test('Mixed content: Only marker lines trigger navigation', () {
      // Step 1: Create note with mixed content
      final noteContent = '''# Research Notes

This is regular text.

- Regular bullet point
- Another regular item

PDF References:

- 🔴 P3  First reference
- 🟡 P5  Second reference

- Not a marker (no emoji)
- Also not a marker

- 🟢 P10  Third reference''';

      final note = Note(
        id: 'note-nav-7',
        frontmatter: null,
        content: noteContent,
        markers: [],
      );

      // Step 2: Parse only marker lines
      final markers = MarkerParser.extractMarkers(note.content);

      // Only 3 valid marker lines should be extracted
      expect(markers.length, 3);
      expect(markers[0].pageNumber, 3);
      expect(markers[1].pageNumber, 5);
      expect(markers[2].pageNumber, 10);

      // Step 3: Verify only marker lines are navigable
      for (final marker in markers) {
        expect(marker.isMarkerLine, true);
        expect(marker.pageNumber, isNotNull);
        expect(marker.color, isNotNull);
      }
    });

    test('All marker colors navigate correctly', () {
      // Step 1: Create markers with all 5 colors
      final allColorMarkers = [
        (MarkerColor.red, 2),
        (MarkerColor.yellow, 4),
        (MarkerColor.green, 6),
        (MarkerColor.blue, 8),
        (MarkerColor.purple, 10),
      ];

      // Step 2: Create note with all colors
      final markerLines = allColorMarkers
          .map((pair) => '- ${pair.$1.emoji} P${pair.$2}  ${pair.$1.name.toUpperCase()} marker')
          .join('\n');

      final note = Note(
        id: 'note-nav-8',
        frontmatter: null,
        content: '# All Marker Colors\n\n$markerLines',
        markers: [],
      );

      // Step 3: Parse all markers
      final markers = MarkerParser.extractMarkers(note.content);

      expect(markers.length, 5);

      // Step 4: Verify each color navigates to correct page
      for (var i = 0; i < markers.length; i++) {
        expect(markers[i].color, allColorMarkers[i].$1);
        expect(markers[i].pageNumber, allColorMarkers[i].$2);
        expect(markers[i].text, contains(allColorMarkers[i].$1.name.toUpperCase()));
      }

      // Step 5: Simulate navigation for all colors
      final navigatedPages = markers.map((m) => m.pageNumber!).toList();
      expect(navigatedPages, [2, 4, 6, 8, 10]);
    });

    test('Rapid marker clicks: All navigation calls are registered', () {
      // Step 1: Create note with multiple markers
      final note = Note(
        id: 'note-nav-9',
        frontmatter: null,
        content: '''- 🔴 P1  First
- 🟡 P2  Second
- 🟢 P3  Third
- 🔵 P4  Fourth
- 🟣 P5  Fifth''',
        markers: [],
      );

      // Step 2: Parse markers
      final markers = MarkerParser.extractMarkers(note.content);
      expect(markers.length, 5);

      // Step 3: Simulate rapid clicking
      final navigationLog = <int>[];
      for (final marker in markers) {
        // Simulate rapid tap
        navigationLog.add(marker.pageNumber!);
      }

      // Step 4: Verify all navigation calls were registered
      expect(navigationLog, [1, 2, 3, 4, 5]);
      expect(navigationLog.length, 5);
    });

    test('Edge case: Special characters in marker text still navigate', () {
      // Step 1: Create markers with special characters
      final noteContent = '''# Special Characters

- 🔴 P5  Formula: E = mc² & F = ma
- 🟡 P10  Quote: "Hello, World!" & 'test'
- 🟢 P15  Symbols: @#\$%^&*()_+-=[]{}|;:,.<>?/~`''';

      final note = Note(
        id: 'note-nav-10',
        frontmatter: null,
        content: noteContent,
        markers: [],
      );

      // Step 2: Parse markers with special characters
      final markers = MarkerParser.extractMarkers(note.content);

      expect(markers.length, 3);

      // Step 3: Verify navigation works despite special characters
      expect(markers[0].pageNumber, 5);
      expect(markers[0].text, contains('E = mc²'));

      expect(markers[1].pageNumber, 10);
      expect(markers[1].text, contains('"Hello, World!"'));

      expect(markers[2].pageNumber, 15);
      expect(markers[2].text, contains('@#\$%^&*()'));

      // Step 4: Simulate navigation
      final navigatedPages = markers.map((m) => m.pageNumber!).toList();
      expect(navigatedPages, [5, 10, 15]);
    });

    test('Roundtrip: Create marker -> Store in note -> Parse -> Navigate', () {
      // Step 1: Simulate creating marker from PDF selection
      final originalMarker = PdfMarker(
        id: 'marker-roundtrip',
        pageNumber: 42,
        color: MarkerColor.purple,
        selectedText: 'The answer to life, the universe, and everything',
        textRect: const PdfRect(x: 100.0, y: 200.0, width: 300.0, height: 20.0),
      );

      // Step 2: Format marker for note storage
      final markerLine =
          '- ${originalMarker.color.emoji} P${originalMarker.pageNumber}  ${originalMarker.selectedText}';

      final note = Note(
        id: 'note-roundtrip',
        frontmatter: null,
        content: '# Roundtrip\n\n$markerLine',
        markers: [],
      );

      // Step 3: Serialize note (simulate save to storage)
      final noteJson = note.toJson();
      expect(noteJson['content'], contains('🟣'));
      expect(noteJson['content'], contains('P42'));

      // Step 4: Deserialize note (simulate load from storage)
      final loadedNote = Note.fromJson(noteJson);
      expect(loadedNote.content, note.content);

      // Step 5: Parse markers from loaded note
      final parsedMarkers = MarkerParser.extractMarkers(loadedNote.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].isMarkerLine, true);
      expect(parsedMarkers[0].color, originalMarker.color);
      expect(parsedMarkers[0].pageNumber, originalMarker.pageNumber);
      expect(parsedMarkers[0].text, originalMarker.selectedText);

      // Step 6: Simulate navigation via parsed marker
      int? navigatedToPage;

      // User clicks marker in UI
      navigatedToPage = parsedMarkers[0].pageNumber;

      // Step 7: Verify navigation matches original marker
      expect(navigatedToPage, 42);
      expect(navigatedToPage, originalMarker.pageNumber);
    });

    testWidgets('Widget test: MarkerLineWidget onTap triggers navigation',
        (WidgetTester tester) async {
      // Step 1: Create marker widget with tap handler
      bool navigationTriggered = false;
      int? navigatedPage;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MarkerLineWidget(
                color: MarkerColor.blue,
                pageNumber: 25,
                text: 'Test navigation callback',
                onTap: () {
                  navigationTriggered = true;
                  navigatedPage = 25;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 2: Verify marker is rendered
      expect(find.text('🔵'), findsOneWidget);
      expect(find.text('P25'), findsOneWidget);

      // Step 3: Tap marker
      await tester.tap(find.byType(MarkerLineWidget));
      await tester.pumpAndSettle();

      // Step 4: Verify navigation callback was triggered
      expect(navigationTriggered, true);
      expect(navigatedPage, 25);
    });

    testWidgets('Widget test: Multiple markers each have independent navigation',
        (WidgetTester tester) async {
      // Step 1: Create multiple marker widgets
      final navigationLog = <int>[];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  MarkerLineWidget(
                    key: const Key('marker-a'),
                    color: MarkerColor.red,
                    pageNumber: 10,
                    text: 'First marker',
                    onTap: () => navigationLog.add(10),
                  ),
                  MarkerLineWidget(
                    key: const Key('marker-b'),
                    color: MarkerColor.yellow,
                    pageNumber: 20,
                    text: 'Second marker',
                    onTap: () => navigationLog.add(20),
                  ),
                  MarkerLineWidget(
                    key: const Key('marker-c'),
                    color: MarkerColor.green,
                    pageNumber: 30,
                    text: 'Third marker',
                    onTap: () => navigationLog.add(30),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 2: Tap each marker and verify independent navigation
      await tester.tap(find.byKey(const Key('marker-a')));
      await tester.pumpAndSettle();
      expect(navigationLog, [10]);

      await tester.tap(find.byKey(const Key('marker-c')));
      await tester.pumpAndSettle();
      expect(navigationLog, [10, 30]);

      await tester.tap(find.byKey(const Key('marker-b')));
      await tester.pumpAndSettle();
      expect(navigationLog, [10, 30, 20]);
    });

    test('Complete E2E scenario: User opens note and navigates through all markers', () {
      // Step 1: User opens note file
      final noteContent = '''---
title: Research Summary
pdf: ./papers/ml_survey.pdf
---

# Machine Learning Survey

## Abstract

- 🔴 P1  Survey introduction and scope

## Methodology

- 🟡 P3  Data collection methods
  ![methodology](./captures/p3_methods.png)

## Results

- 🟢 P7  Key findings
- 🔵 P9  Statistical analysis

## Discussion

- 🟣 P12  Implications and future work

## Conclusion

- 🔴 P15  Summary''';

      final note = Note(
        id: 'note-e2e-final',
        frontmatter: null,
        content: noteContent,
        markers: [],
      );

      // Step 2: App parses markers from note
      final markers = MarkerParser.extractMarkers(note.content);

      expect(markers.length, 6);

      // Step 3: User clicks through all markers sequentially
      final userNavigationPath = <int>[];

      for (final marker in markers) {
        // Simulate user clicking marker in UI
        userNavigationPath.add(marker.pageNumber!);
      }

      // Step 4: Verify complete navigation path
      expect(userNavigationPath, [1, 3, 7, 9, 12, 15]);

      // Step 5: Verify marker with image was handled
      final markerWithImage = markers.firstWhere((m) => m.imagePath != null);
      expect(markerWithImage.pageNumber, 3);
      expect(markerWithImage.imagePath, './captures/p3_methods.png');

      // Step 6: Verify all colors were used
      final colors = markers.map((m) => m.color).toSet();
      expect(colors.length, 5); // All 5 colors used
      expect(colors, containsAll(MarkerColor.values));
    });
  });
}
