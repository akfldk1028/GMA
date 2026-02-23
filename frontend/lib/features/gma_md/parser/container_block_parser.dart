import 'package:markdown/markdown.dart' as m;

class ContainerBlockSyntax extends m.BlockSyntax {
  // Matches: ::: type title {key: value, ...}
  static final _openPattern =
      RegExp(r'^:::\s*(\w[\w-]*)\s*(.*?)(?:\s*\{(.+)\})?\s*$');
  static final _closePattern = RegExp(r'^:::\s*$');

  @override
  RegExp get pattern => _openPattern;

  @override
  m.Node? parse(m.BlockParser parser) {
    final match = _openPattern.firstMatch(parser.current.content);
    if (match == null) return null;

    final type = match.group(1)!.toLowerCase();
    final title = match.group(2)?.trim() ?? '';
    final attrRaw = match.group(3); // e.g. source: "p.42", tags: "calculus"

    parser.advance(); // Skip opening :::

    final lines = <String>[];
    while (!parser.isDone) {
      final line = parser.current.content;
      if (_closePattern.hasMatch(line)) {
        parser.advance(); // Skip closing :::
        break;
      }
      lines.add(line);
      parser.advance();
    }

    final content = lines.join('\n');
    final el = m.Element.text('gma-container', content);
    el.attributes['blockType'] = type;
    el.attributes['title'] = title;

    // Parse {key: "value", ...} attributes
    if (attrRaw != null && attrRaw.isNotEmpty) {
      el.attributes['metadata'] = attrRaw;
    }

    return el;
  }

  /// Parse metadata string like `source: "p.42", tags: "calculus"` into a Map.
  static Map<String, String> parseMetadata(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    final result = <String, String>{};
    // Match key: "value" or key: value patterns
    final pairs = RegExp(r'(\w+)\s*:\s*"([^"]*)"|\b(\w+)\s*:\s*(\S+)');
    for (final m in pairs.allMatches(raw)) {
      final key = m.group(1) ?? m.group(3) ?? '';
      final val = m.group(2) ?? m.group(4) ?? '';
      if (key.isNotEmpty) result[key] = val;
    }
    return result;
  }
}
