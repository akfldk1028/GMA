import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gma_frontend/features/scrapnote/pages/widgets/scrapnote_canvas.dart';
import 'package:gma_frontend/features/pdf_viewer/drawing/models/drawing_model.dart';

void main() {
  group('ScrapnoteCanvas widget', () {
    testWidgets('renders without error when given empty strokes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScrapnoteCanvas(
              strokes: [],
              elements: [],
              isActive: false,
              onStrokeCompleted: _noopStroke,
            ),
          ),
        ),
      );

      expect(find.byType(ScrapnoteCanvas), findsOneWidget);
    });

    testWidgets('renders with strokes without error', (tester) async {
      final stroke = DrawingStroke(
        id: 'test-stroke-1',
        pageNumber: 0,
        toolId: 'pen',
        colorValue: 0xFF000000,
        size: 3.0,
        points: const [
          StrokePoint(x: 100, y: 100, pressure: 0.5),
          StrokePoint(x: 200, y: 200, pressure: 0.5),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrapnoteCanvas(
              strokes: [stroke],
              elements: const [],
              isActive: false,
              onStrokeCompleted: _noopStroke,
            ),
          ),
        ),
      );

      expect(find.byType(ScrapnoteCanvas), findsOneWidget);
    });

    testWidgets('contains InteractiveViewer for pan/zoom scrolling',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScrapnoteCanvas(
              strokes: [],
              elements: [],
              isActive: false,
              onStrokeCompleted: _noopStroke,
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('when inactive, does not capture pointer events', (tester) async {
      bool strokeCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrapnoteCanvas(
              strokes: const [],
              elements: const [],
              isActive: false,
              onStrokeCompleted: (_) {
                strokeCompleted = true;
              },
            ),
          ),
        ),
      );

      // Tap in the canvas area — should not trigger stroke since isActive=false
      await tester.tap(find.byType(ScrapnoteCanvas));
      await tester.pump();

      expect(strokeCompleted, isFalse);
    });
  });
}

void _noopStroke(DrawingStroke stroke) {}
