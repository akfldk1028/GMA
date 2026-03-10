import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/scrapnote/pages/widgets/confirm_scrap_popup.dart';
import 'package:gma_frontend/features/scrapnote/services/scrap_insertion_service.dart';

// Helper to wrap the widget under test in a Material app
Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('ConfirmScrapPopup', () {
    // ─── CaptureProposal rendering ────────────────────────────

    testWidgets('renders header text for capture proposal', (tester) async {
      final proposal = CaptureProposal(
        imagePath: '/nonexistent/image.png',
        sourcePageNumber: 3,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () {},
          onReject: () {},
        ),
      ));

      expect(find.text('Add capture to scrapnote?'), findsOneWidget);
    });

    testWidgets('shows an image widget for capture proposal', (tester) async {
      final proposal = CaptureProposal(
        imagePath: '/nonexistent/image.png',
        sourcePageNumber: 3,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () {},
          onReject: () {},
        ),
      ));

      // The popup should contain an Image widget (or its fallback) for captures
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    // ─── HighlightProposal rendering ──────────────────────────

    testWidgets('renders header text for highlight proposal', (tester) async {
      final proposal = HighlightProposal(
        selectedText: 'This is highlighted text',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 5,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () {},
          onReject: () {},
        ),
      ));

      expect(find.text('Add highlight to scrapnote?'), findsOneWidget);
    });

    testWidgets('renders selected text preview for highlight proposal',
        (tester) async {
      final proposal = HighlightProposal(
        selectedText: 'Hello scrapnote world',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 2,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () {},
          onReject: () {},
        ),
      ));

      expect(find.text('Hello scrapnote world'), findsOneWidget);
    });

    // ─── Button callbacks ─────────────────────────────────────

    testWidgets('accept button triggers onAccept callback', (tester) async {
      bool accepted = false;
      final proposal = HighlightProposal(
        selectedText: 'text',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () => accepted = true,
          onReject: () {},
        ),
      ));

      await tester.tap(find.byKey(const Key('confirm_scrap_popup_accept')));
      await tester.pump();

      expect(accepted, isTrue);
    });

    testWidgets('reject button triggers onReject callback', (tester) async {
      bool rejected = false;
      final proposal = HighlightProposal(
        selectedText: 'text',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () {},
          onReject: () => rejected = true,
        ),
      ));

      await tester.tap(find.byKey(const Key('confirm_scrap_popup_reject')));
      await tester.pump();

      expect(rejected, isTrue);
    });

    testWidgets('accept button does not trigger onReject', (tester) async {
      bool rejected = false;
      final proposal = CaptureProposal(
        imagePath: '/tmp/img.png',
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () {},
          onReject: () => rejected = true,
        ),
      ));

      await tester.tap(find.byKey(const Key('confirm_scrap_popup_accept')));
      await tester.pump();

      expect(rejected, isFalse);
    });

    testWidgets('reject button does not trigger onAccept', (tester) async {
      bool accepted = false;
      final proposal = CaptureProposal(
        imagePath: '/tmp/img.png',
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () => accepted = true,
          onReject: () {},
        ),
      ));

      await tester.tap(find.byKey(const Key('confirm_scrap_popup_reject')));
      await tester.pump();

      expect(accepted, isFalse);
    });

    // ─── Icons ───────────────────────────────────────────────

    testWidgets('shows check icon in accept button', (tester) async {
      final proposal = HighlightProposal(
        selectedText: 'text',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () {},
          onReject: () {},
        ),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows close icon in reject button', (tester) async {
      final proposal = HighlightProposal(
        selectedText: 'text',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      await tester.pumpWidget(_wrap(
        ConfirmScrapPopup(
          proposal: proposal,
          onAccept: () {},
          onReject: () {},
        ),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
