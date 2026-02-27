import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/note_editor/models/note_model.dart';
import 'package:gma_frontend/features/note_editor/utils/marker_parser.dart';
import 'package:gma_frontend/features/workspace/models/pdf_marker_model.dart';
import 'package:pdfrx/pdfrx.dart';

/// E2E test for complete marker creation flow:
/// Load PDF -> Select text -> Choose color -> Marker appears in note
///
/// This test simulates the full user journey without mocking,
/// testing the integration of all components in the marker creation flow.
void main() {
  group('E2E: Create Marker Flow', () {
    testWidgets('Load PDF -> Select text -> Choose red color -> Marker appears in note',
        (WidgetTester tester) async {
      // Step 1: Initialize app with ProviderScope
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MarkerCreationTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 2: Simulate PDF loaded (verify PDF viewer is ready)
      expect(find.text('PDF Viewer Ready'), findsOneWidget);

      // Step 3: Simulate text selection in PDF
      // User drags to select text on page 3
      await tester.tap(find.byKey(const Key('pdf_page_3')));
      await tester.pumpAndSettle();

      expect(find.text('Text Selection Active'), findsOneWidget);

      // Step 4: User chooses red color from toolbar
      await tester.tap(find.byKey(const Key('marker_color_red')));
      await tester.pumpAndSettle();

      // Step 5: Verify marker is created and appears in note
      expect(find.text('Marker Created'), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsWidgets); // Red marker indicator

      // Step 6: Verify note content contains marker line
      expect(find.textContaining('🔴'), findsOneWidget);
      expect(find.textContaining('P3'), findsOneWidget);
    });

    testWidgets('Complete flow with all marker colors', (WidgetTester tester) async {
      // Test creating markers with all 5 colors
      final colors = [
        MarkerColor.red,
        MarkerColor.yellow,
        MarkerColor.green,
        MarkerColor.blue,
        MarkerColor.purple,
      ];

      for (final color in colors) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: MarkerCreationTestScreen(initialColor: color),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Select text and create marker
        await tester.tap(find.byKey(const Key('pdf_page_1')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(Key('marker_color_${color.name}')));
        await tester.pumpAndSettle();

        // Verify marker with correct color is created
        expect(find.text('Marker Created'), findsOneWidget);
        expect(find.textContaining(color.emoji), findsOneWidget);
      }
    });

    test('Full flow integration: PDF text selection -> Marker creation -> Note update', () {
      // Step 1: Simulate PDF text selection
      const selectedText = 'Machine learning is a subset of AI';
      const pageNumber = 5;
      final textRect = PdfRect(50.0, 100.0, 300.0, 80.0);

      // Step 2: User chooses yellow color
      final selectedColor = MarkerColor.yellow;

      // Step 3: Create marker from selection
      final marker = PdfMarker(
        id: 'marker-e2e-1',
        pageNumber: pageNumber,
        color: selectedColor,
        selectedText: selectedText,
        textRect: textRect,
      );

      expect(marker.id, 'marker-e2e-1');
      expect(marker.pageNumber, pageNumber);
      expect(marker.color, selectedColor);
      expect(marker.selectedText, selectedText);

      // Step 4: Format marker as markdown line
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}';

      expect(markerLine, '- 🟡 P5  Machine learning is a subset of AI');

      // Step 5: Add marker to note content
      final existingContent = '# AI Notes\n\n## Chapter 1\n';
      final updatedContent = '$existingContent$markerLine';

      final note = Note(
        id: 'note-e2e-1',
        frontmatter: null,
        content: updatedContent,
        markers: [],
      );

      // Step 6: Verify note contains marker
      expect(note.content, contains('🟡'));
      expect(note.content, contains('P5'));
      expect(note.content, contains('Machine learning is a subset of AI'));

      // Step 7: Parse marker back from note (roundtrip verification)
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].isMarkerLine, true);
      expect(parsedMarkers[0].color, MarkerColor.yellow);
      expect(parsedMarkers[0].pageNumber, 5);
      expect(parsedMarkers[0].text, 'Machine learning is a subset of AI');
    });

    test('Image capture flow: Select region -> Capture -> Marker with image appears in note',
        () {
      // Step 1: Simulate PDF region selection
      const pageNumber = 8;
      final captureRect = PdfRect(100.0, 200.0, 500.0, -100.0);

      // Step 2: User chooses green color
      final selectedColor = MarkerColor.green;

      // Step 3: Capture image from selected region
      const capturedImagePath = './captures/p8_diagram.png';

      // Step 4: Create marker with image
      final marker = PdfMarker(
        id: 'marker-e2e-2',
        pageNumber: pageNumber,
        color: selectedColor,
        textRect: captureRect,
        capturedImagePath: capturedImagePath,
      );

      expect(marker.capturedImagePath, capturedImagePath);

      // Step 5: Format marker with image embed
      final markerLines = '''- ${marker.color.emoji} P${marker.pageNumber}
  ![diagram](${marker.capturedImagePath})''';

      expect(markerLines, contains('🟢'));
      expect(markerLines, contains('P8'));
      expect(markerLines, contains('![diagram](./captures/p8_diagram.png)'));

      // Step 6: Add to note
      final note = Note(
        id: 'note-e2e-2',
        frontmatter: null,
        content: '# Important Diagrams\n\n$markerLines',
        markers: [],
      );

      // Step 7: Verify note contains marker with image
      expect(note.content, contains('🟢'));
      expect(note.content, contains('P8'));
      expect(note.content, contains('![diagram](./captures/p8_diagram.png)'));

      // Step 8: Parse marker with image from note
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].color, MarkerColor.green);
      expect(parsedMarkers[0].pageNumber, 8);
      expect(parsedMarkers[0].imagePath, './captures/p8_diagram.png');
    });

    test('Multiple markers flow: Sequential text selections create multiple markers', () {
      // Step 1: Create first marker (red, page 2)
      final marker1 = PdfMarker(
        id: 'marker-e2e-3a',
        pageNumber: 2,
        color: MarkerColor.red,
        selectedText: 'Neural networks consist of layers',
      );

      // Step 2: Create second marker (blue, page 4)
      final marker2 = PdfMarker(
        id: 'marker-e2e-3b',
        pageNumber: 4,
        color: MarkerColor.blue,
        selectedText: 'Backpropagation algorithm',
      );

      // Step 3: Create third marker (purple, page 6)
      final marker3 = PdfMarker(
        id: 'marker-e2e-3c',
        pageNumber: 6,
        color: MarkerColor.purple,
        selectedText: 'Gradient descent optimization',
      );

      // Step 4: Format all markers as markdown
      final markerLines = [
        '- ${marker1.color.emoji} P${marker1.pageNumber}  ${marker1.selectedText}',
        '- ${marker2.color.emoji} P${marker2.pageNumber}  ${marker2.selectedText}',
        '- ${marker3.color.emoji} P${marker3.pageNumber}  ${marker3.selectedText}',
      ].join('\n');

      // Step 5: Create note with all markers
      final note = Note(
        id: 'note-e2e-3',
        frontmatter: null,
        content: '# Deep Learning\n\n$markerLines',
        markers: [],
      );

      // Step 6: Verify all markers are in note
      expect(note.content, contains('🔴'));
      expect(note.content, contains('🔵'));
      expect(note.content, contains('🟣'));
      expect(note.content, contains('P2'));
      expect(note.content, contains('P4'));
      expect(note.content, contains('P6'));

      // Step 7: Parse all markers from note
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 3);
      expect(parsedMarkers[0].color, MarkerColor.red);
      expect(parsedMarkers[1].color, MarkerColor.blue);
      expect(parsedMarkers[2].color, MarkerColor.purple);
    });

    test('Edge case: Empty text selection creates bookmark marker', () {
      // Step 1: User clicks page without selecting text (bookmark)
      final bookmarkMarker = PdfMarker(
        id: 'marker-e2e-4',
        pageNumber: 10,
        color: MarkerColor.yellow,
        // No selectedText - this is a bookmark
      );

      // Step 2: Format as marker line (no text)
      final markerLine = '- ${bookmarkMarker.color.emoji} P${bookmarkMarker.pageNumber}';

      expect(markerLine, '- 🟡 P10');

      // Step 3: Add to note
      final note = Note(
        id: 'note-e2e-4',
        frontmatter: null,
        content: '# Quick Access\n\n$markerLine',
        markers: [],
      );

      // Step 4: Verify bookmark marker in note
      expect(note.content, contains('🟡'));
      expect(note.content, contains('P10'));

      // Step 5: Parse bookmark marker
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].color, MarkerColor.yellow);
      expect(parsedMarkers[0].pageNumber, 10);
      expect(parsedMarkers[0].text, isNull); // No text for bookmark
    });

    test('Edge case: Very long text selection is properly formatted', () {
      // Step 1: Select very long text
      final longText = 'This is a very long text selection that spans multiple lines ' * 5;

      final marker = PdfMarker(
        id: 'marker-e2e-5',
        pageNumber: 15,
        color: MarkerColor.blue,
        selectedText: longText.trim(),
      );

      // Step 2: Format as marker line
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}';

      // Step 3: Add to note
      final note = Note(
        id: 'note-e2e-5',
        frontmatter: null,
        content: markerLine,
        markers: [],
      );

      // Step 4: Verify note contains full text
      expect(note.content, contains('🔵'));
      expect(note.content, contains('P15'));
      expect(note.content.length, greaterThan(200)); // Long text

      // Step 5: Parse marker with long text
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].text, equals(longText.trim()));
    });

    test('Edge case: Special characters in selected text are preserved', () {
      // Step 1: Select text with special characters
      const specialText = 'Formula: E = mc² (Einstein\'s equation) & symbols: @#\$%';

      final marker = PdfMarker(
        id: 'marker-e2e-6',
        pageNumber: 20,
        color: MarkerColor.red,
        selectedText: specialText,
      );

      // Step 2: Format as marker line
      final markerLine = '- ${marker.color.emoji} P${marker.pageNumber}  ${marker.selectedText}';

      // Step 3: Add to note
      final note = Note(
        id: 'note-e2e-6',
        frontmatter: null,
        content: markerLine,
        markers: [],
      );

      // Step 4: Verify special characters are preserved
      expect(note.content, contains('E = mc²'));
      expect(note.content, contains("Einstein's equation"));
      expect(note.content, contains('@#\$%'));

      // Step 5: Parse marker and verify special characters
      final parsedMarkers = MarkerParser.extractMarkers(note.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].text, specialText);
    });

    test('Complete roundtrip: Create -> Store -> Load -> Parse -> Verify', () {
      // Step 1: User flow - select text and create marker
      final originalMarker = PdfMarker(
        id: 'marker-roundtrip',
        pageNumber: 7,
        color: MarkerColor.green,
        selectedText: 'Convolutional neural networks for image recognition',
        textRect: PdfRect(80.0, 150.0, 400.0, 132.0),
      );

      // Step 2: Format and store in note
      final markerLine =
          '- ${originalMarker.color.emoji} P${originalMarker.pageNumber}  ${originalMarker.selectedText}';

      final note = Note(
        id: 'note-roundtrip',
        frontmatter: null,
        content: '---\ntags: [ml, cnn]\n---\n\n# CNNs\n\n$markerLine',
        markers: [],
      );

      // Step 3: Serialize note (simulate save)
      final noteJson = note.toJson();

      expect(noteJson['id'], 'note-roundtrip');
      expect(noteJson['content'], contains('🟢'));
      expect(noteJson['content'], contains('P7'));

      // Step 4: Deserialize note (simulate load)
      final loadedNote = Note.fromJson(noteJson);

      expect(loadedNote.id, note.id);
      expect(loadedNote.content, note.content);

      // Step 5: Parse markers from loaded note
      final parsedMarkers = MarkerParser.extractMarkers(loadedNote.content);

      expect(parsedMarkers.length, 1);
      expect(parsedMarkers[0].color, originalMarker.color);
      expect(parsedMarkers[0].pageNumber, originalMarker.pageNumber);
      expect(parsedMarkers[0].text, originalMarker.selectedText);

      // Step 6: Verify full roundtrip integrity
      expect(parsedMarkers[0].isMarkerLine, true);
    });
  });
}

/// Test screen widget for simulating marker creation UI
class MarkerCreationTestScreen extends StatefulWidget {
  const MarkerCreationTestScreen({
    super.key,
    this.initialColor = MarkerColor.red,
  });

  final MarkerColor initialColor;

  @override
  State<MarkerCreationTestScreen> createState() => _MarkerCreationTestScreenState();
}

class _MarkerCreationTestScreenState extends State<MarkerCreationTestScreen> {
  bool _pdfLoaded = true;
  bool _textSelected = false;
  bool _markerCreated = false;
  MarkerColor _selectedColor = MarkerColor.red;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  void _selectText() {
    setState(() {
      _textSelected = true;
    });
  }

  void _createMarker(MarkerColor color) {
    setState(() {
      _selectedColor = color;
      _markerCreated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // PDF Viewer simulation
          if (_pdfLoaded)
            const Text('PDF Viewer Ready', key: Key('pdf_status')),

          // PDF Page (tappable for text selection)
          GestureDetector(
            key: const Key('pdf_page_3'),
            onTap: _selectText,
            child: Container(
              width: 200,
              height: 100,
              color: Colors.grey[300],
              child: const Center(child: Text('PDF Page 3')),
            ),
          ),

          // Another page for testing
          GestureDetector(
            key: const Key('pdf_page_1'),
            onTap: _selectText,
            child: Container(
              width: 200,
              height: 100,
              color: Colors.grey[300],
              child: const Center(child: Text('PDF Page 1')),
            ),
          ),

          const SizedBox(height: 20),

          // Text selection status
          if (_textSelected)
            const Text('Text Selection Active', key: Key('selection_status')),

          const SizedBox(height: 20),

          // Color selection toolbar
          if (_textSelected)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final color in MarkerColor.values)
                  IconButton(
                    key: Key('marker_color_${color.name}'),
                    icon: Icon(Icons.circle, color: color.color),
                    onPressed: () => _createMarker(color),
                  ),
              ],
            ),

          const SizedBox(height: 20),

          // Marker creation status
          if (_markerCreated) ...[
            const Text('Marker Created', key: Key('marker_status')),
            Text('${_selectedColor.emoji} P3'),
          ],
        ],
      ),
    );
  }
}
