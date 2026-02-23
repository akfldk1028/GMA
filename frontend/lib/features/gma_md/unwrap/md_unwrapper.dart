import '../block_registry.dart';

/// Converts GMA-MD (with ::: container blocks) to standard Markdown.
class MdUnwrapper {
  // Same pattern as parser — strips {metadata} from title
  static final _openPattern =
      RegExp(r'^:::\s*(\w[\w-]*)\s*(.*?)(?:\s*\{.+\})?\s*$');
  static final _closePattern = RegExp(r'^:::\s*$');

  static String unwrap(String input) {
    final lines = input.split('\n');
    final output = <String>[];

    int i = 0;
    while (i < lines.length) {
      final match = _openPattern.firstMatch(lines[i]);
      if (match != null) {
        final type = match.group(1)!.toLowerCase();
        final title = match.group(2)?.trim() ?? '';
        i++; // skip opening :::

        final contentLines = <String>[];
        while (i < lines.length && !_closePattern.hasMatch(lines[i])) {
          contentLines.add(lines[i]);
          i++;
        }
        if (i < lines.length) i++; // skip closing :::

        final content = contentLines.join('\n').trim();

        // Registry lookup — no switch needed
        final def = lookupBlock(type);
        if (def != null) {
          output.add(def.unwrap(title, content));
        } else {
          output.add(content);
        }
      } else {
        output.add(lines[i]);
        i++;
      }
    }

    return output.join('\n');
  }
}
