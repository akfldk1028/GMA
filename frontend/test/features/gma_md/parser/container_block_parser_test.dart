import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/gma_md/parser/container_block_parser.dart';
import 'package:markdown/markdown.dart' as m;

void main() {
  group('ContainerBlockSyntax', () {
    late ContainerBlockSyntax syntax;

    setUp(() {
      syntax = ContainerBlockSyntax();
    });

    test('pattern matches opening line', () {
      expect(syntax.pattern.hasMatch('::: concept Title'), isTrue);
      expect(syntax.pattern.hasMatch('::: flow'), isTrue);
      expect(syntax.pattern.hasMatch('::: warning 주의사항'), isTrue);
      expect(syntax.pattern.hasMatch('not a block'), isFalse);
    });

    test('pattern captures type and title', () {
      final match = syntax.pattern.firstMatch(
        '::: concept 미분의 정의',
      );
      expect(match, isNotNull);
      expect(match!.group(1), 'concept');
      expect(match.group(2)!.trim(), '미분의 정의');
    });

    test('pattern captures metadata', () {
      final match = syntax.pattern.firstMatch(
        '::: concept 제목 {source: "p.42", tags: "calc"}',
      );
      expect(match, isNotNull);
      expect(match!.group(1), 'concept');
      expect(match.group(2)!.trim(), '제목');
      expect(match.group(3), 'source: "p.42", tags: "calc"');
    });

    test('pattern matches without metadata', () {
      final match = syntax.pattern.firstMatch(
        '::: theorem 정리 이름',
      );
      expect(match, isNotNull);
      expect(match!.group(1), 'theorem');
      expect(match.group(2)!.trim(), '정리 이름');
      expect(match.group(3), isNull);
    });

    test('parses block content correctly', () {
      final doc = m.Document(
        blockSyntaxes: [ContainerBlockSyntax()],
      );
      final nodes = doc.parseLines([
        '::: concept Test',
        'Line 1',
        'Line 2',
        ':::',
      ]);

      expect(nodes, hasLength(1));
      final element = nodes.first as m.Element;
      expect(element.tag, 'gma-container');
      expect(element.attributes['blockType'], 'concept');
      expect(element.attributes['title'], 'Test');
      expect(element.textContent, 'Line 1\nLine 2');
    });

    test('parses block with metadata attribute', () {
      final doc = m.Document(
        blockSyntaxes: [ContainerBlockSyntax()],
      );
      final nodes = doc.parseLines([
        '::: concept Title {source: "p.42"}',
        'Content here',
        ':::',
      ]);

      final element = nodes.first as m.Element;
      expect(element.attributes['blockType'], 'concept');
      expect(element.attributes['title'], 'Title');
      expect(element.attributes['metadata'], 'source: "p.42"');
    });

    test('handles empty content', () {
      final doc = m.Document(
        blockSyntaxes: [ContainerBlockSyntax()],
      );
      final nodes = doc.parseLines(['::: note', ':::']);

      final element = nodes.first as m.Element;
      expect(element.textContent, '');
    });
  });

  group('parseMetadata', () {
    test('parses quoted values', () {
      final result = ContainerBlockSyntax.parseMetadata(
        'source: "p.42", tags: "calculus"',
      );
      expect(result, {'source': 'p.42', 'tags': 'calculus'});
    });

    test('parses unquoted values', () {
      final result = ContainerBlockSyntax.parseMetadata('level: 3');
      expect(result, {'level': '3'});
    });

    test('returns empty map for null input', () {
      expect(ContainerBlockSyntax.parseMetadata(null), isEmpty);
    });

    test('returns empty map for empty string', () {
      expect(ContainerBlockSyntax.parseMetadata(''), isEmpty);
    });
  });
}
