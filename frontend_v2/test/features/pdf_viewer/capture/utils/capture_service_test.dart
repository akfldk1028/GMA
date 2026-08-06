import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/pdf_viewer/capture/utils/capture_service.dart';

void main() {
  group('CaptureService', () {
    test('renderRegion static method is accessible on CaptureService', () {
      // Structural test: verifies the static method is visible and callable.
      // Full rendering requires a live PdfPage (native pdfrx object) and
      // cannot be exercised in a pure unit test environment.
      //
      // Integration tests covering the full render + crop pipeline belong in
      // the integration_test/ suite where a real PdfDocument is available.
      expect(CaptureService.renderRegion, isNotNull);
    });
  });
}
