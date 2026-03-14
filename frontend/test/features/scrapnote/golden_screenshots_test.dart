// Golden screenshot tests for SPEC-SCRAPNOTE-001 visual verification.
// Run with: flutter test --update-goldens test/features/scrapnote/golden_screenshots_test.dart
//
// Output images saved to: test/features/scrapnote/goldens/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gma_frontend/features/pdf_viewer/drawing/models/drawing_model.dart';
import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/scrapnote/pages/providers/scrapnote_canvas_provider.dart';
import 'package:gma_frontend/features/scrapnote/pages/screens/scrapnote_screen.dart';
import 'package:gma_frontend/features/scrapnote/pages/widgets/confirm_scrap_popup.dart';
import 'package:gma_frontend/features/scrapnote/pages/widgets/highlight_card_widget.dart';
import 'package:gma_frontend/features/scrapnote/pages/widgets/capture_element_widget.dart';
import 'package:gma_frontend/features/scrapnote/services/scrap_insertion_service.dart';

// --- Fake provider for screen-level tests ---

class _FakeScrapnoteCanvasState extends ScrapnoteCanvasState {
  _FakeScrapnoteCanvasState(this._data);
  final ScrapnoteCanvasData _data;

  @override
  Future<ScrapnoteCanvasData> build(String scrapnoteId) async => _data;
}

// --- Helper ---

Widget _materialWrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(child: child),
    ),
  );
}

final _now = DateTime(2026, 3, 10);

void main() {
  // 1. ScrapnoteScreen — empty canvas with toolbar
  group('Golden Screenshots', () {
    testWidgets('01_scrapnote_screen_empty', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final emptyCanvas = ScrapnoteCanvasData(
        id: 'golden-test',
        linkedPdfPath: '/test/document.pdf',
        strokes: const [],
        elements: const [],
        createdAt: _now,
        modifiedAt: _now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scrapnoteCanvasStateProvider('golden-test')
                .overrideWith(() => _FakeScrapnoteCanvasState(emptyCanvas)),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            home: const ScrapnoteScreen(scrapnoteId: 'golden-test'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/01_scrapnote_screen_empty.png'),
      );
    });

    // 2. ScrapnoteScreen — canvas with strokes and elements
    testWidgets('02_scrapnote_screen_with_content', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final sampleStrokes = <DrawingStroke>[
        DrawingStroke(
          id: 'stroke-1',
          toolId: 'pen',
          colorValue: 0xFF000000,
          size: 4.0,
          pageNumber: 0,
          points: const [
            StrokePoint(x: 100, y: 200),
            StrokePoint(x: 150, y: 180),
            StrokePoint(x: 200, y: 220),
            StrokePoint(x: 250, y: 190),
            StrokePoint(x: 300, y: 210),
          ],
        ),
        DrawingStroke(
          id: 'stroke-2',
          toolId: 'highlighter',
          colorValue: 0xFFEAB308,
          size: 12.0,
          pageNumber: 0,
          points: const [
            StrokePoint(x: 80, y: 350),
            StrokePoint(x: 200, y: 350),
            StrokePoint(x: 400, y: 355),
          ],
        ),
        DrawingStroke(
          id: 'stroke-3',
          toolId: 'pen',
          colorValue: 0xFF3B82F6,
          size: 3.0,
          pageNumber: 0,
          points: const [
            StrokePoint(x: 500, y: 150),
            StrokePoint(x: 520, y: 170),
            StrokePoint(x: 540, y: 150),
            StrokePoint(x: 560, y: 170),
            StrokePoint(x: 580, y: 150),
          ],
        ),
      ];

      final sampleElements = <CanvasElement>[
        CanvasElement(
          id: 'elem-1',
          type: CanvasElementType.highlight,
          x: 50,
          y: 400,
          width: 300,
          height: 80,
          selectedText:
              'The Fourier transform decomposes a function of time into its constituent frequencies.',
          colorValue: 0xFFEF4444,
          sourcePageNumber: 3,
          createdAt: _now,
        ),
        CanvasElement(
          id: 'elem-2',
          type: CanvasElementType.capture,
          x: 50,
          y: 100,
          width: 200,
          height: 150,
          imagePath: '/nonexistent/capture_p5.png',
          sourcePageNumber: 5,
          createdAt: _now,
        ),
        CanvasElement(
          id: 'elem-3',
          type: CanvasElementType.highlight,
          x: 400,
          y: 250,
          width: 280,
          height: 70,
          selectedText:
              'Integration by parts is a technique based on the product rule of differentiation.',
          colorValue: 0xFF22C55E,
          sourcePageNumber: 7,
          createdAt: _now,
        ),
      ];

      final contentCanvas = ScrapnoteCanvasData(
        id: 'golden-content',
        linkedPdfPath: '/test/document.pdf',
        strokes: sampleStrokes,
        elements: sampleElements,
        createdAt: _now,
        modifiedAt: _now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scrapnoteCanvasStateProvider('golden-content')
                .overrideWith(() => _FakeScrapnoteCanvasState(contentCanvas)),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            home: const ScrapnoteScreen(scrapnoteId: 'golden-content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/02_scrapnote_screen_with_content.png'),
      );
    });

    // 3. HighlightCardWidget — standalone
    testWidgets('03_highlight_card_widget', (tester) async {
      tester.view.physicalSize = const Size(600, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _materialWrap(
          SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: HighlightCardWidget(
                    element: CanvasElement(
                      id: 'hl-red',
                      type: CanvasElementType.highlight,
                      x: 0, y: 0, width: 300, height: 80,
                      selectedText:
                          'The eigenvalues of a symmetric matrix are always real numbers.',
                      colorValue: 0xFFEF4444,
                      sourcePageNumber: 12,
                      createdAt: _now,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: HighlightCardWidget(
                    element: CanvasElement(
                      id: 'hl-blue',
                      type: CanvasElementType.highlight,
                      x: 0, y: 0, width: 300, height: 80,
                      selectedText:
                          'A continuous function on a closed interval attains its maximum and minimum values.',
                      colorValue: 0xFF3B82F6,
                      sourcePageNumber: 24,
                      createdAt: _now,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: HighlightCardWidget(
                    element: CanvasElement(
                      id: 'hl-green',
                      type: CanvasElementType.highlight,
                      x: 0, y: 0, width: 300, height: 80,
                      selectedText:
                          'Proof by induction: base case + inductive step.',
                      colorValue: 0xFF22C55E,
                      sourcePageNumber: 5,
                      createdAt: _now,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/03_highlight_card_widget.png'),
      );
    });

    // 4. CaptureElementWidget — standalone (placeholder since no real image)
    testWidgets('04_capture_element_widget', (tester) async {
      tester.view.physicalSize = const Size(600, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _materialWrap(
          SizedBox(
            width: 220,
            height: 180,
            child: CaptureElementWidget(
              element: CanvasElement(
                id: 'cap-1',
                type: CanvasElementType.capture,
                x: 0, y: 0, width: 200, height: 160,
                imagePath: '/nonexistent/capture.png',
                sourcePageNumber: 3,
                createdAt: _now,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/04_capture_element_widget.png'),
      );
    });

    // 5. ConfirmScrapPopup — highlight proposal
    testWidgets('05_confirm_popup_highlight', (tester) async {
      tester.view.physicalSize = const Size(600, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final proposal = HighlightProposal(
        selectedText:
            'The fundamental theorem of calculus links the concept of differentiation and integration.',
        colorValue: 0xFFEAB308,
        sourcePageNumber: 15,
        sourcePdfPath: '/docs/calculus.pdf',
      );

      await tester.pumpWidget(
        _materialWrap(
          ConfirmScrapPopup(
            proposal: proposal,
            onAccept: () {},
            onReject: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/05_confirm_popup_highlight.png'),
      );
    });

    // 6. ConfirmScrapPopup — capture proposal
    testWidgets('06_confirm_popup_capture', (tester) async {
      tester.view.physicalSize = const Size(600, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final proposal = CaptureProposal(
        imagePath: '/nonexistent/capture_p8.png',
        sourcePageNumber: 8,
        sourcePdfPath: '/docs/linear_algebra.pdf',
      );

      await tester.pumpWidget(
        _materialWrap(
          ConfirmScrapPopup(
            proposal: proposal,
            onAccept: () {},
            onReject: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/06_confirm_popup_capture.png'),
      );
    });
  });
}
