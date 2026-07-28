/// Extracts GMA MD blocks from LLM output.
///
/// LLM sometimes adds explanation text around the block.
/// This extracts just the ::: block(s).
class BlockExtractor {
  BlockExtractor._();

  /// Matches ::: blocks with optional content (including empty blocks).
  /// Allows trailing whitespace after closing :::
  static final _blockPattern = RegExp(
    r'^(:::[ \t]+\w[\w-]*[^\n]*\n[\s\S]*?\n:::)\s*$',
    multiLine: true,
  );

  /// Matches empty blocks: `::: type Title\n:::`
  static final _emptyBlockPattern = RegExp(
    r'^(:::[ \t]+\w[\w-]*[^\n]*\n:::)\s*$',
    multiLine: true,
  );

  /// Extract all ::: blocks from [text].
  ///
  /// Returns extracted blocks joined by newlines.
  /// If no blocks found, returns the original text unchanged.
  static String extract(String text) {
    final matches = <RegExpMatch>[];
    final seen = <int>{};

    for (final m in _blockPattern.allMatches(text)) {
      if (seen.add(m.start)) matches.add(m);
    }
    for (final m in _emptyBlockPattern.allMatches(text)) {
      if (seen.add(m.start)) matches.add(m);
    }

    if (matches.isEmpty) return text;

    matches.sort((a, b) => a.start.compareTo(b.start));
    return matches.map((m) => m.group(1)!.trim()).join('\n\n');
  }

  /// Check if [text] contains at least one ::: block.
  static bool hasBlock(String text) {
    return _blockPattern.hasMatch(text) || _emptyBlockPattern.hasMatch(text);
  }
}
