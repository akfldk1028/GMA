import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/services/block_extractor.dart';

/// Edge case tests for BlockExtractor.
void main() {
  group('BlockExtractor edge cases', () {
    test('handles nested ::: inside code block gracefully', () {
      // A code block containing ::: should not confuse the extractor
      const text = '''Here is some text.

::: flow Test
(A) --> (B)
:::

Done.''';
      final result = BlockExtractor.extract(text);
      expect(result, contains('::: flow'));
      expect(result, isNot(contains('Done.')));
    });

    test('handles empty block (no content between fences)', () {
      const text = '::: concept Empty\n:::';
      expect(BlockExtractor.hasBlock(text), isTrue);
      final result = BlockExtractor.extract(text);
      expect(result, contains('::: concept'));
    });

    test('handles block with only whitespace content', () {
      const text = '::: summary Title\n  \n  \n:::';
      expect(BlockExtractor.hasBlock(text), isTrue);
    });

    test('handles multiple blocks of different types', () {
      const text = '''::: concept 정의
설명
:::

::: flow 순서
A --> B
:::

::: summary 요약
내용
:::''';
      final result = BlockExtractor.extract(text);
      expect(result, contains('::: concept'));
      expect(result, contains('::: flow'));
      expect(result, contains('::: summary'));
    });

    test('handles block with Korean title and content', () {
      const text = '::: concept 미분의 정의\n함수의 순간변화율을 구하는 것\n:::';
      expect(BlockExtractor.hasBlock(text), isTrue);
      final result = BlockExtractor.extract(text);
      expect(result, contains('미분의 정의'));
      expect(result, contains('순간변화율'));
    });

    test('handles LLM chatty prefix before block', () {
      const text = '''네, 플로우차트로 정리해드리겠습니다.

::: flow 방법론
(시작) --> 데이터 수집
데이터 수집 --> 전처리
전처리 --> (끝)
:::

위와 같은 플로우차트입니다.''';
      final result = BlockExtractor.extract(text);
      expect(result, startsWith('::: flow'));
      expect(result, endsWith(':::'));
      expect(result, isNot(contains('정리해드리겠습니다')));
      expect(result, isNot(contains('위와 같은')));
    });

    test('handles trailing whitespace after closing :::', () {
      const text = '::: flow Test\n(A) --> (B)\n:::   \n';
      expect(BlockExtractor.hasBlock(text), isTrue);
      final result = BlockExtractor.extract(text);
      expect(result, endsWith(':::'));
    });

    test('returns original when ::: appears but not as block', () {
      const text = '참고: ::: 는 블록 구분자입니다.';
      expect(BlockExtractor.hasBlock(text), isFalse);
      expect(BlockExtractor.extract(text), text);
    });
  });
}
