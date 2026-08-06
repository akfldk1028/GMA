import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/pdf_viewer/models/pdf_document_state.dart';

void main() {
  group('PdfDocumentState', () {
    test('creates with defaults', () {
      const state = PdfDocumentState();
      expect(state.document, isNull);
      expect(state.currentPage, 1);
      expect(state.totalPages, 0);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('creates in loading state', () {
      const state = PdfDocumentState(isLoading: true);
      expect(state.isLoading, isTrue);
      expect(state.document, isNull);
      expect(state.error, isNull);
    });

    test('creates with error state', () {
      const state = PdfDocumentState(
        error: 'File not found',
        isLoading: false,
      );
      expect(state.error, 'File not found');
      expect(state.isLoading, isFalse);
    });

    test('copyWith updates currentPage', () {
      const state = PdfDocumentState(totalPages: 10);
      final updated = state.copyWith(currentPage: 5);
      expect(updated.currentPage, 5);
      expect(updated.totalPages, 10);
    });

    test('copyWith clears error', () {
      const state = PdfDocumentState(error: 'some error');
      final updated = state.copyWith(error: null);
      expect(updated.error, isNull);
    });

    test('copyWith sets loading', () {
      const state = PdfDocumentState();
      final loading = state.copyWith(isLoading: true);
      expect(loading.isLoading, isTrue);
      final done = loading.copyWith(isLoading: false);
      expect(done.isLoading, isFalse);
    });

    test('equality works for identical states', () {
      const a = PdfDocumentState();
      const b = PdfDocumentState();
      expect(a, equals(b));
    });

    test('equality fails for different states', () {
      const a = PdfDocumentState(currentPage: 1);
      const b = PdfDocumentState(currentPage: 2);
      expect(a, isNot(equals(b)));
    });

    test('fromJson round-trip', () {
      const state = PdfDocumentState(
        currentPage: 3,
        totalPages: 10,
        isLoading: false,
        error: null,
      );
      final json = state.toJson();
      final restored = PdfDocumentState.fromJson(json);
      expect(restored.currentPage, state.currentPage);
      expect(restored.totalPages, state.totalPages);
      expect(restored.isLoading, state.isLoading);
      expect(restored.error, state.error);
    });
  });
}
