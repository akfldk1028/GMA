import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/gma_md/parser/mindmap_parser.dart';

void main() {
  group('MindmapParser', () {
    test('parses single root', () {
      final root = MindmapParser.parse('Root');
      expect(root, isNotNull);
      expect(root!.label, 'Root');
      expect(root.children, isEmpty);
    });

    test('parses simple hierarchy', () {
      final root = MindmapParser.parse('Root\n  Child1\n  Child2');
      expect(root, isNotNull);
      expect(root!.label, 'Root');
      expect(root.children, hasLength(2));
      expect(root.children[0].label, 'Child1');
      expect(root.children[1].label, 'Child2');
    });

    test('parses nested hierarchy', () {
      final root = MindmapParser.parse(
        '미적분학\n  미분\n    도함수\n    편미분\n  적분\n    부정적분\n    정적분',
      );
      expect(root, isNotNull);
      expect(root!.label, '미적분학');
      expect(root.children, hasLength(2));

      final diff = root.children[0];
      expect(diff.label, '미분');
      expect(diff.children, hasLength(2));
      expect(diff.children[0].label, '도함수');
      expect(diff.children[1].label, '편미분');

      final integral = root.children[1];
      expect(integral.label, '적분');
      expect(integral.children, hasLength(2));
      expect(integral.children[0].label, '부정적분');
      expect(integral.children[1].label, '정적분');
    });

    test('returns null for empty content', () {
      expect(MindmapParser.parse(''), isNull);
    });

    test('skips blank lines', () {
      final root = MindmapParser.parse('Root\n\n  Child');
      expect(root, isNotNull);
      expect(root!.children, hasLength(1));
      expect(root.children[0].label, 'Child');
    });

    test('handles three levels', () {
      final root = MindmapParser.parse('A\n  B\n    C');
      expect(root!.children[0].children[0].label, 'C');
    });
  });
}
