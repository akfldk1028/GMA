import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/pages/widgets/confirm_scrap_popup.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Minimal 1x1 PNG bytes for testing.
// Generated from a single transparent pixel.
final Uint8List _kMinimalPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
  0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
  0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
  0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, // IEND chunk
  0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Widget _buildTestWidget({
  required Uint8List previewBytes,
  required VoidCallback onAccept,
  required VoidCallback onReject,
}) {
  return ShadApp(
    home: Scaffold(
      body: ConfirmScrapPopup(
        previewImageBytes: previewBytes,
        onAccept: onAccept,
        onReject: onReject,
      ),
    ),
  );
}

void main() {
  group('ConfirmScrapPopup', () {
    testWidgets('renders the popup with preview image', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          previewBytes: _kMinimalPng,
          onAccept: () {},
          onReject: () {},
        ),
      );
      await tester.pump();

      expect(find.byType(ConfirmScrapPopup), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('accept button calls onAccept', (tester) async {
      bool acceptCalled = false;

      await tester.pumpWidget(
        _buildTestWidget(
          previewBytes: _kMinimalPng,
          onAccept: () => acceptCalled = true,
          onReject: () {},
        ),
      );
      await tester.pump();

      // Tap the accept (check icon) button.
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(acceptCalled, isTrue);
    });

    testWidgets('reject button calls onReject', (tester) async {
      bool rejectCalled = false;

      await tester.pumpWidget(
        _buildTestWidget(
          previewBytes: _kMinimalPng,
          onAccept: () {},
          onReject: () => rejectCalled = true,
        ),
      );
      await tester.pump();

      // Tap the reject (close icon) button.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(rejectCalled, isTrue);
    });

    testWidgets('auto-dismiss timer fires after 30 seconds and calls onReject',
        (tester) async {
      bool rejectCalled = false;

      await tester.pumpWidget(
        _buildTestWidget(
          previewBytes: _kMinimalPng,
          onAccept: () {},
          onReject: () => rejectCalled = true,
        ),
      );
      await tester.pump();

      // Advance time past the 30-second auto-dismiss threshold.
      await tester.pump(const Duration(seconds: 31));

      expect(rejectCalled, isTrue);
    });

    testWidgets('timer is cancelled when accept is tapped before timeout',
        (tester) async {
      int rejectCount = 0;

      await tester.pumpWidget(
        _buildTestWidget(
          previewBytes: _kMinimalPng,
          onAccept: () {},
          onReject: () => rejectCount++,
        ),
      );
      await tester.pump();

      // Accept before timeout.
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      // Advance past timeout.
      await tester.pump(const Duration(seconds: 31));

      // Timer should have been cancelled; onReject not called.
      expect(rejectCount, isZero);
    });

    testWidgets('timer is cancelled on reject tap (no duplicate reject calls)',
        (tester) async {
      int rejectCount = 0;

      await tester.pumpWidget(
        _buildTestWidget(
          previewBytes: _kMinimalPng,
          onAccept: () {},
          onReject: () => rejectCount++,
        ),
      );
      await tester.pump();

      // Reject manually.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(rejectCount, equals(1));

      // Advance past timeout — timer should already be cancelled.
      await tester.pump(const Duration(seconds: 31));

      // Still only one rejection.
      expect(rejectCount, equals(1));
    });

    testWidgets('widget is compact (width ~200 logical pixels)', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          previewBytes: _kMinimalPng,
          onAccept: () {},
          onReject: () {},
        ),
      );
      await tester.pump();

      final sizebox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(ShadCard),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizebox.width, equals(200.0));
    });

    testWidgets('check and close icons are present', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          previewBytes: _kMinimalPng,
          onAccept: () {},
          onReject: () {},
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
