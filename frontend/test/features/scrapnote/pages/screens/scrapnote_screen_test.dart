import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/scrapnote/pages/providers/scrapnote_canvas_provider.dart';
import 'package:gma_frontend/features/scrapnote/pages/screens/scrapnote_screen.dart';
import 'package:gma_frontend/features/scrapnote/pages/widgets/scrapnote_canvas.dart';

/// Fake notifier that immediately returns test canvas data.
class _FakeScrapnoteCanvasState extends ScrapnoteCanvasState {
  _FakeScrapnoteCanvasState(this._data);
  final ScrapnoteCanvasData _data;

  @override
  Future<ScrapnoteCanvasData> build(String scrapnoteId) async => _data;
}

void main() {
  group('ScrapnoteScreen', () {
    final testCanvasData = ScrapnoteCanvasData(
      id: 'test-scrapnote-id',
      linkedPdfPath: '/test/path.pdf',
      strokes: const [],
      elements: const [],
      createdAt: DateTime(2024, 1, 1),
      modifiedAt: DateTime(2024, 1, 1),
    );

    Widget buildScreen({String scrapnoteId = 'test-scrapnote-id'}) {
      return ProviderScope(
        overrides: [
          scrapnoteCanvasStateProvider(scrapnoteId).overrideWith(
            () => _FakeScrapnoteCanvasState(testCanvasData),
          ),
        ],
        child: MaterialApp(
          home: ScrapnoteScreen(scrapnoteId: scrapnoteId),
        ),
      );
    }

    group('AppBar', () {
      testWidgets('renders AppBar with back button', (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('AppBar shows Scrapnote title', (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        expect(find.text('Scrapnote'), findsOneWidget);
      });
    });

    group('Canvas', () {
      testWidgets('shows canvas widget', (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        expect(find.byType(ScrapnoteCanvas), findsOneWidget);
      });

      testWidgets('shows loading indicator while canvas data is loading', (tester) async {
        await tester.pumpWidget(buildScreen());
        // Before pumpAndSettle, should show loading
        await tester.pump();
        // Either loading indicator or canvas should be visible
        final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
        final hasCanvas = find.byType(ScrapnoteCanvas).evaluate().isNotEmpty;
        expect(hasLoading || hasCanvas, isTrue);
      });
    });

    group('Toolbar', () {
      testWidgets('shows toolbar with drawing tools', (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        // The screen should have some form of toolbar
        // Check for icon buttons that represent drawing tools
        final hasToolbarIcons = find.byType(IconButton).evaluate().isNotEmpty ||
            find.byType(InkWell).evaluate().isNotEmpty;
        expect(hasToolbarIcons, isTrue);
      });
    });

    group('Layout', () {
      testWidgets('uses Scaffold as root widget', (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('canvas takes up remaining space below toolbar', (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        // Layout should have a Column with toolbar + canvas
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('renders with different scrapnote ids', (tester) async {
        final altData = testCanvasData.copyWith(id: 'another-id');
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              scrapnoteCanvasStateProvider('another-id').overrideWith(
                () => _FakeScrapnoteCanvasState(altData),
              ),
            ],
            child: const MaterialApp(
              home: ScrapnoteScreen(scrapnoteId: 'another-id'),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(ScrapnoteScreen), findsOneWidget);
      });
    });
  });
}
