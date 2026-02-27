import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/workspace/models/pdf_marker_model.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  // PdfRect tests removed - PdfRect is from pdfrx package, not our code
  // PdfRectConverter is tested via PdfMarker serialization tests

  group('PdfMarker', () {
    group('serialization with all fields', () {
      test('toJson creates valid JSON with all fields including optionals', () {
        final marker = PdfMarker(
          id: 'marker-123',
          pageNumber: 5,
          color: MarkerColor.red,
          selectedText: 'Selected text content',
          textRect: PdfRect(10, 70, 110, 20),
          capturedImagePath: './captures/p5_capture.png',
        );
        final json = marker.toJson();

        expect(json['id'], 'marker-123');
        expect(json['pageNumber'], 5);
        expect(json['color'], 'red');
        expect(json['selectedText'], 'Selected text content');
        expect(json['textRect'], isA<Map<String, dynamic>>());
        expect(json['textRect']['left'], 10.0);
        expect(json['capturedImagePath'], './captures/p5_capture.png');
      });

      test('fromJson creates valid PdfMarker with all fields', () {
        final json = {
          'id': 'marker-456',
          'pageNumber': 10,
          'color': 'yellow',
          'selectedText': 'Important note',
          'textRect': {
            'left': 15.0,
            'top': 25.0,
            'right': 120.0,
            'bottom': 60.0,
          },
          'capturedImagePath': './captures/p10_capture.png',
        };
        final marker = PdfMarker.fromJson(json);

        expect(marker.id, 'marker-456');
        expect(marker.pageNumber, 10);
        expect(marker.color, MarkerColor.yellow);
        expect(marker.selectedText, 'Important note');
        expect(marker.textRect, isNotNull);
        expect(marker.textRect!.left, 15.0);
        expect(marker.capturedImagePath, './captures/p10_capture.png');
      });

      test('roundtrip serialization with all fields maintains data integrity',
          () {
        final original = PdfMarker(
          id: 'marker-789',
          pageNumber: 15,
          color: MarkerColor.green,
          selectedText: 'Key insight',
          textRect: PdfRect(20, 105, 170, 30),
          capturedImagePath: './captures/p15_capture.png',
        );
        final json = original.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('serialization with minimal required fields', () {
      test('toJson creates valid JSON with only required fields', () {
        final marker = PdfMarker(
          id: 'marker-minimal',
          pageNumber: 1,
          color: MarkerColor.blue,
        );
        final json = marker.toJson();

        expect(json['id'], 'marker-minimal');
        expect(json['pageNumber'], 1);
        expect(json['color'], 'blue');
        expect(json.containsKey('selectedText'), true);
        expect(json['selectedText'], null);
        expect(json.containsKey('textRect'), true);
        expect(json['textRect'], null);
        expect(json.containsKey('capturedImagePath'), true);
        expect(json['capturedImagePath'], null);
      });

      test('fromJson creates valid PdfMarker with only required fields', () {
        final json = {
          'id': 'marker-required-only',
          'pageNumber': 3,
          'color': 'purple',
        };
        final marker = PdfMarker.fromJson(json);

        expect(marker.id, 'marker-required-only');
        expect(marker.pageNumber, 3);
        expect(marker.color, MarkerColor.purple);
        expect(marker.selectedText, null);
        expect(marker.textRect, null);
        expect(marker.capturedImagePath, null);
      });

      test('roundtrip serialization with minimal fields maintains data', () {
        const original = PdfMarker(
          id: 'marker-minimal-roundtrip',
          pageNumber: 7,
          color: MarkerColor.yellow,
        );
        final json = original.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('MarkerColor enum serialization', () {
      test('serializes all MarkerColor values correctly', () {
        final markers = [
          PdfMarker(
              id: 'red-marker', pageNumber: 1, color: MarkerColor.red),
          PdfMarker(
              id: 'yellow-marker', pageNumber: 2, color: MarkerColor.yellow),
          PdfMarker(
              id: 'green-marker', pageNumber: 3, color: MarkerColor.green),
          PdfMarker(
              id: 'blue-marker', pageNumber: 4, color: MarkerColor.blue),
          PdfMarker(
              id: 'purple-marker', pageNumber: 5, color: MarkerColor.purple),
        ];

        final jsonList = markers.map((m) => m.toJson()).toList();

        expect(jsonList[0]['color'], 'red');
        expect(jsonList[1]['color'], 'yellow');
        expect(jsonList[2]['color'], 'green');
        expect(jsonList[3]['color'], 'blue');
        expect(jsonList[4]['color'], 'purple');
      });

      test('deserializes all MarkerColor values correctly', () {
        final jsonList = [
          {'id': 'm1', 'pageNumber': 1, 'color': 'red'},
          {'id': 'm2', 'pageNumber': 2, 'color': 'yellow'},
          {'id': 'm3', 'pageNumber': 3, 'color': 'green'},
          {'id': 'm4', 'pageNumber': 4, 'color': 'blue'},
          {'id': 'm5', 'pageNumber': 5, 'color': 'purple'},
        ];

        final markers = jsonList.map((j) => PdfMarker.fromJson(j)).toList();

        expect(markers[0].color, MarkerColor.red);
        expect(markers[1].color, MarkerColor.yellow);
        expect(markers[2].color, MarkerColor.green);
        expect(markers[3].color, MarkerColor.blue);
        expect(markers[4].color, MarkerColor.purple);
      });
    });

    group('edge cases', () {
      test('handles empty string selectedText', () {
        final marker = PdfMarker(
          id: 'marker-empty-text',
          pageNumber: 1,
          color: MarkerColor.red,
          selectedText: '',
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized.selectedText, '');
        expect(deserialized, marker);
      });

      test('handles empty string capturedImagePath', () {
        final marker = PdfMarker(
          id: 'marker-empty-path',
          pageNumber: 1,
          color: MarkerColor.red,
          capturedImagePath: '',
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized.capturedImagePath, '');
        expect(deserialized, marker);
      });

      test('handles very long selectedText', () {
        final longText = 'A' * 10000;
        final marker = PdfMarker(
          id: 'marker-long-text',
          pageNumber: 1,
          color: MarkerColor.red,
          selectedText: longText,
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized.selectedText, longText);
        expect(deserialized, marker);
      });

      test('handles special characters in selectedText', () {
        const specialText = '특수문자 テスト 😀 \n\t\r';
        final marker = PdfMarker(
          id: 'marker-special-chars',
          pageNumber: 1,
          color: MarkerColor.red,
          selectedText: specialText,
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized.selectedText, specialText);
        expect(deserialized, marker);
      });

      test('handles page number 0', () {
        final marker = PdfMarker(
          id: 'marker-page-0',
          pageNumber: 0,
          color: MarkerColor.red,
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized.pageNumber, 0);
        expect(deserialized, marker);
      });

      test('handles very large page numbers', () {
        final marker = PdfMarker(
          id: 'marker-large-page',
          pageNumber: 999999,
          color: MarkerColor.red,
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized.pageNumber, 999999);
        expect(deserialized, marker);
      });

      test('handles UUID-style IDs', () {
        final marker = PdfMarker(
          id: '550e8400-e29b-41d4-a716-446655440000',
          pageNumber: 1,
          color: MarkerColor.red,
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(deserialized, marker);
      });
    });

    group('equality', () {
      test('two PdfMarkers with same values are equal', () {
        const marker1 = PdfMarker(
          id: 'same-id',
          pageNumber: 5,
          color: MarkerColor.red,
          selectedText: 'Same text',
        );
        const marker2 = PdfMarker(
          id: 'same-id',
          pageNumber: 5,
          color: MarkerColor.red,
          selectedText: 'Same text',
        );

        expect(marker1, equals(marker2));
        expect(marker1.hashCode, equals(marker2.hashCode));
      });

      test('two PdfMarkers with different IDs are not equal', () {
        const marker1 = PdfMarker(
          id: 'id-1',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        const marker2 = PdfMarker(
          id: 'id-2',
          pageNumber: 5,
          color: MarkerColor.red,
        );

        expect(marker1, isNot(equals(marker2)));
      });

      test('two PdfMarkers with different pageNumbers are not equal', () {
        const marker1 = PdfMarker(
          id: 'same-id',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        const marker2 = PdfMarker(
          id: 'same-id',
          pageNumber: 6,
          color: MarkerColor.red,
        );

        expect(marker1, isNot(equals(marker2)));
      });

      test('two PdfMarkers with different colors are not equal', () {
        const marker1 = PdfMarker(
          id: 'same-id',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        const marker2 = PdfMarker(
          id: 'same-id',
          pageNumber: 5,
          color: MarkerColor.blue,
        );

        expect(marker1, isNot(equals(marker2)));
      });
    });

    group('copyWith', () {
      test('copyWith updates id', () {
        const original = PdfMarker(
          id: 'old-id',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        final updated = original.copyWith(id: 'new-id');

        expect(updated.id, 'new-id');
        expect(updated.pageNumber, 5);
        expect(updated.color, MarkerColor.red);
      });

      test('copyWith updates pageNumber', () {
        const original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        final updated = original.copyWith(pageNumber: 10);

        expect(updated.id, 'marker-id');
        expect(updated.pageNumber, 10);
        expect(updated.color, MarkerColor.red);
      });

      test('copyWith updates color', () {
        const original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        final updated = original.copyWith(color: MarkerColor.blue);

        expect(updated.id, 'marker-id');
        expect(updated.pageNumber, 5);
        expect(updated.color, MarkerColor.blue);
      });

      test('copyWith adds selectedText', () {
        const original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        final updated = original.copyWith(selectedText: 'New text');

        expect(updated.selectedText, 'New text');
      });

      test('copyWith removes selectedText by setting to null', () {
        const original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
          selectedText: 'Old text',
        );
        final updated = original.copyWith(selectedText: null);

        expect(updated.selectedText, null);
      });

      test('copyWith adds textRect', () {
        const original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        final newRect = PdfRect(10, 70, 110, 20);
        final updated = original.copyWith(textRect: newRect);

        expect(updated.textRect, newRect);
      });

      test('copyWith removes textRect by setting to null', () {
        final original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
          textRect: PdfRect(10, 70, 110, 20),
        );
        final updated = original.copyWith(textRect: null);

        expect(updated.textRect, null);
      });

      test('copyWith updates multiple fields at once', () {
        const original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
        );
        final updated = original.copyWith(
          pageNumber: 10,
          color: MarkerColor.blue,
          selectedText: 'New text',
        );

        expect(updated.id, 'marker-id');
        expect(updated.pageNumber, 10);
        expect(updated.color, MarkerColor.blue);
        expect(updated.selectedText, 'New text');
      });

      test('copyWith with no arguments returns equal object', () {
        const original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
          selectedText: 'Text',
        );
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('real-world scenarios', () {
      test('text selection marker (P3 with red color)', () {
        final marker = PdfMarker(
          id: 'text-selection-1',
          pageNumber: 3,
          color: MarkerColor.red,
          selectedText: 'This is an important passage that needs highlighting.',
          textRect: PdfRect(72, 168, 372, 144),
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized, marker);
        expect(deserialized.pageNumber, 3);
        expect(deserialized.color, MarkerColor.red);
        expect(deserialized.selectedText, isNotNull);
        expect(deserialized.textRect, isNotNull);
        expect(deserialized.capturedImagePath, null);
      });

      test('image capture marker (P5 with yellow color)', () {
        final marker = PdfMarker(
          id: 'image-capture-1',
          pageNumber: 5,
          color: MarkerColor.yellow,
          capturedImagePath: './captures/p5_capture.png',
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized, marker);
        expect(deserialized.pageNumber, 5);
        expect(deserialized.color, MarkerColor.yellow);
        expect(deserialized.capturedImagePath, './captures/p5_capture.png');
        expect(deserialized.selectedText, null);
        expect(deserialized.textRect, null);
      });

      test('combined text and image marker', () {
        final marker = PdfMarker(
          id: 'combined-marker-1',
          pageNumber: 10,
          color: MarkerColor.green,
          selectedText: 'Figure 2.1: Network Architecture',
          textRect: PdfRect(100, 500, 500, 200),
          capturedImagePath: './captures/p10_figure_2_1.png',
        );
        final json = marker.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized, marker);
        expect(deserialized.selectedText, isNotNull);
        expect(deserialized.textRect, isNotNull);
        expect(deserialized.capturedImagePath, isNotNull);
      });

      test('list of markers from different pages', () {
        final markers = [
          PdfMarker(
            id: 'm1',
            pageNumber: 1,
            color: MarkerColor.red,
            selectedText: 'Introduction',
          ),
          PdfMarker(
            id: 'm2',
            pageNumber: 5,
            color: MarkerColor.yellow,
            selectedText: 'Key concept',
          ),
          PdfMarker(
            id: 'm3',
            pageNumber: 10,
            color: MarkerColor.green,
            selectedText: 'Conclusion',
          ),
        ];

        final jsonList = markers.map((m) => m.toJson()).toList();
        final deserialized =
            jsonList.map((j) => PdfMarker.fromJson(j)).toList();

        expect(deserialized.length, 3);
        expect(deserialized[0], markers[0]);
        expect(deserialized[1], markers[1]);
        expect(deserialized[2], markers[2]);
      });
    });
  });
}
