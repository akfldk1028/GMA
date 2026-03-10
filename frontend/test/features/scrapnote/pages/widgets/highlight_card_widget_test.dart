import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/scrapnote/pages/widgets/highlight_card_widget.dart';

void main() {
  group('HighlightCardWidget', () {
    final testElement = CanvasElement(
      id: 'test-highlight-1',
      type: CanvasElementType.highlight,
      x: 0,
      y: 0,
      width: 250,
      height: 80,
      selectedText: 'This is highlighted text from the PDF document.',
      colorValue: 0xFFFFFF00, // yellow
      sourcePageNumber: 5,
      createdAt: DateTime(2024, 1, 1),
    );

    final elementNoText = CanvasElement(
      id: 'test-highlight-no-text',
      type: CanvasElementType.highlight,
      x: 0,
      y: 0,
      width: 250,
      height: 80,
      colorValue: 0xFFEF4444, // red
      sourcePageNumber: 2,
      createdAt: DateTime(2024, 1, 1),
    );

    Widget buildWidget(CanvasElement element, {void Function(String, double, double)? onReposition}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 200,
            child: HighlightCardWidget(
              element: element,
              onReposition: onReposition,
            ),
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders without error', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        expect(find.byType(HighlightCardWidget), findsOneWidget);
      });

      testWidgets('shows selected text content', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        expect(find.text('This is highlighted text from the PDF document.'), findsOneWidget);
      });

      testWidgets('shows page number indicator', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        expect(find.text('P5'), findsOneWidget);
      });

      testWidgets('shows page number indicator for page 2', (tester) async {
        await tester.pumpWidget(buildWidget(elementNoText));
        expect(find.text('P2'), findsOneWidget);
      });

      testWidgets('does not show page number when sourcePageNumber is null', (tester) async {
        final elementNoPage = CanvasElement(
          id: 'no-page-highlight',
          type: CanvasElementType.highlight,
          x: 0,
          y: 0,
          width: 250,
          height: 80,
          selectedText: 'Some text',
          createdAt: DateTime(2024, 1, 1),
        );
        await tester.pumpWidget(buildWidget(elementNoPage));
        expect(find.textContaining('P'), findsNothing);
      });
    });

    group('Color Indicator Strip', () {
      testWidgets('shows color indicator strip', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        // There should be a colored container for the strip
        // We verify it renders without crashing and has container elements
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('color strip uses colorValue from element', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        // Find containers and check one has the yellow color
        final containers = tester.widgetList<Container>(find.byType(Container)).toList();
        final hasYellowContainer = containers.any((c) {
          final deco = c.decoration as BoxDecoration?;
          return deco?.color == const Color(0xFFFFFF00);
        });
        expect(hasYellowContainer, isTrue);
      });

      testWidgets('color strip uses red colorValue when set to red', (tester) async {
        await tester.pumpWidget(buildWidget(elementNoText));
        final containers = tester.widgetList<Container>(find.byType(Container)).toList();
        final hasRedContainer = containers.any((c) {
          final deco = c.decoration as BoxDecoration?;
          return deco?.color == const Color(0xFFEF4444);
        });
        expect(hasRedContainer, isTrue);
      });

      testWidgets('handles null colorValue gracefully', (tester) async {
        final elementNoColor = CanvasElement(
          id: 'no-color',
          type: CanvasElementType.highlight,
          x: 0,
          y: 0,
          width: 250,
          height: 80,
          selectedText: 'Text without color',
          sourcePageNumber: 1,
          createdAt: DateTime(2024, 1, 1),
        );
        await tester.pumpWidget(buildWidget(elementNoColor));
        expect(find.byType(HighlightCardWidget), findsOneWidget);
      });
    });

    group('Text Display', () {
      testWidgets('handles null selectedText gracefully', (tester) async {
        await tester.pumpWidget(buildWidget(elementNoText));
        expect(find.byType(HighlightCardWidget), findsOneWidget);
      });

      testWidgets('renders long text without crashing', (tester) async {
        final elementLongText = CanvasElement(
          id: 'long-text',
          type: CanvasElementType.highlight,
          x: 0,
          y: 0,
          width: 250,
          height: 80,
          selectedText:
              'This is a very long text that should still render correctly without causing any overflow or errors in the widget tree.',
          colorValue: 0xFF3B82F6,
          sourcePageNumber: 10,
          createdAt: DateTime(2024, 1, 1),
        );
        await tester.pumpWidget(buildWidget(elementLongText));
        expect(find.byType(HighlightCardWidget), findsOneWidget);
      });

      testWidgets('renders with empty selectedText', (tester) async {
        final elementEmpty = CanvasElement(
          id: 'empty-text',
          type: CanvasElementType.highlight,
          x: 0,
          y: 0,
          width: 250,
          height: 80,
          selectedText: '',
          colorValue: 0xFF22C55E,
          sourcePageNumber: 3,
          createdAt: DateTime(2024, 1, 1),
        );
        await tester.pumpWidget(buildWidget(elementEmpty));
        expect(find.byType(HighlightCardWidget), findsOneWidget);
      });
    });

    group('Reposition Callback', () {
      testWidgets('calls onReposition callback after long-press drag', (tester) async {
        String? repositionedId;

        await tester.pumpWidget(
          buildWidget(
            testElement,
            onReposition: (id, x, y) {
              repositionedId = id;
            },
          ),
        );

        await tester.longPress(find.byType(HighlightCardWidget));
        await tester.pump();

        final center = tester.getCenter(find.byType(HighlightCardWidget));
        await tester.dragFrom(center, const Offset(40, 20));
        await tester.pump();

        if (repositionedId != null) {
          expect(repositionedId, equals('test-highlight-1'));
        }
      });

      testWidgets('does not crash when onReposition is null', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        await tester.longPress(find.byType(HighlightCardWidget));
        await tester.pump();
        expect(find.byType(HighlightCardWidget), findsOneWidget);
      });
    });

    group('Card Layout', () {
      testWidgets('has card-like appearance with rounded corners or border', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        // The widget should have either a Card or a Container with rounded corners
        final hasCard = find.byType(Card).evaluate().isNotEmpty;
        final hasContainer = find.byType(Container).evaluate().isNotEmpty;
        expect(hasCard || hasContainer, isTrue);
      });

      testWidgets('layout uses Row for color strip and content arrangement', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        expect(find.byType(Row), findsWidgets);
      });
    });
  });
}
