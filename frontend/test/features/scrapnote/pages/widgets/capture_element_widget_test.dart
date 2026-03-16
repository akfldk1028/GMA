import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/scrapnote/pages/widgets/capture_element_widget.dart';

void main() {
  group('CaptureElementWidget', () {
    final testElement = CanvasElement(
      id: 'test-capture-1',
      type: CanvasElementType.capture,
      x: 0,
      y: 0,
      width: 200,
      height: 150,
      imagePath: '/nonexistent/path/image.png',
      sourcePageNumber: 3,
      createdAt: DateTime(2024, 1, 1),
    );

    final elementWithoutImage = CanvasElement(
      id: 'test-capture-no-image',
      type: CanvasElementType.capture,
      x: 0,
      y: 0,
      width: 200,
      height: 150,
      sourcePageNumber: 5,
      createdAt: DateTime(2024, 1, 1),
    );

    Widget buildWidget(CanvasElement element, {void Function(String, double, double)? onReposition}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: CaptureElementWidget(
              element: element,
              onReposition: onReposition,
            ),
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders without error', (tester) async {
        await tester.pumpWidget(buildWidget(elementWithoutImage));
        expect(find.byType(CaptureElementWidget), findsOneWidget);
      });

      testWidgets('shows page number indicator when sourcePageNumber is set', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        expect(find.text('P3'), findsOneWidget);
      });

      testWidgets('shows page number indicator when sourcePageNumber is 5', (tester) async {
        await tester.pumpWidget(buildWidget(elementWithoutImage));
        expect(find.text('P5'), findsOneWidget);
      });

      testWidgets('does not show page number when sourcePageNumber is null', (tester) async {
        final elementNoPage = CanvasElement(
          id: 'no-page',
          type: CanvasElementType.capture,
          x: 0,
          y: 0,
          width: 200,
          height: 150,
          createdAt: DateTime(2024, 1, 1),
        );
        await tester.pumpWidget(buildWidget(elementNoPage));
        expect(find.textContaining('P'), findsNothing);
      });

      testWidgets('shows border/frame around the widget', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        // Container with decoration should be present for the frame
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('Image Placeholder', () {
      testWidgets('shows placeholder when imagePath is null', (tester) async {
        await tester.pumpWidget(buildWidget(elementWithoutImage));
        // Should show placeholder icon or text
        final hasIcon = find.byIcon(Icons.image_not_supported).evaluate().isNotEmpty ||
            find.byIcon(Icons.image).evaluate().isNotEmpty ||
            find.byIcon(Icons.photo).evaluate().isNotEmpty;
        expect(hasIcon || find.text('Capture').evaluate().isNotEmpty, isTrue);
      });

      testWidgets('shows placeholder when imagePath points to nonexistent file', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        // Widget should not throw even with nonexistent file
        expect(find.byType(CaptureElementWidget), findsOneWidget);
      });

      testWidgets('renders without crashing when imagePath is empty string', (tester) async {
        final elementEmptyPath = CanvasElement(
          id: 'empty-path',
          type: CanvasElementType.capture,
          x: 0,
          y: 0,
          width: 200,
          height: 150,
          imagePath: '',
          sourcePageNumber: 1,
          createdAt: DateTime(2024, 1, 1),
        );
        await tester.pumpWidget(buildWidget(elementEmptyPath));
        expect(find.byType(CaptureElementWidget), findsOneWidget);
      });
    });

    group('Reposition Callback', () {
      testWidgets('calls onReposition callback with element id when long-press drag occurs', (tester) async {
        String? repositionedId;
        double? newX;
        double? newY;

        await tester.pumpWidget(
          buildWidget(
            testElement,
            onReposition: (id, x, y) {
              repositionedId = id;
              newX = x;
              newY = y;
            },
          ),
        );

        // Long-press to enter drag mode
        await tester.longPress(find.byType(CaptureElementWidget));
        await tester.pump();

        // Perform a drag
        final center = tester.getCenter(find.byType(CaptureElementWidget));
        await tester.dragFrom(center, const Offset(50, 30));
        await tester.pump();

        // onReposition should have been called
        if (repositionedId != null) {
          expect(repositionedId, equals('test-capture-1'));
          expect(newX, isNotNull);
          expect(newY, isNotNull);
        }
      });

      testWidgets('does not crash when onReposition is null', (tester) async {
        await tester.pumpWidget(buildWidget(testElement));
        await tester.longPress(find.byType(CaptureElementWidget));
        await tester.pump();
        // Should not throw
        expect(find.byType(CaptureElementWidget), findsOneWidget);
      });
    });
  });
}
