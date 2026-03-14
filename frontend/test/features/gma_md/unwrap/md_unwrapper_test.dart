import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/gma_md/unwrap/md_unwrapper.dart';

void main() {
  group('MdUnwrapper', () {
    test('unwraps concept block', () {
      final result = MdUnwrapper.unwrap(
        '::: concept 미분의 정의\n내용\n:::',
      );
      expect(result, '## 미분의 정의\n\n내용');
    });

    test('unwraps theorem block', () {
      final result = MdUnwrapper.unwrap(
        '::: theorem 중간값 정리\n내용\n:::',
      );
      expect(result, '## 정리: 중간값 정리\n\n내용');
    });

    test('unwraps proof block with QED', () {
      final result = MdUnwrapper.unwrap(
        '::: proof 증명\n증명 과정\n:::',
      );
      expect(result, contains('## 증명: 증명'));
      expect(result, contains('증명 과정'));
      expect(result, contains('\u25A1')); // □
    });

    test('unwraps example block', () {
      final result = MdUnwrapper.unwrap(
        '::: example 예제1\n예제 내용\n:::',
      );
      expect(result, '## 예제: 예제1\n\n예제 내용');
    });

    test('unwraps summary to blockquote', () {
      final result = MdUnwrapper.unwrap(
        '::: summary 요약\nLine1\nLine2\n:::',
      );
      expect(result, contains('> **요약**'));
      expect(result, contains('> Line1'));
    });

    test('unwraps callout to blockquote', () {
      final result = MdUnwrapper.unwrap(
        '::: warning 주의\n내용\n:::',
      );
      expect(result, contains('> **[Warning]** 주의'));
    });

    test('unwraps timeline to bullet list', () {
      final result = MdUnwrapper.unwrap(
        '::: timeline 역사\n1950 | 사건1\n1960 | 사건2\n:::',
      );
      expect(result, contains('## 역사'));
      expect(result, contains('- 1950: 사건1'));
      expect(result, contains('- 1960: 사건2'));
    });

    test('unwraps mindmap to indented bullet list', () {
      final result = MdUnwrapper.unwrap(
        '::: mindmap 주제\n주제\n  가지1\n    세부1\n:::',
      );
      expect(result, contains('## 주제'));
      expect(result, contains('- 주제'));
      expect(result, contains('  - 가지1'));
      expect(result, contains('    - 세부1'));
    });

    test('unwraps compare to table', () {
      final result = MdUnwrapper.unwrap(
        '::: compare A vs B\nLeft content\n---\nRight content\n:::',
      );
      expect(result, contains('## A vs B'));
      expect(result, contains('| Left | Right |'));
      expect(result, contains('Left content'));
      expect(result, contains('Right content'));
    });

    test('unwraps flow to bullet list', () {
      final result = MdUnwrapper.unwrap(
        '::: flow\nA --> B\nB --> C\n:::',
      );
      expect(result, contains('- A'));
      expect(result, contains('- B'));
      expect(result, contains('- C'));
    });

    test('unwraps graph to bullet list', () {
      final result = MdUnwrapper.unwrap(
        '::: graph\nA -- rel --> B\n:::',
      );
      expect(result, contains('- A -- rel --> B'));
    });

    test('preserves non-block content', () {
      final result = MdUnwrapper.unwrap('# Title\n\nParagraph');
      expect(result, '# Title\n\nParagraph');
    });

    test('handles mixed content', () {
      final result = MdUnwrapper.unwrap(
        '# Title\n\n::: note\nNote content\n:::\n\nMore text',
      );
      expect(result, contains('# Title'));
      expect(result, contains('> **[Note]**'));
      expect(result, contains('More text'));
    });

    test('strips metadata from opening line', () {
      final result = MdUnwrapper.unwrap(
        '::: concept Title {source: "p.42"}\nContent\n:::',
      );
      expect(result, '## Title\n\nContent');
      expect(result, isNot(contains('source')));
      expect(result, isNot(contains('p.42')));
    });
  });
}
