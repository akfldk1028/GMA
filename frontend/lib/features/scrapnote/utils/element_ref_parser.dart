/// Parser for element reference lines in scrapnote markdown.
///
/// Element reference format: `@el <element-id>`
///
/// Examples:
/// - `@el element-123`
/// - `@el pdf-marker-abc`
/// - `Some text @el my-element more text`
class ElementRefParser {
  ElementRefParser._();

  /// Regex pattern for element references:
  /// - Matches `@el` followed by whitespace
  /// - Captures element ID (word characters and hyphens)
  /// Pattern: `@el <id>` where id contains letters, numbers, underscores, or hyphens
  static final _elementRefRegex = RegExp(r'@el\s+([\w-]+)');

  /// Parses a line and extracts the element ID if present.
  ///
  /// Returns the element ID string if found, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final id = ElementRefParser.parse('@el element-123');
  /// print(id); // 'element-123'
  ///
  /// final noMatch = ElementRefParser.parse('No reference here');
  /// print(noMatch); // null
  /// ```
  static String? parse(String line) {
    final match = _elementRefRegex.firstMatch(line);
    return match?.group(1);
  }

  /// Checks if a line contains an element reference.
  ///
  /// Example:
  /// ```dart
  /// final hasRef = ElementRefParser.hasElementRef('@el element-123');
  /// print(hasRef); // true
  ///
  /// final noRef = ElementRefParser.hasElementRef('Just text');
  /// print(noRef); // false
  /// ```
  static bool hasElementRef(String line) {
    return _elementRefRegex.hasMatch(line);
  }

  /// Extracts all element IDs from markdown content.
  ///
  /// Returns a list of unique element IDs found in the content.
  ///
  /// Example:
  /// ```dart
  /// final content = '''
  /// # Notes
  ///
  /// @el element-1
  /// Some text @el element-2 more text
  /// @el element-1
  /// ''';
  /// final ids = ElementRefParser.extractElementIds(content);
  /// print(ids); // ['element-1', 'element-2']
  /// ```
  static List<String> extractElementIds(String content) {
    final matches = _elementRefRegex.allMatches(content);
    final ids = <String>{};

    for (final match in matches) {
      final id = match.group(1);
      if (id != null) {
        ids.add(id);
      }
    }

    return ids.toList();
  }
}
