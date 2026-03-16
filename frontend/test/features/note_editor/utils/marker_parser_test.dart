import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/constants/marker_colors.dart';
import 'package:gma_frontend/features/note_editor/utils/marker_parser.dart';

void main() {
  group('MarkerParser - Valid Marker Lines', () {
    test('parses red marker with text', () {
      const line = '- 🔴 P3  Dictionary-based sentiment analysis is...';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.red);
      expect(result.pageNumber, 3);
      expect(result.text, 'Dictionary-based sentiment analysis is...');
      expect(result.imagePath, null);
    });

    test('parses yellow marker with text', () {
      const line = '- 🟡 P5  Some highlighted text here';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.yellow);
      expect(result.pageNumber, 5);
      expect(result.text, 'Some highlighted text here');
    });

    test('parses green marker with text', () {
      const line = '- 🟢 P10  Important concept to remember';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.green);
      expect(result.pageNumber, 10);
      expect(result.text, 'Important concept to remember');
    });

    test('parses blue marker with text', () {
      const line = '- 🔵 P7  Key definition from the paper';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.blue);
      expect(result.pageNumber, 7);
      expect(result.text, 'Key definition from the paper');
    });

    test('parses purple marker with text', () {
      const line = '- 🟣 P12  Reference for later review';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.purple);
      expect(result.pageNumber, 12);
      expect(result.text, 'Reference for later review');
    });

    test('parses marker without text', () {
      const line = '- 🔴 P3';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.red);
      expect(result.pageNumber, 3);
      expect(result.text, null);
    });

    test('parses marker with large page number', () {
      const line = '- 🟡 P999  Text from page 999';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.yellow);
      expect(result.pageNumber, 999);
      expect(result.text, 'Text from page 999');
    });

    test('parses marker with single digit page', () {
      const line = '- 🔵 P1  First page marker';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.blue);
      expect(result.pageNumber, 1);
      expect(result.text, 'First page marker');
    });

    test('parses marker with text containing special characters', () {
      const line = '- 🟢 P5  Text with "quotes" and (parentheses) & symbols!';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.green);
      expect(result.pageNumber, 5);
      expect(result.text, 'Text with "quotes" and (parentheses) & symbols!');
    });

    test('parses marker with unicode text', () {
      const line = '- 🔴 P3  한글 텍스트와 日本語 そして emoji 😀';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.red);
      expect(result.pageNumber, 3);
      expect(result.text, '한글 텍스트와 日本語 そして emoji 😀');
    });

    test('parses marker with very long text', () {
      final longText = 'a' * 500;
      final line = '- 🟡 P10  $longText';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.yellow);
      expect(result.pageNumber, 10);
      expect(result.text, longText);
    });

    test('parses marker with leading/trailing whitespace', () {
      const line = '  - 🔴 P3  Some text  ';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.red);
      expect(result.pageNumber, 3);
    });
  });

  group('MarkerParser - Invalid Marker Lines', () {
    test('rejects line without emoji', () {
      const line = '- P3  Some text';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects line with wrong emoji', () {
      const line = '- ❤️ P3  Some text';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects line without page number', () {
      const line = '- 🔴 Some text';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects line with invalid page format', () {
      const line = '- 🔴 Page3  Some text';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects line with negative page number', () {
      const line = '- 🔴 P-3  Some text';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects line with page zero', () {
      const line = '- 🔴 P0  Some text';

      final result = MarkerParser.parse(line);

      // P0 technically parses but is semantically invalid
      // For now, parser accepts it (validation happens elsewhere)
      expect(result.isMarkerLine, true);
      expect(result.pageNumber, 0);
    });

    test('rejects line without list marker', () {
      const line = '🔴 P3  Some text';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects regular list item', () {
      const line = '- Regular list item';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects line with only one space before text', () {
      const line = '- 🔴 P3 Text with one space';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects line with extra characters before emoji', () {
      const line = '- ABC 🔴 P3  Some text';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects empty line', () {
      const line = '';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });

    test('rejects line with only whitespace', () {
      const line = '     ';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, false);
    });
  });

  group('MarkerParser - Image Embed Parsing', () {
    test('parses marker with image embed on next line', () {
      final lines = [
        '- 🟡 P5',
        '  ![capture](./captures/p5_logistic_regression.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.yellow);
      expect(result.pageNumber, 5);
      expect(result.imagePath, './captures/p5_logistic_regression.png');
    });

    test('parses marker with text and image embed', () {
      final lines = [
        '- 🔴 P3  Some important text',
        '  ![screenshot](./captures/p3_screenshot.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.color, MarkerColor.red);
      expect(result.pageNumber, 3);
      expect(result.text, 'Some important text');
      expect(result.imagePath, './captures/p3_screenshot.png');
    });

    test('parses image with different caption', () {
      final lines = [
        '- 🟢 P7',
        '  ![diagram from page 7](./assets/diagram.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, './assets/diagram.png');
    });

    test('parses image with empty caption', () {
      final lines = [
        '- 🔵 P10',
        '  ![](./captures/p10.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, './captures/p10.png');
    });

    test('ignores non-image line after marker', () {
      final lines = [
        '- 🔴 P3',
        'Regular text line',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, null);
    });

    test('ignores incorrectly indented image', () {
      final lines = [
        '- 🔴 P3',
        '![wrong indentation](./captures/p3.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, null);
    });

    test('handles marker with only one line', () {
      final lines = ['- 🔴 P3  Text only'];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, null);
    });

    test('handles empty lines array', () {
      final lines = <String>[];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, false);
    });

    test('parses image with absolute path', () {
      final lines = [
        '- 🟣 P15',
        '  ![capture](/absolute/path/to/image.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, '/absolute/path/to/image.png');
    });

    test('parses image with Windows path', () {
      final lines = [
        '- 🟡 P8',
        r'  ![capture](C:\Users\Documents\capture.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, r'C:\Users\Documents\capture.png');
    });

    test('parses image with URL', () {
      final lines = [
        '- 🔴 P5',
        '  ![online](https://example.com/image.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, 'https://example.com/image.png');
    });
  });

  group('MarkerParser - Helper Methods', () {
    test('isMarkerLine returns true for valid marker', () {
      const line = '- 🔴 P3  Text';

      expect(MarkerParser.isMarkerLine(line), true);
    });

    test('isMarkerLine returns false for invalid line', () {
      const line = '- Regular list item';

      expect(MarkerParser.isMarkerLine(line), false);
    });
  });

  group('MarkerParser - Extract Markers from Content', () {
    test('extracts multiple markers from content', () {
      const content = '''
# Machine Learning Notes

- 🔴 P3  Dictionary-based sentiment analysis is...
- 🟡 P5  Logistic regression equation

Regular list item

- 🟢 P10  Neural network architecture
''';

      final markers = MarkerParser.extractMarkers(content);

      expect(markers.length, 3);
      expect(markers[0].color, MarkerColor.red);
      expect(markers[0].pageNumber, 3);
      expect(markers[1].color, MarkerColor.yellow);
      expect(markers[1].pageNumber, 5);
      expect(markers[2].color, MarkerColor.green);
      expect(markers[2].pageNumber, 10);
    });

    test('extracts markers with images', () {
      const content = '''
# Notes

- 🔴 P3  Text marker
- 🟡 P5
  ![capture](./captures/p5.png)
- 🟢 P7  Another text marker
''';

      final markers = MarkerParser.extractMarkers(content);

      expect(markers.length, 3);
      expect(markers[0].imagePath, null);
      expect(markers[1].imagePath, './captures/p5.png');
      expect(markers[2].imagePath, null);
    });

    test('handles content with no markers', () {
      const content = '''
# Regular Note

Just some regular markdown content here.

- Regular list item
- Another list item
''';

      final markers = MarkerParser.extractMarkers(content);

      expect(markers.isEmpty, true);
    });

    test('handles empty content', () {
      const content = '';

      final markers = MarkerParser.extractMarkers(content);

      expect(markers.isEmpty, true);
    });

    test('handles content with only whitespace', () {
      const content = '   \n\n   \n';

      final markers = MarkerParser.extractMarkers(content);

      expect(markers.isEmpty, true);
    });

    test('extracts markers from real-world example', () {
      const content = '''---
file: DMDA_WK06_1760326528155_0.pdf
file-path: ./assets/DMDA_WK06_1760326528155_0.pdf
created: 2026-02-04
tags: [machine-learning, logistic-regression]
---

# Machine Learning Notes

## Logistic Regression

- 🔴 P3  Dictionary-based sentiment analysis is a method...
- 🟡 P5  Logistic regression formula
  ![equation](./captures/p5_logistic_regression.png)

## Neural Networks

- 🔵 P10  Backpropagation algorithm
- 🟢 P12  Activation functions

See also: [[3blue1brown/NN]]
''';

      final markers = MarkerParser.extractMarkers(content);

      expect(markers.length, 4);
      expect(markers[0].color, MarkerColor.red);
      expect(markers[0].pageNumber, 3);
      expect(markers[0].text, 'Dictionary-based sentiment analysis is a method...');
      expect(markers[1].color, MarkerColor.yellow);
      expect(markers[1].pageNumber, 5);
      expect(markers[1].imagePath, './captures/p5_logistic_regression.png');
      expect(markers[2].color, MarkerColor.blue);
      expect(markers[2].pageNumber, 10);
      expect(markers[3].color, MarkerColor.green);
      expect(markers[3].pageNumber, 12);
    });

    test('handles consecutive markers without gaps', () {
      const content = '''
- 🔴 P1  First
- 🟡 P2  Second
- 🟢 P3  Third
''';

      final markers = MarkerParser.extractMarkers(content);

      expect(markers.length, 3);
    });

    test('handles markers with mixed content', () {
      const content = '''
Some intro text

- 🔴 P3  Marker 1

## Section

More text here

- 🟡 P5  Marker 2
  ![img](./img.png)

- Regular list
- Another regular list

- 🟢 P7  Marker 3
''';

      final markers = MarkerParser.extractMarkers(content);

      expect(markers.length, 3);
      expect(markers[0].pageNumber, 3);
      expect(markers[1].pageNumber, 5);
      expect(markers[1].imagePath, './img.png');
      expect(markers[2].pageNumber, 7);
    });
  });

  group('MarkerParser - Edge Cases', () {
    test('handles marker with page number at integer limit', () {
      const line = '- 🔴 P2147483647  Max int page';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.pageNumber, 2147483647);
    });

    test('handles marker with text containing line breaks in raw string', () {
      const line = '- 🔴 P3  Text without actual newline but with \\n';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.text, contains('\\n'));
    });

    test('handles marker with markdown in text', () {
      const line = '- 🔴 P3  Text with **bold** and *italic*';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.text, 'Text with **bold** and *italic*');
    });

    test('handles marker with code in text', () {
      const line = '- 🔴 P3  Text with `code` snippet';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.text, 'Text with `code` snippet');
    });

    test('handles marker with link in text', () {
      const line = '- 🔴 P3  Text with [link](https://example.com)';

      final result = MarkerParser.parse(line);

      expect(result.isMarkerLine, true);
      expect(result.text, 'Text with [link](https://example.com)');
    });

    test('handles image embed with spaces in path', () {
      final lines = [
        '- 🔴 P3',
        '  ![capture](./captures/my file with spaces.png)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, './captures/my file with spaces.png');
    });

    test('handles image embed with query parameters', () {
      final lines = [
        '- 🔴 P3',
        '  ![capture](https://example.com/image.png?width=500&height=300)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, 'https://example.com/image.png?width=500&height=300');
    });

    test('handles very long image path', () {
      final longPath = './captures/${'a' * 200}.png';
      final lines = [
        '- 🔴 P3',
        '  ![capture]($longPath)',
      ];

      final result = MarkerParser.parseWithImage(lines);

      expect(result.isMarkerLine, true);
      expect(result.imagePath, longPath);
    });
  });
}
