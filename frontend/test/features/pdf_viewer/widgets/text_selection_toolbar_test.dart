import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/pdf_viewer/pages/widgets/text_selection_toolbar.dart';

void main() {
  group('PdfTextSelectionToolbar', () {
    // Helper to wrap widget with MaterialApp for testing
    Widget buildWidget(PdfTextSelectionToolbar widget) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: widget,
            ),
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders all 5 marker color buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        expect(find.text('🔴'), findsOneWidget);
        expect(find.text('🟡'), findsOneWidget);
        expect(find.text('🟢'), findsOneWidget);
        expect(find.text('🔵'), findsOneWidget);
        expect(find.text('🟣'), findsOneWidget);
      });

      testWidgets('renders as Card with elevation', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 4);
      });

      testWidgets('has rounded corners', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        final card = tester.widget<Card>(find.byType(Card));
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(12));
      });

      testWidgets('color buttons are in a Row', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        // Find the Row containing the color buttons
        final row = tester.widget<Row>(
          find.descendant(
            of: find.byType(PdfTextSelectionToolbar),
            matching: find.byType(Row),
          ),
        );
        expect(row.mainAxisSize, MainAxisSize.min);
      });

      testWidgets('has correct number of color buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        // Count InkWell widgets (one per color button)
        expect(find.byType(InkWell), findsNWidgets(5));
      });
    });

    group('Text Preview Display', () {
      testWidgets('does not show text preview when selectedText is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: null,
            ),
          ),
        );

        // Should not find Divider (which only appears with text preview)
        expect(find.byType(Divider), findsNothing);

        // Only the 5 emoji should be present
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        expect(textWidgets.length, 5); // Just the 5 emoji
      });

      testWidgets('does not show text preview when selectedText is empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: '',
            ),
          ),
        );

        expect(find.byType(Divider), findsNothing);
      });

      testWidgets('shows text preview when selectedText is provided', (WidgetTester tester) async {
        const previewText = 'Selected text from PDF';

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: previewText,
            ),
          ),
        );

        expect(find.text(previewText), findsOneWidget);
        expect(find.byType(Divider), findsOneWidget);
      });

      testWidgets('text preview has correct styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: 'Sample text',
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Sample text'));
        expect(textWidget.style?.fontSize, 12);
        expect(textWidget.style?.color, Colors.black54);
        expect(textWidget.maxLines, 2);
        expect(textWidget.overflow, TextOverflow.ellipsis);
        expect(textWidget.textAlign, TextAlign.center);
      });

      testWidgets('shows short text preview completely', (WidgetTester tester) async {
        const shortText = 'Short text';

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: shortText,
            ),
          ),
        );

        expect(find.text(shortText), findsOneWidget);
      });

      testWidgets('truncates long text preview with ellipsis', (WidgetTester tester) async {
        const longText = 'This is a very long text that should be truncated '
            'with an ellipsis because it exceeds the maximum number of lines '
            'allowed in the text preview area of the toolbar widget.';

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: longText,
            ),
          ),
        );

        expect(find.text(longText), findsOneWidget);

        final textWidget = tester.widget<Text>(find.text(longText));
        expect(textWidget.maxLines, 2);
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('handles text with special characters', (WidgetTester tester) async {
        const specialText = 'Text with "quotes" & <brackets>';

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: specialText,
            ),
          ),
        );

        expect(find.text(specialText), findsOneWidget);
      });

      testWidgets('handles text with unicode characters', (WidgetTester tester) async {
        const unicodeText = '你好世界 Привет мир مرحبا 🌍';

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: unicodeText,
            ),
          ),
        );

        expect(find.text(unicodeText), findsOneWidget);
      });

      testWidgets('handles whitespace-only text', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: '   ',
            ),
          ),
        );

        expect(find.text('   '), findsOneWidget);
      });
    });

    group('Color Button Interaction', () {
      testWidgets('calls onColorSelected with red when red button is tapped', (WidgetTester tester) async {
        MarkerColor? selectedColor;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColor = color;
              },
            ),
          ),
        );

        await tester.tap(find.text('🔴'));
        expect(selectedColor, MarkerColor.red);
      });

      testWidgets('calls onColorSelected with yellow when yellow button is tapped', (WidgetTester tester) async {
        MarkerColor? selectedColor;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColor = color;
              },
            ),
          ),
        );

        await tester.tap(find.text('🟡'));
        expect(selectedColor, MarkerColor.yellow);
      });

      testWidgets('calls onColorSelected with green when green button is tapped', (WidgetTester tester) async {
        MarkerColor? selectedColor;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColor = color;
              },
            ),
          ),
        );

        await tester.tap(find.text('🟢'));
        expect(selectedColor, MarkerColor.green);
      });

      testWidgets('calls onColorSelected with blue when blue button is tapped', (WidgetTester tester) async {
        MarkerColor? selectedColor;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColor = color;
              },
            ),
          ),
        );

        await tester.tap(find.text('🔵'));
        expect(selectedColor, MarkerColor.blue);
      });

      testWidgets('calls onColorSelected with purple when purple button is tapped', (WidgetTester tester) async {
        MarkerColor? selectedColor;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColor = color;
              },
            ),
          ),
        );

        await tester.tap(find.text('🟣'));
        expect(selectedColor, MarkerColor.purple);
      });

      testWidgets('multiple taps work correctly', (WidgetTester tester) async {
        final selectedColors = <MarkerColor>[];

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColors.add(color);
              },
            ),
          ),
        );

        await tester.tap(find.text('🔴'));
        await tester.tap(find.text('🟡'));
        await tester.tap(find.text('🔵'));

        expect(selectedColors, [
          MarkerColor.red,
          MarkerColor.yellow,
          MarkerColor.blue,
        ]);
      });

      testWidgets('tapping same color multiple times works', (WidgetTester tester) async {
        var tapCount = 0;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                if (color == MarkerColor.red) {
                  tapCount++;
                }
              },
            ),
          ),
        );

        await tester.tap(find.text('🔴'));
        await tester.tap(find.text('🔴'));
        await tester.tap(find.text('🔴'));

        expect(tapCount, 3);
      });
    });

    group('Visual Properties', () {
      testWidgets('color buttons have InkWell for tap feedback', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        expect(find.byType(InkWell), findsNWidgets(5));
      });

      testWidgets('color buttons have correct size', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(InkWell),
            matching: find.byType(Container),
          ),
        );

        for (final container in containers) {
          // Each button should be 44x44
          expect(container.constraints?.minWidth, 44);
          expect(container.constraints?.minHeight, 44);
        }
      });

      testWidgets('red button has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('🔴'),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFEF4444).withOpacity(0.1));
        expect(decoration.border?.top.color, const Color(0xFFEF4444).withOpacity(0.3));
        expect(decoration.border?.top.width, 2);
        expect(decoration.borderRadius, BorderRadius.circular(8));
      });

      testWidgets('yellow button has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('🟡'),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFF59E0B).withOpacity(0.1));
        expect(decoration.border?.top.color, const Color(0xFFF59E0B).withOpacity(0.3));
      });

      testWidgets('green button has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('🟢'),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF22C55E).withOpacity(0.1));
        expect(decoration.border?.top.color, const Color(0xFF22C55E).withOpacity(0.3));
      });

      testWidgets('blue button has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('🔵'),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF3B82F6).withOpacity(0.1));
        expect(decoration.border?.top.color, const Color(0xFF3B82F6).withOpacity(0.3));
      });

      testWidgets('purple button has correct color properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('🟣'),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF8B5CF6).withOpacity(0.1));
        expect(decoration.border?.top.color, const Color(0xFF8B5CF6).withOpacity(0.3));
      });

      testWidgets('emoji has correct font size', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        final emojiText = tester.widget<Text>(find.text('🔴'));
        expect(emojiText.style?.fontSize, 24);
      });

      testWidgets('toolbar has correct padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        // Find the main padding inside Card
        final paddings = tester.widgetList<Padding>(
          find.descendant(
            of: find.byType(Card),
            matching: find.byType(Padding),
          ),
        );

        // The first padding (outer padding in Card) should be (12, 8)
        bool foundCorrectPadding = false;
        for (final padding in paddings) {
          if (padding.padding == const EdgeInsets.symmetric(horizontal: 12, vertical: 8)) {
            foundCorrectPadding = true;
            break;
          }
        }

        expect(foundCorrectPadding, true,
            reason: 'Expected to find padding with EdgeInsets.symmetric(horizontal: 12, vertical: 8)');
      });

      testWidgets('color buttons have horizontal spacing', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        // Find padding around InkWell buttons (parent padding of InkWell)
        final paddings = tester.widgetList<Padding>(
          find.descendant(
            of: find.byType(Row),
            matching: find.byType(Padding),
          ),
        );

        // Count paddings with horizontal: 4
        int correctPaddingCount = 0;
        for (final padding in paddings) {
          if (padding.padding == const EdgeInsets.symmetric(horizontal: 4)) {
            correctPaddingCount++;
          }
        }

        // Should have 5 buttons, each wrapped in padding with horizontal: 4
        expect(correctPaddingCount, 5,
            reason: 'Expected 5 color buttons with horizontal padding of 4');
      });
    });

    group('Layout Structure', () {
      testWidgets('uses Column for vertical arrangement', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: 'Sample text',
            ),
          ),
        );

        final column = tester.widget<Column>(
          find.descendant(
            of: find.byType(Padding),
            matching: find.byType(Column),
          ),
        );
        expect(column.mainAxisSize, MainAxisSize.min);
      });

      testWidgets('text preview appears above color buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: 'Sample text',
            ),
          ),
        );

        final column = tester.widget<Column>(
          find.descendant(
            of: find.byType(Card),
            matching: find.byType(Column),
          ),
        );

        // First child should contain the text, last child should be the Row with buttons
        expect(column.children.length, greaterThan(1));
      });

      testWidgets('divider separates text preview from buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: 'Sample text',
            ),
          ),
        );

        expect(find.byType(Divider), findsOneWidget);

        final divider = tester.widget<Divider>(find.byType(Divider));
        expect(divider.height, 1);
      });
    });

    group('Edge Cases', () {
      testWidgets('renders without crashing when no text preview', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        expect(find.byType(PdfTextSelectionToolbar), findsOneWidget);
      });

      testWidgets('renders correctly with text preview', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: 'Sample text',
            ),
          ),
        );

        expect(find.byType(PdfTextSelectionToolbar), findsOneWidget);
        expect(find.text('Sample text'), findsOneWidget);
      });

      testWidgets('handles very long single word', (WidgetTester tester) async {
        final longWord = 'Supercalifragilisticexpialidocious' * 10;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: longWord,
            ),
          ),
        );

        expect(find.text(longWord), findsOneWidget);
      });

      testWidgets('handles newlines in text preview', (WidgetTester tester) async {
        const multilineText = 'Line 1\nLine 2\nLine 3';

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: multilineText,
            ),
          ),
        );

        expect(find.text(multilineText), findsOneWidget);
      });

      testWidgets('all buttons remain accessible when text preview is shown', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
              selectedText: 'Long text that might affect layout',
            ),
          ),
        );

        // All 5 colors should still be accessible
        expect(find.text('🔴'), findsOneWidget);
        expect(find.text('🟡'), findsOneWidget);
        expect(find.text('🟢'), findsOneWidget);
        expect(find.text('🔵'), findsOneWidget);
        expect(find.text('🟣'), findsOneWidget);
      });

      testWidgets('callback works with text preview', (WidgetTester tester) async {
        MarkerColor? selectedColor;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColor = color;
              },
              selectedText: 'Sample text',
            ),
          ),
        );

        await tester.tap(find.text('🔴'));
        expect(selectedColor, MarkerColor.red);
      });
    });

    group('Complete Scenarios', () {
      testWidgets('complete toolbar without text preview', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (_) {},
            ),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(InkWell), findsNWidgets(5));
        expect(find.byType(Divider), findsNothing);
      });

      testWidgets('complete toolbar with text preview', (WidgetTester tester) async {
        MarkerColor? selectedColor;

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColor = color;
              },
              selectedText: 'Selected PDF text',
            ),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.text('Selected PDF text'), findsOneWidget);
        expect(find.byType(Divider), findsOneWidget);
        expect(find.byType(InkWell), findsNWidgets(5));

        await tester.tap(find.text('🟢'));
        expect(selectedColor, MarkerColor.green);
      });

      testWidgets('sequential color selection', (WidgetTester tester) async {
        final selectedColors = <MarkerColor>[];

        await tester.pumpWidget(
          buildWidget(
            PdfTextSelectionToolbar(
              onColorSelected: (color) {
                selectedColors.add(color);
              },
              selectedText: 'Test selection',
            ),
          ),
        );

        // Tap all colors in order
        await tester.tap(find.text('🔴'));
        await tester.tap(find.text('🟡'));
        await tester.tap(find.text('🟢'));
        await tester.tap(find.text('🔵'));
        await tester.tap(find.text('🟣'));

        expect(selectedColors, [
          MarkerColor.red,
          MarkerColor.yellow,
          MarkerColor.green,
          MarkerColor.blue,
          MarkerColor.purple,
        ]);
      });
    });
  });
}
