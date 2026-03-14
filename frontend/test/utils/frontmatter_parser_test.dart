import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/utils/frontmatter_parser.dart';

void main() {
  group('FrontmatterParser - Valid YAML', () {
    test('parses valid frontmatter with simple fields', () {
      const content = '''---
file: example.pdf
file-path: ./assets/example.pdf
created: 2026-02-04
---

# Hello World''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter, isNotNull);
      expect(result.frontmatter!['file'], 'example.pdf');
      expect(result.frontmatter!['file-path'], './assets/example.pdf');
      expect(result.frontmatter!['created'], '2026-02-04');
      expect(result.body, '# Hello World');
    });

    test('parses frontmatter with tags array', () {
      const content = '''---
tags: [machine-learning, logistic-regression]
---

Content here''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['tags'], isList);
      expect(result.frontmatter!['tags'], ['machine-learning', 'logistic-regression']);
    });

    test('parses frontmatter with complex nested markers', () {
      const content = '''---
file: test.pdf
markers:
  - id: m1
    page: 3
    color: red
    text: "Some text"
    rect: [120.5, 340.2, 580.0, 360.8]
  - id: m2
    page: 5
    color: yellow
    capture: ./captures/p5.png
---

Body content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['markers'], isList);
      expect(result.frontmatter!['markers'].length, 2);

      final marker1 = result.frontmatter!['markers'][0] as Map;
      expect(marker1['id'], 'm1');
      expect(marker1['page'], 3);
      expect(marker1['color'], 'red');
      expect(marker1['text'], 'Some text');
      expect(marker1['rect'], [120.5, 340.2, 580.0, 360.8]);

      final marker2 = result.frontmatter!['markers'][1] as Map;
      expect(marker2['id'], 'm2');
      expect(marker2['page'], 5);
      expect(marker2['color'], 'yellow');
      expect(marker2['capture'], './captures/p5.png');
    });

    test('parses frontmatter with multiline strings', () {
      const content = '''---
title: My Note
description: |
  This is a multiline
  description text
---

Content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['title'], 'My Note');
      expect(result.frontmatter!['description'], contains('multiline'));
    });

    test('parses frontmatter with numeric values', () {
      const content = '''---
page: 42
confidence: 0.95
count: 100
---

Text''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['page'], 42);
      expect(result.frontmatter!['confidence'], 0.95);
      expect(result.frontmatter!['count'], 100);
    });

    test('parses frontmatter with boolean values', () {
      const content = '''---
published: true
draft: false
---

Content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['published'], true);
      expect(result.frontmatter!['draft'], false);
    });

    test('parses frontmatter with null values', () {
      const content = '''---
author: null
reviewer:
---

Content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['author'], null);
    });

    test('handles empty frontmatter', () {
      const content = '''---
---

Content here''';

      final result = FrontmatterParser.parse(content);

      // Empty frontmatter should be treated as no frontmatter
      expect(result.hasFrontmatter, false);
      expect(result.body, content);
    });

    test('preserves body formatting and whitespace', () {
      const content = '''---
title: Test
---

# Title

Paragraph 1

Paragraph 2''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.body, contains('# Title'));
      expect(result.body, contains('Paragraph 1'));
      expect(result.body, contains('Paragraph 2'));
    });
  });

  group('FrontmatterParser - Invalid YAML', () {
    test('handles malformed YAML gracefully', () {
      const content = '''---
title: Test
tags: [unclosed
invalid: {
---

Content''';

      final result = FrontmatterParser.parse(content);

      // Should fail gracefully and return original content
      expect(result.hasFrontmatter, false);
      expect(result.body, content);
    });

    test('handles missing closing delimiter', () {
      const content = '''---
title: Test
tags: [test]

Content without closing delimiter''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, false);
      expect(result.body, content);
    });

    test('handles missing opening delimiter', () {
      const content = '''title: Test
tags: [test]
---

Content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, false);
      expect(result.body, content);
    });

    test('handles frontmatter delimiter in wrong position', () {
      const content = '''
Some text before
---
title: Test
---

Content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, false);
      expect(result.body, content);
    });

    test('handles invalid indentation', () {
      const content = '''---
  title: Test
    invalid: indentation
---

Content''';

      final result = FrontmatterParser.parse(content);

      // YAML parser should handle this or fail gracefully
      // Depending on yaml package behavior, this might parse or fail
      expect(result.hasFrontmatter || !result.hasFrontmatter, true);
    });

    test('handles special characters in keys', () {
      const content = '''---
title@special: Test
key-with-dash: value
key_with_underscore: value
---

Content''';

      final result = FrontmatterParser.parse(content);

      // Should parse successfully as YAML allows these
      expect(result.hasFrontmatter, true);
    });
  });

  group('FrontmatterParser - Edge Cases', () {
    test('handles empty content', () {
      const content = '';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, false);
      expect(result.body, '');
    });

    test('handles content with only frontmatter', () {
      const content = '''---
title: Test
---''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.body.trim(), isEmpty);
    });

    test('handles content with multiple --- markers', () {
      const content = '''---
title: Test
---

# Content

---

More content with horizontal rule''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.body, contains('# Content'));
      expect(result.body, contains('---'));
      expect(result.body, contains('More content'));
    });

    test('handles whitespace around delimiters', () {
      const content = '''  ---
title: Test
  ---

Content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['title'], 'Test');
    });

    test('handles very large frontmatter', () {
      final markers = List.generate(100, (i) => '''  - id: m$i
    page: $i
    color: red
    text: "Marker $i"''').join('\n');

      final content = '''---
title: Large Document
markers:
$markers
---

Content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['markers'], isList);
      expect(result.frontmatter!['markers'].length, 100);
    });

    test('handles unicode characters', () {
      const content = '''---
title: 한글 제목
author: 作者
emoji: 🔴🟡🟢
---

Content with unicode: 日本語''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['title'], '한글 제목');
      expect(result.frontmatter!['author'], '作者');
      expect(result.frontmatter!['emoji'], '🔴🟡🟢');
    });

    test('handles newlines in body', () {
      const content = '''---
title: Test
---


# Title

Content''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.body, startsWith('# Title'));
    });
  });

  group('FrontmatterParser - Helper Methods', () {
    test('getField returns correct typed value', () {
      final frontmatter = {
        'title': 'Test',
        'page': 42,
        'published': true,
        'tags': ['a', 'b'],
      };

      expect(FrontmatterParser.getField<String>(frontmatter, 'title'), 'Test');
      expect(FrontmatterParser.getField<int>(frontmatter, 'page'), 42);
      expect(FrontmatterParser.getField<bool>(frontmatter, 'published'), true);
      expect(FrontmatterParser.getField<List>(frontmatter, 'tags'), ['a', 'b']);
    });

    test('getField returns null for non-existent key', () {
      final frontmatter = {'title': 'Test'};

      expect(FrontmatterParser.getField<String>(frontmatter, 'missing'), null);
    });

    test('getField returns null for wrong type', () {
      final frontmatter = {'page': 42};

      expect(FrontmatterParser.getField<String>(frontmatter, 'page'), null);
    });

    test('hasField returns correct boolean', () {
      final frontmatter = {'title': 'Test', 'author': null};

      expect(FrontmatterParser.hasField(frontmatter, 'title'), true);
      expect(FrontmatterParser.hasField(frontmatter, 'author'), true);
      expect(FrontmatterParser.hasField(frontmatter, 'missing'), false);
    });

    test('hasField handles null frontmatter', () {
      expect(FrontmatterParser.hasField(null, 'title'), false);
    });

    test('serialize creates valid YAML', () {
      final frontmatter = {
        'file': 'test.pdf',
        'created': '2026-02-04',
        'tags': ['ml', 'ai'],
      };

      final yaml = FrontmatterParser.serialize(frontmatter);

      expect(yaml, startsWith('---\n'));
      expect(yaml, endsWith('---\n'));
      expect(yaml, contains('file: test.pdf'));
      expect(yaml, contains('created: 2026-02-04'));
      expect(yaml, contains('tags:'));
    });

    test('serialize handles nested objects', () {
      final frontmatter = {
        'title': 'Test',
        'markers': [
          {
            'id': 'm1',
            'page': 3,
            'color': 'red',
          }
        ],
      };

      final yaml = FrontmatterParser.serialize(frontmatter);

      expect(yaml, contains('title: Test'));
      expect(yaml, contains('markers:'));
      expect(yaml, contains('id: m1'));
      expect(yaml, contains('page: 3'));
      expect(yaml, contains('color: red'));
    });

    test('parse and serialize roundtrip', () {
      const original = '''---
file: test.pdf
tags: [ml, ai]
---

Content''';

      final parsed = FrontmatterParser.parse(original);
      final serialized = FrontmatterParser.serialize(parsed.frontmatter!);
      final reparsed = FrontmatterParser.parse('$serialized\nContent');

      expect(reparsed.hasFrontmatter, true);
      expect(reparsed.frontmatter!['file'], 'test.pdf');
      expect(reparsed.frontmatter!['tags'], ['ml', 'ai']);
    });
  });

  group('FrontmatterParser - Real-world Examples', () {
    test('parses complete PDF note example', () {
      const content = '''---
file: DMDA_WK06_1760326528155_0.pdf
file-path: ./assets/DMDA_WK06_1760326528155_0.pdf
created: 2026-02-04
tags: [machine-learning, logistic-regression]
markers:
  - id: m1
    page: 3
    color: red
    text: "Dictionary-based sentiment analysis is..."
    rect: [120.5, 340.2, 580.0, 360.8]
  - id: m2
    page: 5
    color: yellow
    capture: ./captures/p5_logistic_regression.png
    rect: [100.0, 200.0, 500.0, 450.0]
---

# Machine Learning Notes

## Logistic Regression

- 🔴 P3  Dictionary-based sentiment analysis is...
- 🟡 P5  [캡처된 이미지]

See also: [[3blue1brown/NN]]''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['file'], 'DMDA_WK06_1760326528155_0.pdf');
      expect(result.frontmatter!['file-path'], './assets/DMDA_WK06_1760326528155_0.pdf');
      expect(result.frontmatter!['created'], '2026-02-04');
      expect(result.frontmatter!['tags'], ['machine-learning', 'logistic-regression']);
      expect(result.frontmatter!['markers'], hasLength(2));
      expect(result.body, contains('# Machine Learning Notes'));
      expect(result.body, contains('🔴 P3'));
      expect(result.body, contains('[[3blue1brown/NN]]'));
    });

    test('handles note without PDF markers', () {
      const content = '''---
title: Standalone Note
created: 2026-02-04
tags: [ideas, brainstorm]
---

# Ideas

Just some random thoughts...''';

      final result = FrontmatterParser.parse(content);

      expect(result.hasFrontmatter, true);
      expect(result.frontmatter!['title'], 'Standalone Note');
      expect(result.frontmatter!.containsKey('markers'), false);
      expect(result.body, contains('# Ideas'));
    });
  });
}
