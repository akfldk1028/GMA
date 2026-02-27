import 'package:gma_frontend/constants/marker_colors.dart';

/// Result of parsing a marker line from markdown.
class MarkerLineParseResult {
  const MarkerLineParseResult({
    required this.isMarkerLine,
    this.color,
    this.pageNumber,
    this.subNumber,
    this.text,
    this.imagePath,
    this.id,
  });

  /// Whether the line is a valid marker line.
  final bool isMarkerLine;

  /// The marker color (extracted from emoji).
  final MarkerColor? color;

  /// The page number (e.g., 3 from "P3" or 1 from "P1-2").
  final int? pageNumber;

  /// The sub-number (e.g., 2 from "P1-2"). Optional.
  final int? subNumber;

  /// The selected text content (optional).
  final String? text;

  /// The captured image path (optional).
  final String? imagePath;

  /// The marker ID (extracted from <!-- id:uuid --> comment). Optional.
  final String? id;
}

/// Parser for PDF marker lines in markdown notes.
///
/// Marker line format: `- 🔴 P3  Selected text...`
/// With optional sub-number: `- 🔴 P1-2  Selected text...`
/// With optional image: `  ![caption](./captures/p5.png)`
/// With optional ID: `- 🔴 P3  Text <!-- id:uuid -->`
///
/// Examples:
/// - `- 🔴 P3  Dictionary-based sentiment analysis is...`
/// - `- 🟡 P5`
/// - `- 🟡 P1-2  Multiple markers on same page`
/// - `- 🟢 P10  Some text\n  ![capture](./captures/p10.png)`
/// - `- 🔴 P3  Text with ID <!-- id:abc-123-def -->`
class MarkerParser {
  MarkerParser._();

  /// Regex pattern for marker lines:
  /// - Starts with `- ` (list item)
  /// - Followed by emoji (🔴🟡🟢🔵🟣🖊️) using alternation (not character class)
  /// - Space and page number `P{number}` with optional sub-number `-{number}`
  /// - Optional: two spaces and text content
  /// Note: Using alternation instead of character class because emojis are multi-byte unicode
  static final _markerLineRegex = RegExp(
    r'^-\s+(🔴|🟡|🟢|🔵|🟣|🖊️)\s+P(\d+)(?:-(\d+))?(?:\s{2}(.+))?$',
  );

  /// Regex pattern for image embed:
  /// `  ![caption](./path/to/image.png)`
  static final _imageEmbedRegex = RegExp(
    r'^\s{2}!\[.*?\]\((.*?)\)$',
  );

  /// Regex pattern for marker ID comment:
  /// `<!-- id:uuid -->`
  static final _idCommentRegex = RegExp(
    r'<!--\s*id:(\S+)\s*-->',
  );

  /// Parses a single marker line.
  ///
  /// Returns [MarkerLineParseResult] with extracted fields or
  /// `isMarkerLine: false` if the line doesn't match the pattern.
  ///
  /// Example:
  /// ```dart
  /// final result = MarkerParser.parse('- 🔴 P3  Some text');
  /// if (result.isMarkerLine) {
  ///   print('Color: ${result.color}');
  ///   print('Page: ${result.pageNumber}');
  ///   print('Text: ${result.text}');
  /// }
  ///
  /// // With sub-number
  /// final result2 = MarkerParser.parse('- 🟡 P1-2  Second marker on page 1');
  /// print('Sub-number: ${result2.subNumber}'); // 2
  ///
  /// // With ID
  /// final result3 = MarkerParser.parse('- 🔴 P3  Text <!-- id:abc-123 -->');
  /// print('ID: ${result3.id}'); // abc-123
  /// ```
  static MarkerLineParseResult parse(String line) {
    final trimmedLine = line.trim();

    // First, check for and extract ID comment if present
    String? id;
    String lineWithoutId = trimmedLine;

    final idMatch = _idCommentRegex.firstMatch(trimmedLine);
    if (idMatch != null) {
      id = idMatch.group(1);
      // Remove the ID comment from the line for further parsing
      lineWithoutId = trimmedLine.replaceFirst(_idCommentRegex, '').trim();
    }

    final match = _markerLineRegex.firstMatch(lineWithoutId);

    if (match == null) {
      return const MarkerLineParseResult(isMarkerLine: false);
    }

    final emoji = match.group(1)!;
    final pageStr = match.group(2)!;
    final subNumStr = match.group(3); // Optional sub-number
    final text = match.group(4); // Optional text (was group 3, now group 4)

    final color = MarkerColor.fromEmoji(emoji);
    final pageNumber = int.tryParse(pageStr);

    if (pageNumber == null) {
      return const MarkerLineParseResult(isMarkerLine: false);
    }

    // Parse optional sub-number
    final subNumber = subNumStr != null ? int.tryParse(subNumStr) : null;

    return MarkerLineParseResult(
      isMarkerLine: true,
      color: color,
      pageNumber: pageNumber,
      subNumber: subNumber,
      text: text,
      id: id,
    );
  }

  /// Parses multiple lines to extract marker line and optional image embed.
  ///
  /// Returns [MarkerLineParseResult] with image path if the next line
  /// contains an image embed.
  ///
  /// Example:
  /// ```dart
  /// final lines = [
  ///   '- 🟡 P5',
  ///   '  ![capture](./captures/p5.png)',
  /// ];
  /// final result = MarkerParser.parseWithImage(lines);
  /// print(result.imagePath); // ./captures/p5.png
  /// ```
  static MarkerLineParseResult parseWithImage(List<String> lines) {
    if (lines.isEmpty) {
      return const MarkerLineParseResult(isMarkerLine: false);
    }

    final markerResult = parse(lines[0]);
    if (!markerResult.isMarkerLine) {
      return markerResult;
    }

    // Check if next line has an image embed
    if (lines.length > 1) {
      final imageMatch = _imageEmbedRegex.firstMatch(lines[1]);
      if (imageMatch != null) {
        final imagePath = imageMatch.group(1);
        return MarkerLineParseResult(
          isMarkerLine: true,
          color: markerResult.color,
          pageNumber: markerResult.pageNumber,
          subNumber: markerResult.subNumber,
          text: markerResult.text,
          imagePath: imagePath,
          id: markerResult.id,
        );
      }
    }

    return markerResult;
  }

  /// Checks if a line is a valid marker line.
  static bool isMarkerLine(String line) {
    return parse(line).isMarkerLine;
  }

  /// Extracts all marker lines from markdown content.
  ///
  /// Returns a list of [MarkerLineParseResult] for all valid marker lines
  /// found in the content.
  ///
  /// Example:
  /// ```dart
  /// final content = '''
  /// # Notes
  ///
  /// - 🔴 P3  Text 1
  /// - 🟡 P5  Text 2
  ///
  /// Regular list item
  /// ''';
  /// final markers = MarkerParser.extractMarkers(content);
  /// print(markers.length); // 2
  /// ```
  static List<MarkerLineParseResult> extractMarkers(String content) {
    final lines = content.split('\n');
    final markers = <MarkerLineParseResult>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final result = parse(line);

      if (result.isMarkerLine) {
        // Check if next line has an image
        if (i + 1 < lines.length) {
          final withImage = parseWithImage([line, lines[i + 1]]);
          markers.add(withImage);
          if (withImage.imagePath != null) {
            i++; // Skip the image line
          }
        } else {
          markers.add(result);
        }
      }
    }

    return markers;
  }
}
