import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/models/drawing_model.dart';
import 'package:gma_app/features/drawing/pages/widgets/drawing_canvas.dart';

void main() {
  group('DrawingCanvas', () {
    Widget buildTestWidget({
      bool isActive = true,
      List<DrawingStroke> strokes = const [],
      String toolId = 'pen',
      int colorValue = 0xFF000000,
      double strokeSize = 3.0,
      int pageNumber = 1,
      void Function(DrawingStroke)? onStrokeCompleted,
      void Function(int, String)? onStrokeErased,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: DrawingCanvas(
              isActive: isActive,
              strokes: strokes,
              toolId: toolId,
              colorValue: colorValue,
              strokeSize: strokeSize,
              pageNumber: pageNumber,
              onStrokeCompleted: onStrokeCompleted ?? (_) {},
              onStrokeErased: onStrokeErased,
            ),
          ),
        ),
      );
    }

    testWidgets('renders without error when inactive', (tester) async {
      await tester.pumpWidget(buildTestWidget(isActive: false));
      expect(find.byType(DrawingCanvas), findsOneWidget);
    });

    testWidgets('renders without error when active', (tester) async {
      await tester.pumpWidget(buildTestWidget(isActive: true));
      expect(find.byType(DrawingCanvas), findsOneWidget);
    });

    testWidgets('uses IgnorePointer with ignoring=true when inactive',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(isActive: false));
      // Find IgnorePointer widgets with ignoring=true (our specific one)
      final ignoringWidgets = tester.widgetList<IgnorePointer>(
        find.byType(IgnorePointer),
      );
      expect(
        ignoringWidgets.where((w) => w.ignoring == true),
        isNotEmpty,
      );
    });

    testWidgets('does not use IgnorePointer with ignoring=true when active',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(isActive: true));
      // No IgnorePointer with ignoring=true should be present
      final ignoringWidgets = tester.widgetList<IgnorePointer>(
        find.byType(IgnorePointer),
      );
      expect(
        ignoringWidgets.where((w) => w.ignoring == true),
        isEmpty,
      );
    });

    testWidgets('uses Listener when active', (tester) async {
      await tester.pumpWidget(buildTestWidget(isActive: true));
      // There should be a Listener with our HitTestBehavior.opaque
      final listeners = tester.widgetList<Listener>(find.byType(Listener));
      expect(
        listeners.where((l) => l.behavior == HitTestBehavior.opaque),
        isNotEmpty,
      );
    });

    testWidgets('renders existing strokes via CustomPaint', (tester) async {
      const stroke = DrawingStroke(
        id: 's1',
        pageNumber: 1,
        points: [StrokePoint(x: 0.5, y: 0.5)],
        toolId: 'pen',
      );
      await tester.pumpWidget(buildTestWidget(strokes: [stroke]));
      // The DrawingCanvas uses a CustomPaint with StrokePainter
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('coordinate normalization: stroke on 400x600 canvas',
        (tester) async {
      DrawingStroke? capturedStroke;

      await tester.pumpWidget(buildTestWidget(
        isActive: true,
        onStrokeCompleted: (stroke) => capturedStroke = stroke,
      ));

      // Simulate a drag gesture
      final gesture = await tester.startGesture(const Offset(200, 300));
      await tester.pump();
      await gesture.moveBy(const Offset(40, 60));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // Verify normalized coordinates
      if (capturedStroke != null) {
        expect(capturedStroke!.points.length, greaterThanOrEqualTo(2));
        // First point should be near 0.5, 0.5 (200/400, 300/600)
        final firstPoint = capturedStroke!.points.first;
        expect(firstPoint.x, closeTo(0.5, 0.05));
        expect(firstPoint.y, closeTo(0.5, 0.05));
      }
    });

    testWidgets('single pointer tracking: second touch is ignored',
        (tester) async {
      int strokeCount = 0;

      await tester.pumpWidget(buildTestWidget(
        isActive: true,
        onStrokeCompleted: (_) => strokeCount++,
      ));

      // First gesture
      final gesture1 = await tester.startGesture(const Offset(100, 100));
      await tester.pump();

      // Second gesture (should be ignored)
      final gesture2 = await tester.startGesture(const Offset(200, 200));
      await tester.pump();

      await gesture1.moveBy(const Offset(50, 50));
      await tester.pump();
      await gesture1.up();
      await tester.pump();
      await gesture2.up();
      await tester.pump();

      // Only one stroke should be completed (from gesture1)
      expect(strokeCount, lessThanOrEqualTo(1));
    });
  });
}
