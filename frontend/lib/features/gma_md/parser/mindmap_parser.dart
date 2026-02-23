import '../models/mindmap_model.dart';

/// Parses indentation-based mindmap content into a tree structure.
/// Each level is 2 spaces of indentation.
class MindmapParser {
  static MindmapNode? parse(String content) {
    final lines = content.split('\n').where((l) => l.trimRight().isNotEmpty).toList();
    if (lines.isEmpty) return null;

    final root = MindmapNode(label: lines[0].trim());
    if (lines.length == 1) return root;

    _parseChildren(lines, 1, lines.length, _indentLevel(lines[0]) + 1, root);
    return root;
  }

  static void _parseChildren(
    List<String> lines,
    int start,
    int end,
    int expectedLevel,
    MindmapNode parent,
  ) {
    int i = start;
    while (i < end) {
      final level = _indentLevel(lines[i]);
      if (level < expectedLevel) break;
      if (level == expectedLevel) {
        final node = MindmapNode(label: lines[i].trim());
        parent.children.add(node);
        // Find children of this node
        int j = i + 1;
        while (j < end && _indentLevel(lines[j]) > expectedLevel) {
          j++;
        }
        if (j > i + 1) {
          _parseChildren(lines, i + 1, j, expectedLevel + 1, node);
        }
        i = j;
      } else {
        i++;
      }
    }
  }

  static int _indentLevel(String line) {
    int spaces = 0;
    for (final ch in line.codeUnits) {
      if (ch == 0x20) {
        spaces++;
      } else if (ch == 0x09) {
        spaces += 2;
      } else {
        break;
      }
    }
    return spaces ~/ 2;
  }
}
