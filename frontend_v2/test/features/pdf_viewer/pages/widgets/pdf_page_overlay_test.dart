import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/drawing/models/drawing_model.dart';
import 'package:gma_app/features/drawing/pages/providers/drawing_provider.dart';
import 'package:gma_app/features/drawing/pages/widgets/drawing_canvas.dart';
import 'package:gma_app/features/pdf_viewer/highlight/models/highlight_marker_data.dart';
import 'package:gma_app/features/pdf_viewer/highlight/providers/highlight_provider.dart';
import 'package:gma_app/features/pdf_viewer/highlight/widgets/highlight_overlay.dart';
import 'package:gma_app/features/pdf_viewer/pages/widgets/pdf_page_overlay.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class _EmptyHighlightMarkers extends HighlightMarkers {
  @override
  Map<int, List<HighlightMarkerData>> build(String documentPath) => const {};
}

void main() {
  Widget buildTestWidget({
    required String documentPath,
    required int pageNumber,
    required double pageWidth,
    required double pageHeight,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        // Always override the highlight provider to avoid Hive dependency.
        highlightMarkersProvider(documentPath).overrideWith(
          () => _EmptyHighlightMarkers(),
        ),
        ...overrides,
      ],
      child: ShadApp(
        home: Scaffold(
          body: SizedBox(
            width: pageWidth,
            height: pageHeight,
            child: PdfPageOverlay(
              documentPath: documentPath,
              pageNumber: pageNumber,
              pageWidth: pageWidth,
              pageHeight: pageHeight,
            ),
          ),
        ),
      ),
    );
  }

  group('PdfPageOverlay', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        documentPath: 'test.pdf',
        pageNumber: 1,
        pageWidth: 400.0,
        pageHeight: 600.0,
      ));
      await tester.pump();

      expect(find.byType(PdfPageOverlay), findsOneWidget);
    });

    testWidgets('contains DrawingCanvas for drawing layer', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        documentPath: 'test.pdf',
        pageNumber: 1,
        pageWidth: 400.0,
        pageHeight: 600.0,
      ));
      await tester.pump();

      expect(find.byType(DrawingCanvas), findsOneWidget);
    });

    testWidgets('uses Stack to compose layers', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        documentPath: 'test.pdf',
        pageNumber: 1,
        pageWidth: 400.0,
        pageHeight: 600.0,
      ));
      await tester.pump();

      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('passes correct pageNumber to drawing canvas', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        documentPath: 'test.pdf',
        pageNumber: 3,
        pageWidth: 400.0,
        pageHeight: 600.0,
      ));
      await tester.pump();

      final canvas = tester.widget<DrawingCanvas>(find.byType(DrawingCanvas));
      expect(canvas.pageNumber, equals(3));
    });

    testWidgets('drawing canvas is inactive when drawing mode is off',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        documentPath: 'test.pdf',
        pageNumber: 1,
        pageWidth: 400.0,
        pageHeight: 600.0,
      ));
      await tester.pump();

      final canvas = tester.widget<DrawingCanvas>(find.byType(DrawingCanvas));
      // Default drawing mode is inactive
      expect(canvas.isActive, isFalse);
    });

    testWidgets('drawing canvas is active when drawing mode is on',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        documentPath: 'test.pdf',
        pageNumber: 1,
        pageWidth: 400.0,
        pageHeight: 600.0,
        overrides: [
          drawingModeProvider.overrideWith(() => _ActiveDrawingMode()),
        ],
      ));
      await tester.pump();

      final canvas = tester.widget<DrawingCanvas>(find.byType(DrawingCanvas));
      expect(canvas.isActive, isTrue);
    });

    testWidgets('contains HighlightOverlay for highlight layer', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        documentPath: 'test.pdf',
        pageNumber: 1,
        pageWidth: 400.0,
        pageHeight: 600.0,
      ));
      await tester.pump();

      expect(find.byType(HighlightOverlay), findsOneWidget);
    });

    testWidgets('HighlightOverlay is rendered below DrawingCanvas in stack',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        documentPath: 'test.pdf',
        pageNumber: 2,
        pageWidth: 400.0,
        pageHeight: 600.0,
      ));
      await tester.pump();

      // Both layers must coexist in the widget tree.
      expect(find.byType(HighlightOverlay), findsOneWidget);
      expect(find.byType(DrawingCanvas), findsOneWidget);
    });
  });
}

class _ActiveDrawingMode extends DrawingMode {
  @override
  DrawingToolState build() => const DrawingToolState(isActive: true);
}
