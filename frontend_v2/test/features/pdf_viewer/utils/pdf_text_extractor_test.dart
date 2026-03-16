import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/pdf_viewer/utils/pdf_text_extractor.dart';

void main() {
  group('PdfTextExtractor coordinate conversion', () {
    test('toNormalized converts absolute coordinates to 0..1 range', () {
      const pageWidth = 800.0;
      const pageHeight = 1000.0;

      final normalized = PdfTextExtractor.toNormalized(
        x: 400.0,
        y: 500.0,
        pageWidth: pageWidth,
        pageHeight: pageHeight,
      );

      expect(normalized.dx, closeTo(0.5, 0.001));
      expect(normalized.dy, closeTo(0.5, 0.001));
    });

    test('toNormalized clamps values to 0..1 when out of bounds', () {
      final normalized = PdfTextExtractor.toNormalized(
        x: -100.0,
        y: 1200.0,
        pageWidth: 800.0,
        pageHeight: 1000.0,
      );

      expect(normalized.dx, equals(0.0));
      expect(normalized.dy, equals(1.0));
    });

    test('toNormalized handles zero-origin point', () {
      final normalized = PdfTextExtractor.toNormalized(
        x: 0.0,
        y: 0.0,
        pageWidth: 800.0,
        pageHeight: 1000.0,
      );

      expect(normalized.dx, equals(0.0));
      expect(normalized.dy, equals(0.0));
    });

    test('toNormalized handles full-extent point', () {
      final normalized = PdfTextExtractor.toNormalized(
        x: 800.0,
        y: 1000.0,
        pageWidth: 800.0,
        pageHeight: 1000.0,
      );

      expect(normalized.dx, closeTo(1.0, 0.001));
      expect(normalized.dy, closeTo(1.0, 0.001));
    });

    test('fromNormalized converts 0..1 range to absolute coordinates', () {
      const pageWidth = 800.0;
      const pageHeight = 1000.0;

      final absolute = PdfTextExtractor.fromNormalized(
        nx: 0.5,
        ny: 0.5,
        pageWidth: pageWidth,
        pageHeight: pageHeight,
      );

      expect(absolute.dx, closeTo(400.0, 0.001));
      expect(absolute.dy, closeTo(500.0, 0.001));
    });

    test('fromNormalized handles zero normalized coordinates', () {
      final absolute = PdfTextExtractor.fromNormalized(
        nx: 0.0,
        ny: 0.0,
        pageWidth: 800.0,
        pageHeight: 1000.0,
      );

      expect(absolute.dx, equals(0.0));
      expect(absolute.dy, equals(0.0));
    });

    test('fromNormalized handles 1.0 normalized coordinates', () {
      final absolute = PdfTextExtractor.fromNormalized(
        nx: 1.0,
        ny: 1.0,
        pageWidth: 800.0,
        pageHeight: 1000.0,
      );

      expect(absolute.dx, closeTo(800.0, 0.001));
      expect(absolute.dy, closeTo(1000.0, 0.001));
    });

    test('toNormalized and fromNormalized are inverse operations', () {
      const pageWidth = 640.0;
      const pageHeight = 480.0;
      const originalX = 320.0;
      const originalY = 240.0;

      final normalized = PdfTextExtractor.toNormalized(
        x: originalX,
        y: originalY,
        pageWidth: pageWidth,
        pageHeight: pageHeight,
      );

      final restored = PdfTextExtractor.fromNormalized(
        nx: normalized.dx,
        ny: normalized.dy,
        pageWidth: pageWidth,
        pageHeight: pageHeight,
      );

      expect(restored.dx, closeTo(originalX, 0.001));
      expect(restored.dy, closeTo(originalY, 0.001));
    });

    test('toNormalized handles non-square page dimensions', () {
      // A4 aspect ratio approximately 1:1.414
      const pageWidth = 595.0;
      const pageHeight = 842.0;

      final normalized = PdfTextExtractor.toNormalized(
        x: 297.5,
        y: 421.0,
        pageWidth: pageWidth,
        pageHeight: pageHeight,
      );

      expect(normalized.dx, closeTo(0.5, 0.001));
      expect(normalized.dy, closeTo(0.5, 0.001));
    });

    test('fromNormalized handles quarter-page coordinates', () {
      const pageWidth = 800.0;
      const pageHeight = 1200.0;

      final absolute = PdfTextExtractor.fromNormalized(
        nx: 0.25,
        ny: 0.75,
        pageWidth: pageWidth,
        pageHeight: pageHeight,
      );

      expect(absolute.dx, closeTo(200.0, 0.001));
      expect(absolute.dy, closeTo(900.0, 0.001));
    });
  });
}
