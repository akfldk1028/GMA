import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/scrapnote/models/scrapnote_canvas_model.dart';
import 'package:gma_frontend/features/scrapnote/services/scrap_insertion_service.dart';

void main() {
  group('ScrapInsertionService', () {
    late ScrapInsertionService service;

    setUp(() {
      service = ScrapInsertionService();
    });

    tearDown(() {
      service.dispose();
    });

    // ─── proposeCapture ──────────────────────────────────────

    test('proposeCapture returns accepted when accept() is called', () async {
      final proposal = CaptureProposal(
        imagePath: '/tmp/capture.png',
        sourcePageNumber: 3,
        sourcePdfPath: '/docs/book.pdf',
      );

      final future = service.proposeCapture(proposal);
      service.accept();

      expect(await future, InsertionResult.accepted);
    });

    test('proposeCapture returns rejected when reject() is called', () async {
      final proposal = CaptureProposal(
        imagePath: '/tmp/capture.png',
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      final future = service.proposeCapture(proposal);
      service.reject();

      expect(await future, InsertionResult.rejected);
    });

    test('proposeCapture returns timeout after 30 seconds (fake async)',
        () async {
      fakeAsync((async) {
        final proposal = CaptureProposal(
          imagePath: '/tmp/capture.png',
          sourcePageNumber: 2,
          sourcePdfPath: '/docs/book.pdf',
        );

        InsertionResult? result;
        service.proposeCapture(proposal).then((r) => result = r);

        // Just before 30s — should not have timed out yet
        async.elapse(const Duration(seconds: 29));
        expect(result, isNull);

        // At 30s — should time out
        async.elapse(const Duration(seconds: 1));
        expect(result, InsertionResult.timeout);
      });
    });

    // ─── proposeHighlight ────────────────────────────────────

    test('proposeHighlight returns accepted when accept() is called', () async {
      final proposal = HighlightProposal(
        selectedText: 'Hello world',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 5,
        sourcePdfPath: '/docs/book.pdf',
      );

      final future = service.proposeHighlight(proposal);
      service.accept();

      expect(await future, InsertionResult.accepted);
    });

    test('proposeHighlight returns rejected when reject() is called', () async {
      final proposal = HighlightProposal(
        selectedText: 'Selected text',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      final future = service.proposeHighlight(proposal);
      service.reject();

      expect(await future, InsertionResult.rejected);
    });

    test('proposeHighlight returns timeout after 30 seconds (fake async)',
        () async {
      fakeAsync((async) {
        final proposal = HighlightProposal(
          selectedText: 'Highlighted passage',
          colorValue: 0xFFFFFF00,
          sourcePageNumber: 4,
          sourcePdfPath: '/docs/book.pdf',
        );

        InsertionResult? result;
        service.proposeHighlight(proposal).then((r) => result = r);

        async.elapse(const Duration(seconds: 29));
        expect(result, isNull);

        async.elapse(const Duration(seconds: 1));
        expect(result, InsertionResult.timeout);
      });
    });

    // ─── proposals stream ────────────────────────────────────

    test('proposals stream emits CaptureProposal when proposeCapture is called',
        () async {
      final proposal = CaptureProposal(
        imagePath: '/tmp/cap.png',
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      final emitted = <Object>[];
      final sub = service.proposals.listen(emitted.add);

      // ignore: unawaited_futures
      service.proposeCapture(proposal);
      service.reject();

      // Allow microtasks to flush
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted.length, 1);
      expect(emitted.first, isA<CaptureProposal>());
    });

    test(
        'proposals stream emits HighlightProposal when proposeHighlight is called',
        () async {
      final proposal = HighlightProposal(
        selectedText: 'text',
        colorValue: 0xFFFFFF00,
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );

      final emitted = <Object>[];
      final sub = service.proposals.listen(emitted.add);

      // ignore: unawaited_futures
      service.proposeHighlight(proposal);
      service.reject();

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted.length, 1);
      expect(emitted.first, isA<HighlightProposal>());
    });

    // ─── calculateAutoPosition ────────────────────────────────

    test('calculateAutoPosition returns default position for empty list', () {
      final pos = ScrapInsertionService.calculateAutoPosition([]);
      expect(pos.x, 50.0);
      expect(pos.y, 100.0);
    });

    test('calculateAutoPosition places new element below the bottom-most element',
        () {
      final elements = [
        CanvasElement(
          id: 'e1',
          type: CanvasElementType.capture,
          x: 50,
          y: 100,
          width: 400,
          height: 300,
          createdAt: DateTime.now(),
        ),
        CanvasElement(
          id: 'e2',
          type: CanvasElementType.highlight,
          x: 50,
          y: 500,
          width: 500,
          height: 80,
          createdAt: DateTime.now(),
        ),
      ];

      // Bottom of e2 = 500 + 80 = 580; gap = 30 → expected y = 610
      final pos = ScrapInsertionService.calculateAutoPosition(elements);
      expect(pos.x, 50.0);
      expect(pos.y, 610.0);
    });

    test('calculateAutoPosition uses the bottom-most element even if out of order',
        () {
      final elements = [
        CanvasElement(
          id: 'e1',
          type: CanvasElementType.capture,
          x: 50,
          y: 800,
          width: 400,
          height: 200,
          createdAt: DateTime.now(),
        ),
        CanvasElement(
          id: 'e2',
          type: CanvasElementType.highlight,
          x: 50,
          y: 100,
          width: 500,
          height: 80,
          createdAt: DateTime.now(),
        ),
      ];

      // Bottom of e1 = 800 + 200 = 1000; gap = 30 → expected y = 1030
      final pos = ScrapInsertionService.calculateAutoPosition(elements);
      expect(pos.y, 1030.0);
    });

    // ─── accept/reject with no pending proposal ──────────────

    test('accept() is a no-op when no proposal is pending', () {
      // Should not throw
      expect(() => service.accept(), returnsNormally);
    });

    test('reject() is a no-op when no proposal is pending', () {
      expect(() => service.reject(), returnsNormally);
    });

    // ─── sequential proposals ────────────────────────────────

    test('second proposal cancels the first with rejected', () async {
      final p1 = CaptureProposal(
        imagePath: '/tmp/a.png',
        sourcePageNumber: 1,
        sourcePdfPath: '/docs/book.pdf',
      );
      final p2 = CaptureProposal(
        imagePath: '/tmp/b.png',
        sourcePageNumber: 2,
        sourcePdfPath: '/docs/book.pdf',
      );

      final future1 = service.proposeCapture(p1);
      final future2 = service.proposeCapture(p2);

      // First proposal auto-rejected because second replaced it
      expect(await future1, InsertionResult.rejected);

      // Accept the second
      service.accept();
      expect(await future2, InsertionResult.accepted);
    });
  });
}

