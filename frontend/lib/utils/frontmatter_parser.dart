import 'package:yaml/yaml.dart';

/// Result of parsing frontmatter from a markdown document
class FrontmatterResult {
  final Map<String, dynamic>? frontmatter;
  final String body;
  final bool hasFrontmatter;

  const FrontmatterResult({
    this.frontmatter,
    required this.body,
    required this.hasFrontmatter,
  });
}

/// Parser for YAML frontmatter in markdown documents
///
/// Frontmatter format:
/// ```
/// ---
/// file: example.pdf
/// file-path: ./assets/example.pdf
/// created: 2026-02-04
/// tags: [machine-learning, logistic-regression]
/// markers:
///   - id: m1
///     page: 3
///     color: red
///     text: "Some text..."
///     rect: [120.5, 340.2, 580.0, 360.8]
/// ---
///
/// # Markdown content starts here
/// ```
class FrontmatterParser {
  /// Parse a markdown document and extract frontmatter if present
  ///
  /// Returns a [FrontmatterResult] containing:
  /// - frontmatter: Map of parsed YAML data (null if no frontmatter)
  /// - body: The markdown content without frontmatter
  /// - hasFrontmatter: Whether frontmatter was found
  static FrontmatterResult parse(String content) {
    if (content.isEmpty) {
      return const FrontmatterResult(
        frontmatter: null,
        body: '',
        hasFrontmatter: false,
      );
    }

    // Check if content starts with frontmatter delimiter
    if (!content.trimLeft().startsWith('---')) {
      return FrontmatterResult(
        frontmatter: null,
        body: content,
        hasFrontmatter: false,
      );
    }

    final lines = content.split('\n');
    int startIndex = -1;
    int endIndex = -1;

    // Find the frontmatter boundaries
    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (trimmed == '---') {
        if (startIndex == -1) {
          startIndex = i;
        } else {
          endIndex = i;
          break;
        }
      }
    }

    // No valid frontmatter found
    if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex + 1) {
      return FrontmatterResult(
        frontmatter: null,
        body: content,
        hasFrontmatter: false,
      );
    }

    // Extract frontmatter YAML content
    final yamlLines = lines.sublist(startIndex + 1, endIndex);
    final yamlContent = yamlLines.join('\n');

    // Extract body content
    final bodyLines = lines.sublist(endIndex + 1);
    final body = bodyLines.join('\n').trimLeft();

    // Parse YAML
    try {
      final yaml = loadYaml(yamlContent);

      if (yaml == null) {
        return FrontmatterResult(
          frontmatter: null,
          body: content,
          hasFrontmatter: false,
        );
      }

      // Convert YamlMap to Map<String, dynamic>
      final Map<String, dynamic> frontmatter = _convertYamlToMap(yaml);

      return FrontmatterResult(
        frontmatter: frontmatter,
        body: body,
        hasFrontmatter: true,
      );
    } catch (e) {
      // If YAML parsing fails, return the original content
      return FrontmatterResult(
        frontmatter: null,
        body: content,
        hasFrontmatter: false,
      );
    }
  }

  /// Convert YamlMap/YamlList to plain Dart Map/List
  static dynamic _convertYamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      final map = <String, dynamic>{};
      for (final entry in yaml.entries) {
        map[entry.key.toString()] = _convertYamlToMap(entry.value);
      }
      return map;
    } else if (yaml is YamlList) {
      return yaml.map((e) => _convertYamlToMap(e)).toList();
    } else {
      return yaml;
    }
  }

  /// Extract a specific field from frontmatter
  static T? getField<T>(Map<String, dynamic>? frontmatter, String key) {
    if (frontmatter == null) return null;
    final value = frontmatter[key];
    if (value is T) return value;
    return null;
  }

  /// Check if frontmatter has a specific field
  static bool hasField(Map<String, dynamic>? frontmatter, String key) {
    return frontmatter?.containsKey(key) ?? false;
  }

  /// Serialize frontmatter map back to YAML string
  static String serialize(Map<String, dynamic> frontmatter) {
    final yamlString = _serializeToYaml(frontmatter, 0);
    return '---\n$yamlString---\n';
  }

  static String _serializeToYaml(dynamic value, int indent) {
    final indentStr = '  ' * indent;

    if (value is Map<String, dynamic>) {
      final buffer = StringBuffer();
      for (final entry in value.entries) {
        final key = entry.key;
        final val = entry.value;

        if (val is Map<String, dynamic>) {
          buffer.writeln('$indentStr$key:');
          buffer.write(_serializeToYaml(val, indent + 1));
        } else if (val is List) {
          buffer.writeln('$indentStr$key:');
          buffer.write(_serializeToYaml(val, indent + 1));
        } else {
          buffer.writeln('$indentStr$key: $val');
        }
      }
      return buffer.toString();
    } else if (value is List) {
      final buffer = StringBuffer();
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          buffer.writeln('$indentStr-');
          final itemYaml = _serializeToYaml(item, indent + 1);
          // Remove the first indent since we already have the dash
          final lines = itemYaml.split('\n');
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].isNotEmpty) {
              if (i == 0) {
                buffer.writeln('$indentStr  ${lines[i].trim()}');
              } else {
                buffer.writeln(lines[i]);
              }
            }
          }
        } else {
          buffer.writeln('$indentStr- $item');
        }
      }
      return buffer.toString();
    } else {
      return '$indentStr$value\n';
    }
  }
}
