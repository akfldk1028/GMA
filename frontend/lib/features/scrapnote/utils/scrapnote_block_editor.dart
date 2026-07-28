import 'element_ref_parser.dart';

/// Pure string-manipulation utility for `::: scrapnote` blocks in markdown.
///
/// Block format:
/// ```markdown
/// ::: scrapnote Title
/// @el element-id-1
/// @el element-id-2
/// :::
/// ```
///
/// No Flutter/Riverpod dependencies — testable as plain Dart.
class ScrapnoteBlockEditor {
  ScrapnoteBlockEditor._();

  static final _blockStartRegex = RegExp(r'^::: *scrapnote\s*(.*)?$');
  static const _blockEnd = ':::';

  /// Finds all `::: scrapnote` blocks in [content].
  ///
  /// Returns a list of maps with keys:
  /// - `startLine`: 0-based line index of `::: scrapnote ...`
  /// - `endLine`: 0-based line index of closing `:::`
  /// - `title`: block title (may be empty)
  /// - `elementIds`: ordered list of element IDs found via `@el`
  static List<Map<String, dynamic>> findBlocks(String content) {
    final lines = content.split('\n');
    final blocks = <Map<String, dynamic>>[];
    int? blockStart;
    String? blockTitle;

    for (var i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();

      if (blockStart == null) {
        final match = _blockStartRegex.firstMatch(trimmed);
        if (match != null) {
          blockStart = i;
          blockTitle = match.group(1)?.trim() ?? '';
        }
      } else {
        if (trimmed == _blockEnd) {
          // Collect element IDs within block
          final ids = <String>[];
          for (var j = blockStart + 1; j < i; j++) {
            final id = ElementRefParser.parse(lines[j]);
            if (id != null) ids.add(id);
          }
          blocks.add({
            'startLine': blockStart,
            'endLine': i,
            'title': blockTitle ?? '',
            'elementIds': ids,
          });
          blockStart = null;
          blockTitle = null;
        }
      }
    }
    return blocks;
  }

  /// Whether [content] contains at least one `::: scrapnote` block.
  static bool hasBlock(String content) {
    return findBlocks(content).isNotEmpty;
  }

  /// Ensures at least one `::: scrapnote` block exists.
  /// If none, appends one at the end with optional [blockTitle].
  static String ensureBlock(String content, [String? blockTitle]) {
    if (hasBlock(content)) return content;
    final title = blockTitle ?? 'Scraps';
    final suffix =
        content.endsWith('\n') ? '' : '\n';
    return '$content$suffix\n::: scrapnote $title\n:::\n';
  }

  /// Returns all element IDs across all blocks, or for a specific [blockTitle].
  static List<String> getElementIds(String content, [String? blockTitle]) {
    final blocks = findBlocks(content);
    final ids = <String>[];
    for (final block in blocks) {
      if (blockTitle != null && block['title'] != blockTitle) continue;
      ids.addAll((block['elementIds'] as List<String>));
    }
    return ids;
  }

  /// Appends `@el [elementId]` to the first matching block (or first block).
  /// If no block exists, creates one with [blockTitle] (default: 'Scraps').
  static String appendElement(String content, String elementId,
      [String? blockTitle]) {
    var text = ensureBlock(content, blockTitle);
    final blocks = findBlocks(text);
    if (blocks.isEmpty) return text;

    // Find target block
    final target = blockTitle != null
        ? blocks.firstWhere(
            (b) => b['title'] == blockTitle,
            orElse: () => blocks.first,
          )
        : blocks.first;

    final lines = text.split('\n');
    final endLine = target['endLine'] as int;

    // Insert @el line before the closing :::
    lines.insert(endLine, '@el $elementId');

    return lines.join('\n');
  }

  /// Removes the first `@el [elementId]` line from the content.
  static String removeElement(String content, String elementId) {
    final lines = content.split('\n');
    final pattern = '@el $elementId';
    final idx = lines.indexWhere((line) => line.trim() == pattern);
    if (idx == -1) return content;
    lines.removeAt(idx);
    return lines.join('\n');
  }

  /// Reorders element IDs within the block matching [blockTitle] (or first block).
  static String reorderElements(
      String content, String? blockTitle, List<String> newOrder) {
    final blocks = findBlocks(content);
    if (blocks.isEmpty) return content;

    final target = blockTitle != null
        ? blocks.firstWhere(
            (b) => b['title'] == blockTitle,
            orElse: () => blocks.first,
          )
        : blocks.first;

    final lines = content.split('\n');
    final startLine = target['startLine'] as int;
    final endLine = target['endLine'] as int;

    // Remove old element lines between start and end
    final before = lines.sublist(0, startLine + 1);
    final after = lines.sublist(endLine);

    // Keep non-@el lines that were inside the block
    final nonElLines = <String>[];
    for (var i = startLine + 1; i < endLine; i++) {
      if (!ElementRefParser.hasElementRef(lines[i])) {
        nonElLines.add(lines[i]);
      }
    }

    // Build new block content
    final newLines = [
      ...before,
      ...nonElLines,
      for (final id in newOrder) '@el $id',
      ...after,
    ];

    return newLines.join('\n');
  }
}
