import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/services/block_extractor.dart';

void main() {
  group('BlockExtractor.hasBlock', () {
    test('detects flow block', () {
      const text = '::: flow 테스트\n(시작) --> 끝\n:::';
      expect(BlockExtractor.hasBlock(text), isTrue);
    });

    test('detects mindmap block', () {
      const text = '::: mindmap 주제\n루트\n  자식1\n:::';
      expect(BlockExtractor.hasBlock(text), isTrue);
    });

    test('returns false for plain text', () {
      expect(BlockExtractor.hasBlock('그냥 텍스트입니다.'), isFalse);
    });

    test('returns false for incomplete block', () {
      expect(BlockExtractor.hasBlock('::: flow 미완성'), isFalse);
    });
  });

  group('BlockExtractor.extract', () {
    test('extracts single block from mixed text', () {
      const text = '''여기에 설명이 있고요.

::: flow 방법론
(시작) --> 전처리
전처리 --> 학습
학습 --> (끝)
:::

이런 결과가 나왔습니다.''';

      final result = BlockExtractor.extract(text);
      expect(result, startsWith('::: flow'));
      expect(result, endsWith(':::'));
      expect(result, isNot(contains('여기에 설명')));
      expect(result, isNot(contains('결과가 나왔습니다')));
    });

    test('extracts multiple blocks', () {
      const text = '''::: concept 정의
내용
:::

::: example 예시
예시 내용
:::''';

      final result = BlockExtractor.extract(text);
      expect(result, contains('::: concept'));
      expect(result, contains('::: example'));
    });

    test('returns original text when no block found', () {
      const text = '블록이 없는 텍스트';
      expect(BlockExtractor.extract(text), text);
    });

    test('handles block with metadata', () {
      const text = '::: concept 미분 {source: "p.42"}\n설명\n:::';
      expect(BlockExtractor.hasBlock(text), isTrue);
      final result = BlockExtractor.extract(text);
      expect(result, contains('::: concept'));
    });
  });
}
