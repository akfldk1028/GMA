import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/gma_md/parser/timeline_parser.dart';

void main() {
  group('TimelineParser', () {
    test('parses basic events', () {
      final events = TimelineParser.parse(
        '1950.06.25 | 한국전쟁 발발\n1953.07.27 | 정전협정 체결',
      );
      expect(events, hasLength(2));
      expect(events[0].date, '1950.06.25');
      expect(events[0].description, '한국전쟁 발발');
      expect(events[1].date, '1953.07.27');
      expect(events[1].description, '정전협정 체결');
    });

    test('skips empty lines', () {
      final events = TimelineParser.parse(
        '2024.01 | Event 1\n\n2024.06 | Event 2\n',
      );
      expect(events, hasLength(2));
    });

    test('skips lines without pipe', () {
      final events = TimelineParser.parse(
        '2024.01 | Valid\nNo pipe here\n2024.06 | Also valid',
      );
      expect(events, hasLength(2));
    });

    test('returns empty for empty content', () {
      expect(TimelineParser.parse(''), isEmpty);
    });

    test('trims whitespace around date and description', () {
      final events = TimelineParser.parse('  2024  |  Description  ');
      expect(events, hasLength(1));
      expect(events[0].date, '2024');
      expect(events[0].description, 'Description');
    });

    test('skips if date or description is empty', () {
      final events = TimelineParser.parse('| no date\nno desc |');
      expect(events, isEmpty);
    });
  });
}
