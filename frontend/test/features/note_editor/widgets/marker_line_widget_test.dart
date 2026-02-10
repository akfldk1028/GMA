import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/note_editor/pages/widgets/marker_line_widget.dart';

void main() {
  group('MarkerLineWidget', () {
    // Helper to wrap widget with MaterialApp for testing
    Widget buildWidget(MarkerLineWidget widget) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders with red marker color', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
            ),
          ),
        );

        expect(find.text('🔴'), findsOneWidget);
        expect(find.text('P3'), findsOneWidget);
      });

      testWidgets('renders with yellow marker color', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.yellow,
              pageNumber: 5,
            ),
          ),
        );

        expect(find.text('🟡'), findsOneWidget);
        expect(find.text('P5'), findsOneWidget);
      });

      testWidgets('renders with green marker color', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.green,
              pageNumber: 7,
            ),
          ),
        );

        expect(find.text('🟢'), findsOneWidget);
        expect(find.text('P7'), findsOneWidget);
      });

      testWidgets('renders with blue marker color', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.blue,
              pageNumber: 10,
            ),
          ),
        );

        expect(find.text('🔵'), findsOneWidget);
        expect(find.text('P10'), findsOneWidget);
      });

      testWidgets('renders with purple marker color', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.purple,
              pageNumber: 15,
            ),
          ),
        );

        expect(find.text('🟣'), findsOneWidget);
        expect(find.text('P15'), findsOneWidget);
      });
    });

    group('Page Number Display', () {
      testWidgets('renders single-digit page number', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 1,
            ),
          ),
        );

        expect(find.text('P1'), findsOneWidget);
      });

      testWidgets('renders double-digit page number', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 42,
            ),
          ),
        );

        expect(find.text('P42'), findsOneWidget);
      });

      testWidgets('renders triple-digit page number', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 123,
            ),
          ),
        );

        expect(find.text('P123'), findsOneWidget);
      });

      testWidgets('renders very large page number', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 9999,
            ),
          ),
        );

        expect(find.text('P9999'), findsOneWidget);
      });
    });

    group('Text Content', () {
      testWidgets('renders without text when text is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: null,
            ),
          ),
        );

        expect(find.text('🔴'), findsOneWidget);
        expect(find.text('P3'), findsOneWidget);
        // Only emoji and page number should be present
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        expect(textWidgets.length, 2); // Emoji + page number
      });

      testWidgets('renders without text when text is empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: '',
            ),
          ),
        );

        expect(find.text('🔴'), findsOneWidget);
        expect(find.text('P3'), findsOneWidget);
        // Only emoji and page number should be present
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        expect(textWidgets.length, 2); // Emoji + page number
      });

      testWidgets('renders with short text', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: 'Short text',
            ),
          ),
        );

        expect(find.text('Short text'), findsOneWidget);
      });

      testWidgets('renders with long text', (WidgetTester tester) async {
        const longText = 'Dictionary-based sentiment analysis is a method '
            'that uses pre-defined lists of words associated with positive '
            'and negative sentiments to determine the overall sentiment of text.';

        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: longText,
            ),
          ),
        );

        expect(find.text(longText), findsOneWidget);
      });

      testWidgets('truncates very long text with ellipsis', (WidgetTester tester) async {
        const veryLongText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
            'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
            'nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in '
            'reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.';

        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: veryLongText,
            ),
          ),
        );

        // Text widget should be present with maxLines and overflow
        final textWidget = tester.widget<Text>(
          find.text(veryLongText),
        );
        expect(textWidget.maxLines, 3);
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('renders text with special characters', (WidgetTester tester) async {
        const specialText = 'Text with "quotes", <brackets>, & symbols!';

        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: specialText,
            ),
          ),
        );

        expect(find.text(specialText), findsOneWidget);
      });

      testWidgets('renders text with unicode characters', (WidgetTester tester) async {
        const unicodeText = 'Unicode: 你好, Привет, مرحبا, 🎉';

        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: unicodeText,
            ),
          ),
        );

        expect(find.text(unicodeText), findsOneWidget);
      });

      testWidgets('renders text with line breaks as single line', (WidgetTester tester) async {
        const multilineText = 'First line\nSecond line\nThird line';

        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: multilineText,
            ),
          ),
        );

        expect(find.text(multilineText), findsOneWidget);
      });
    });

    group('Image Display', () {
      testWidgets('does not render image when imagePath is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              imagePath: null,
            ),
          ),
        );

        expect(find.byType(Image), findsNothing);
        expect(find.byType(ClipRRect), findsNothing);
      });

      testWidgets('does not render image when imagePath is empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              imagePath: '',
            ),
          ),
        );

        expect(find.byType(Image), findsNothing);
        expect(find.byType(ClipRRect), findsNothing);
      });

      testWidgets('renders image widget when imagePath is provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              imagePath: './captures/p3.png',
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
        expect(find.byType(ClipRRect), findsOneWidget);
      });

      testWidgets('image has correct path', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              imagePath: './captures/p3_capture.png',
            ),
          ),
        );

        final image = tester.widget<Image>(find.byType(Image));
        final assetImage = image.image as AssetImage;
        expect(assetImage.assetName, './captures/p3_capture.png');
      });

      testWidgets('renders with both text and image', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.yellow,
              pageNumber: 5,
              text: 'Figure showing the neural network architecture',
              imagePath: './captures/p5_figure.png',
            ),
          ),
        );

        expect(find.text('🟡'), findsOneWidget);
        expect(find.text('P5'), findsOneWidget);
        expect(find.text('Figure showing the neural network architecture'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('Tap Interaction', () {
      testWidgets('calls onTap when tapped', (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          buildWidget(
            MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        expect(tapped, true);
      });

      testWidgets('does not crash when onTap is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              onTap: null,
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        // Should not crash
      });

      testWidgets('tapping text area triggers onTap', (WidgetTester tester) async {
        var tapCount = 0;

        await tester.pumpWidget(
          buildWidget(
            MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: 'Clickable text',
              onTap: () {
                tapCount++;
              },
            ),
          ),
        );

        await tester.tap(find.text('Clickable text'));
        expect(tapCount, 1);
      });

      testWidgets('tapping emoji area triggers onTap', (WidgetTester tester) async {
        var tapCount = 0;

        await tester.pumpWidget(
          buildWidget(
            MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              onTap: () {
                tapCount++;
              },
            ),
          ),
        );

        await tester.tap(find.text('🔴'));
        expect(tapCount, 1);
      });

      testWidgets('tapping page number area triggers onTap', (WidgetTester tester) async {
        var tapCount = 0;

        await tester.pumpWidget(
          buildWidget(
            MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              onTap: () {
                tapCount++;
              },
            ),
          ),
        );

        await tester.tap(find.text('P3'));
        expect(tapCount, 1);
      });

      testWidgets('multiple taps work correctly', (WidgetTester tester) async {
        var tapCount = 0;

        await tester.pumpWidget(
          buildWidget(
            MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              onTap: () {
                tapCount++;
              },
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.tap(find.byType(InkWell));
        await tester.tap(find.byType(InkWell));
        expect(tapCount, 3);
      });
    });

    group('Visual Properties', () {
      testWidgets('has InkWell for tap feedback', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
            ),
          ),
        );

        expect(find.byType(InkWell), findsOneWidget);
        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.borderRadius, BorderRadius.circular(8));
      });

      testWidgets('has correct padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
            ),
          ),
        );

        final padding = tester.widget<Padding>(
          find.descendant(
            of: find.byType(InkWell),
            matching: find.byType(Padding),
          ).first,
        );
        expect(
          padding.padding,
          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        );
      });

      testWidgets('emoji has correct font size', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
            ),
          ),
        );

        final emojiText = tester.widget<Text>(find.text('🔴'));
        expect(emojiText.style?.fontSize, 20);
      });

      testWidgets('page number badge has correct styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
            ),
          ),
        );

        // Find the Container that wraps the page number
        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('P3'),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(4));
        expect(decoration.color, MarkerColor.red.color.withValues(alpha: 0.1));
        expect(decoration.border?.top.color, MarkerColor.red.color.withValues(alpha: 0.3));
        expect(decoration.border?.top.width, 1);
      });

      testWidgets('text content has correct styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: 'Sample text',
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Sample text'));
        expect(textWidget.style?.fontSize, 14);
        expect(textWidget.style?.height, 1.5);
      });

      testWidgets('layout uses Column for vertical arrangement', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: 'Text',
              imagePath: './image.png',
            ),
          ),
        );

        final column = tester.widget<Column>(
          find.descendant(
            of: find.byType(Padding),
            matching: find.byType(Column),
          ),
        );
        expect(column.crossAxisAlignment, CrossAxisAlignment.start);
      });

      testWidgets('marker line uses Row for horizontal arrangement', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: 'Text',
            ),
          ),
        );

        final row = tester.widget<Row>(find.byType(Row));
        expect(row.crossAxisAlignment, CrossAxisAlignment.start);
      });
    });

    group('Edge Cases', () {
      testWidgets('renders with page number 0', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 0,
            ),
          ),
        );

        expect(find.text('P0'), findsOneWidget);
      });

      testWidgets('renders with negative page number', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: -1,
            ),
          ),
        );

        expect(find.text('P-1'), findsOneWidget);
      });

      testWidgets('renders with whitespace-only text', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
              text: '   ',
            ),
          ),
        );

        // Whitespace text should still render (not filtered as empty)
        expect(find.text('   '), findsOneWidget);
      });

      testWidgets('renders with all properties set', (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          buildWidget(
            MarkerLineWidget(
              color: MarkerColor.purple,
              pageNumber: 42,
              text: 'Complete marker with all properties',
              imagePath: './captures/complete.png',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        );

        expect(find.text('🟣'), findsOneWidget);
        expect(find.text('P42'), findsOneWidget);
        expect(find.text('Complete marker with all properties'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);

        await tester.tap(find.byType(InkWell));
        expect(tapped, true);
      });

      testWidgets('renders with minimal properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 1,
            ),
          ),
        );

        expect(find.text('🔴'), findsOneWidget);
        expect(find.text('P1'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
      });
    });

    group('Color Variations', () {
      testWidgets('red marker has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.red,
              pageNumber: 3,
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('P3'),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFEF4444).withValues(alpha: 0.1));
      });

      testWidgets('yellow marker has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.yellow,
              pageNumber: 3,
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('P3'),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFF59E0B).withValues(alpha: 0.1));
      });

      testWidgets('green marker has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.green,
              pageNumber: 3,
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('P3'),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF22C55E).withValues(alpha: 0.1));
      });

      testWidgets('blue marker has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.blue,
              pageNumber: 3,
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('P3'),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF3B82F6).withValues(alpha: 0.1));
      });

      testWidgets('purple marker has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            const MarkerLineWidget(
              color: MarkerColor.purple,
              pageNumber: 3,
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('P3'),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF8B5CF6).withValues(alpha: 0.1));
      });
    });
  });
}
