import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/pdf_viewer/highlight/models/highlight_marker_data.dart';
import 'package:gma_app/features/pdf_viewer/highlight/providers/highlight_provider.dart';
import 'package:gma_app/features/scrapnote/models/element_model.dart';
import 'package:gma_app/features/scrapnote/providers/element_store.dart';

// ---------------------------------------------------------------------------
// Fake ElementStoreNotifier — avoids Hive in unit tests
// ---------------------------------------------------------------------------

class _FakeElementStore extends ElementStoreNotifier {
  _FakeElementStore([List<ScrapElement> initial = const []]) {
    _initial = initial;
  }

  late final List<ScrapElement> _initial;

  @override
  List<ScrapElement> build() => _initial;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _pdfPath = '/docs/test.pdf';
const _otherPdf = '/docs/other.pdf';

ScrapElement _highlight({
  required String id,
  required int page,
  double left = 0.1,
  double top = 0.2,
  double right = 0.8,
  double bottom = 0.3,
  int colorValue = 0xFFFFEB3B,
  String pdfPath = _pdfPath,
}) {
  return ScrapElement(
    id: id,
    type: ScrapElementType.highlight,
    pdfPath: pdfPath,
    selectedText: 'text',
    sourcePageNumber: page,
    sourceRect: ElementRect(left: left, top: top, right: right, bottom: bottom),
    colorValue: colorValue,
    createdAt: DateTime(2024, 1, 1),
  );
}

ScrapElement _capture({
  required String id,
  required int page,
  String pdfPath = _pdfPath,
}) {
  return ScrapElement(
    id: id,
    type: ScrapElementType.capture,
    pdfPath: pdfPath,
    imagePath: '/captures/img.png',
    sourcePageNumber: page,
    sourceRect: const ElementRect(
      left: 0.0,
      top: 0.0,
      right: 1.0,
      bottom: 1.0,
    ),
    createdAt: DateTime(2024, 1, 1),
  );
}

ProviderContainer _makeContainer(List<ScrapElement> elements) {
  return ProviderContainer(
    overrides: [
      elementStoreNotifierProvider.overrideWith(
        () => _FakeElementStore(elements),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('highlightMarkersProvider', () {
    test('returns empty map when store has no elements', () {
      final container = _makeContainer([]);
      addTearDown(container.dispose);

      final result = container.read(highlightMarkersProvider(_pdfPath));

      expect(result, isEmpty);
    });

    test('returns empty map when no highlights match the document path', () {
      final container = _makeContainer([
        _highlight(id: 'h1', page: 1, pdfPath: _otherPdf),
      ]);
      addTearDown(container.dispose);

      final result = container.read(highlightMarkersProvider(_pdfPath));

      expect(result, isEmpty);
    });

    test('groups highlights by page number', () {
      final container = _makeContainer([
        _highlight(id: 'h1', page: 1),
        _highlight(id: 'h2', page: 1),
        _highlight(id: 'h3', page: 3),
      ]);
      addTearDown(container.dispose);

      final result = container.read(highlightMarkersProvider(_pdfPath));

      expect(result.keys, containsAll([1, 3]));
      expect(result[1]!.length, 2);
      expect(result[3]!.length, 1);
    });

    test('excludes capture elements', () {
      final container = _makeContainer([
        _highlight(id: 'h1', page: 1),
        _capture(id: 'c1', page: 1),
        _capture(id: 'c2', page: 2),
      ]);
      addTearDown(container.dispose);

      final result = container.read(highlightMarkersProvider(_pdfPath));

      expect(result[1]!.length, 1);
      expect(result[1]![0].elementId, 'h1');
      expect(result.containsKey(2), isFalse);
    });

    test('excludes highlights from other pdf paths', () {
      final container = _makeContainer([
        _highlight(id: 'h1', page: 1, pdfPath: _pdfPath),
        _highlight(id: 'h2', page: 1, pdfPath: _otherPdf),
      ]);
      addTearDown(container.dispose);

      final result = container.read(highlightMarkersProvider(_pdfPath));

      expect(result[1]!.length, 1);
      expect(result[1]![0].elementId, 'h1');
    });

    test('marker carries correct elementId and colorValue', () {
      final container = _makeContainer([
        _highlight(id: 'h-color', page: 2, colorValue: 0xFF4CAF50),
      ]);
      addTearDown(container.dispose);

      final result = container.read(highlightMarkersProvider(_pdfPath));
      final marker = result[2]![0];

      expect(marker.elementId, 'h-color');
      expect(marker.colorValue, 0xFF4CAF50);
      expect(marker.pageNumber, 2);
    });

    test('marker normalizedRects contains the source rect', () {
      final container = _makeContainer([
        _highlight(
          id: 'h-rect',
          page: 1,
          left: 0.15,
          top: 0.25,
          right: 0.75,
          bottom: 0.35,
        ),
      ]);
      addTearDown(container.dispose);

      final result = container.read(highlightMarkersProvider(_pdfPath));
      final rect = result[1]![0].normalizedRects[0];

      expect(rect.left, 0.15);
      expect(rect.top, 0.25);
      expect(rect.right, 0.75);
      expect(rect.bottom, 0.35);
    });

    test('updates reactively when elements are added', () {
      final container = _makeContainer([]);
      addTearDown(container.dispose);

      expect(container.read(highlightMarkersProvider(_pdfPath)), isEmpty);

      // Simulate adding an element by updating the notifier state directly.
      container.read(elementStoreNotifierProvider.notifier).state = [
        _highlight(id: 'h-new', page: 4),
      ];

      final updated = container.read(highlightMarkersProvider(_pdfPath));
      expect(updated[4]!.length, 1);
      expect(updated[4]![0].elementId, 'h-new');
    });

    test('updates reactively when elements are removed', () {
      final container = _makeContainer([
        _highlight(id: 'h1', page: 1),
        _highlight(id: 'h2', page: 2),
      ]);
      addTearDown(container.dispose);

      // Remove page-1 highlight.
      container.read(elementStoreNotifierProvider.notifier).state = [
        _highlight(id: 'h2', page: 2),
      ];

      final updated = container.read(highlightMarkersProvider(_pdfPath));
      expect(updated.containsKey(1), isFalse);
      expect(updated[2]!.length, 1);
    });
  });
}
