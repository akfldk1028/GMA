import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/pdf_viewer/models/pdf_document_state.dart';
import 'package:gma_app/features/pdf_viewer/pages/providers/pdf_document_provider.dart';
import 'package:gma_app/features/pdf_viewer/pages/screens/pdf_viewer_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  Widget buildTestWidget({
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: ShadApp(
        home: Scaffold(body: const PdfViewerScreen()),
      ),
    );
  }

  group('PdfViewerScreen', () {
    testWidgets('shows empty state when no document loaded', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Should show empty/placeholder state (no loading, no error)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        overrides: [
          pdfDocumentNotifierProvider.overrideWith(
            () => _LoadingPdfDocumentNotifier(),
          ),
        ],
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error is set', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        overrides: [
          pdfDocumentNotifierProvider.overrideWith(
            () => _ErrorPdfDocumentNotifier(),
          ),
        ],
      ));
      await tester.pump();

      expect(find.textContaining('error', findRichText: true), findsWidgets);
    });

    testWidgets('renders PdfViewerScreen widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(PdfViewerScreen), findsOneWidget);
    });
  });
}

class _LoadingPdfDocumentNotifier extends PdfDocumentNotifier {
  @override
  PdfDocumentState build() => const PdfDocumentState(isLoading: true);
}

class _ErrorPdfDocumentNotifier extends PdfDocumentNotifier {
  @override
  PdfDocumentState build() =>
      const PdfDocumentState(error: 'Failed to load PDF error message');
}
