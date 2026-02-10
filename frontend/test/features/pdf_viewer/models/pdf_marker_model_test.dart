import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/pdf_viewer/models/pdf_marker_model.dart';

void main() {
  group('PdfRect', () {
    group('serialization', () {
      test('toJson creates valid JSON with all fields', () {
        const rect = PdfRect(x: 10.5, y: 20.3, width: 100.0, height: 50.0);
        final json = rect.toJson();

        expect(json, {
          'x': 10.5,
          'y': 20.3,
          'width': 100.0,
          'height': 50.0,
        });
      });

      test('fromJson creates valid PdfRect from JSON', () {
        final json = {
          'x': 15.7,
          'y': 25.9,
          'width': 120.5,
          'height': 60.2,
        };
        final rect = PdfRect.fromJson(json);

        expect(rect.x, 15.7);
        expect(rect.y, 25.9);
        expect(rect.width, 120.5);
        expect(rect.height, 60.2);
      });

      test('roundtrip serialization maintains data integrity', () {
        const original = PdfRect(x: 5.5, y: 10.5, width: 200.0, height: 100.0);
        final json = original.toJson();
        final deserialized = PdfRect.fromJson(json);

        expect(deserialized, original);
      });

      test('handles zero values correctly', () {
        const rect = PdfRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0);
        final json = rect.toJson();
        final deserialized = PdfRect.fromJson(json);

        expect(deserialized, rect);
        expect(deserialized.x, 0.0);
        expect(deserialized.y, 0.0);
        expect(deserialized.width, 0.0);
        expect(deserialized.height, 0.0);
      });

      test('handles negative values correctly', () {
        const rect = PdfRect(x: -10.5, y: -20.3, width: 100.0, height: 50.0);
        final json = rect.toJson();
        final deserialized = PdfRect.fromJson(json);

        expect(deserialized, rect);
        expect(deserialized.x, -10.5);
        expect(deserialized.y, -20.3);
      });

      test('handles very large values correctly', () {
        const rect = PdfRect(
          x: 999999.999,
          y: 888888.888,
          width: 777777.777,
          height: 666666.666,
        );
        final json = rect.toJson();
        final deserialized = PdfRect.fromJson(json);

        expect(deserialized, rect);
      });
    });

    group('equality', () {
      test('two PdfRects with same values are equal', () {
        const rect1 = PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0);
        const rect2 = PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0);

        expect(rect1, equals(rect2));
        expect(rect1.hashCode, equals(rect2.hashCode));
      });

      test('two PdfRects with different values are not equal', () {
        const rect1 = PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0);
        const rect2 = PdfRect(x: 11.0, y: 20.0, width: 100.0, height: 50.0);

        expect(rect1, isNot(equals(rect2)));
      });
    });

    group('copyWith', () {
      test('copyWith updates specified fields', () {
        const original = PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0);
        final updated = original.copyWith(x: 15.0, height: 60.0);

        expect(updated.x, 15.0);
        expect(updated.y, 20.0);
        expect(updated.width, 100.0);
        expect(updated.height, 60.0);
      });

      test('copyWith with no arguments returns equal object', () {
        const original = PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0);
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });
  });

  group('PdfMarker', () {
    group('serialization with all fields', () {
      test('toJson creates valid JSON with all fields including optionals', () {
        const marker = PdfMarker(
          id: 'marker-123',
          pageNumber: 5,
          color: MarkerColor.red,
          selectedText: 'Selected text content',
          textRect: PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0),
          capturedImagePath: './captures/p5_capture.png',
        );
        final json = marker.toJson();

        expect(json['id'], 'marker-123');
        expect(json['pageNumber'], 5);
        expect(json['color'], 'red');
        expect(json['selectedText'], 'Selected text content');
        expect(json['textRect'], isA<Map<String, dynamic>>());
        expect(json['textRect']['x'], 10.0);
        expect(json['capturedImagePath'], './captures/p5_capture.png');
      });

      test('fromJson creates valid PdfMarker with all fields', () {
        final json = {
          'id': 'marker-456',
          'pageNumber': 10,
          'color': 'yellow',
          'selectedText': 'Important note',
          'textRect': {
            'x': 15.0,
            'y': 25.0,
            'width': 120.0,
            'height': 60.0,
          },
          'capturedImagePath': './captures/p10_capture.png',
        };
        final marker = PdfMarker.fromJson(json);

        expect(marker.id, 'marker-456');
        expect(marker.pageNumber, 10);
        expect(marker.color, MarkerColor.yellow);
        expect(marker.selectedText, 'Important note');
        expect(marker.textRect, isNotNull);
        expect(marker.textRect!.x, 15.0);
        expect(marker.capturedImagePath, './captures/p10_capture.png');
      });

      test('roundtrip serialization with all fields maintains data integrity',
          () {
        const original = PdfMarker(
          id: 'marker-789',
          pageNumber: 15,
          color: MarkerColor.green,
          selectedText: 'Key insight',
          textRect: PdfRect(x: 20.0, y: 30.0, width: 150.0, height: 75.0),
          capturedImagePath: './captures/p15_capture.png',
        );
        final json = original.toJson();
        final deserialized = PdfMarker.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('serialization with minimal required fields', () {
      test('toJson creates valid JSON with only required fields', () {
        const marker = PdfMarker(
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
          const PdfMarker(
              id: 'red-marker', pageNumber: 1, color: MarkerColor.red),
          const PdfMarker(
              id: 'yellow-marker', pageNumber: 2, color: MarkerColor.yellow),
          const PdfMarker(
              id: 'green-marker', pageNumber: 3, color: MarkerColor.green),
          const PdfMarker(
              id: 'blue-marker', pageNumber: 4, color: MarkerColor.blue),
          const PdfMarker(
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
        const marker = PdfMarker(
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
        const marker = PdfMarker(
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
        const marker = PdfMarker(
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
        const marker = PdfMarker(
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
        const marker = PdfMarker(
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
        const marker = PdfMarker(
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
        const newRect = PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0);
        final updated = original.copyWith(textRect: newRect);

        expect(updated.textRect, newRect);
      });

      test('copyWith removes textRect by setting to null', () {
        const original = PdfMarker(
          id: 'marker-id',
          pageNumber: 5,
          color: MarkerColor.red,
          textRect: PdfRect(x: 10.0, y: 20.0, width: 100.0, height: 50.0),
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
        const marker = PdfMarker(
          id: 'text-selection-1',
          pageNumber: 3,
          color: MarkerColor.red,
          selectedText: 'This is an important passage that needs highlighting.',
          textRect: PdfRect(x: 72.0, y: 144.0, width: 300.0, height: 24.0),
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
        const marker = PdfMarker(
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
        const marker = PdfMarker(
          id: 'combined-marker-1',
          pageNumber: 10,
          color: MarkerColor.green,
          selectedText: 'Figure 2.1: Network Architecture',
          textRect: PdfRect(x: 100.0, y: 200.0, width: 400.0, height: 300.0),
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
        const markers = [
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
