import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/pdf_viewer/highlight/models/highlight_marker_data.dart';
import 'package:gma_app/features/pdf_viewer/highlight/providers/highlight_provider.dart';
import 'package:gma_app/features/pdf_viewer/highlight/widgets/highlight_overlay.dart';
import 'package:gma_app/features/scrapnote/models/element_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ---------------------------------------------------------------------------
// Fake HighlightMarkers notifier stubs
// ---------------------------------------------------------------------------

class _EmptyHighlightMarkers extends HighlightMarkers {
  @override
  Map<int, List<HighlightMarkerData>> build(String documentPath) => const {};
}

class _WithHighlightMarkers extends HighlightMarkers {
  _WithHighlightMarkers(this._data);
  final Map<int, List<HighlightMarkerData>> _data;

  @override
  Map<int, List<HighlightMarkerData>> build(String documentPath) => _data;
}

// ---------------------------------------------------------------------------
// Widget builder
// ---------------------------------------------------------------------------

Widget _buildWidget({
  required String documentPath,
  required int pageNumber,
  double pageWidth = 400.0,
  double pageHeight = 600.0,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: ShadApp(
      home: Scaffold(
        body: SizedBox(
          width: pageWidth,
          height: pageHeight,
          child: HighlightOverlay(
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const docPath = 'test.pdf';

  group('HighlightOverlay', () {
    testWidgets('renders without error when no highlights exist',
        (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          documentPath: docPath,
          pageNumber: 1,
          overrides: [
            highlightMarkersProvider(docPath).overrideWith(
              () => _EmptyHighlightMarkers(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(HighlightOverlay), findsOneWidget);
    });

    testWidgets('contains CustomPaint when no highlights exist',
        (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          documentPath: docPath,
          pageNumber: 1,
          overrides: [
            highlightMarkersProvider(docPath).overrideWith(
              () => _EmptyHighlightMarkers(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('contains CustomPaint when highlights exist', (tester) async {
      const rect = ElementRect(left: 0.1, top: 0.2, right: 0.8, bottom: 0.3);
      final highlights = {
        1: [
          const HighlightMarkerData(
            pageNumber: 1,
            normalizedRects: [rect],
            colorValue: 0xFFFFEB3B,
            elementId: 'elem-1',
          ),
        ],
      };

      await tester.pumpWidget(
        _buildWidget(
          documentPath: docPath,
          pageNumber: 1,
          overrides: [
            highlightMarkersProvider(docPath).overrideWith(
              () => _WithHighlightMarkers(highlights),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('is wrapped in IgnorePointer so events pass through',
        (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          documentPath: docPath,
          pageNumber: 1,
          overrides: [
            highlightMarkersProvider(docPath).overrideWith(
              () => _EmptyHighlightMarkers(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(IgnorePointer), findsWidgets);
    });

    testWidgets('renders gracefully for page with no matching highlights',
        (tester) async {
      final highlights = {
        2: [
          const HighlightMarkerData(
            pageNumber: 2,
            normalizedRects: [
              ElementRect(left: 0.0, top: 0.0, right: 0.5, bottom: 0.1),
            ],
            colorValue: 0xFF4CAF50,
            elementId: 'elem-page2',
          ),
        ],
      };

      // Render for page 1 — no highlights on that page.
      await tester.pumpWidget(
        _buildWidget(
          documentPath: docPath,
          pageNumber: 1,
          overrides: [
            highlightMarkersProvider(docPath).overrideWith(
              () => _WithHighlightMarkers(highlights),
            ),
          ],
        ),
      );
      await tester.pump();

      // Should not throw; CustomPaint is still present (paints nothing).
      expect(find.byType(HighlightOverlay), findsOneWidget);
    });
  });
}
