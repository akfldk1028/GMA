import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

import '../../../constants/marker_colors.dart';
import 'markdown_extension.dart';

const _markerTag = 'pdfmarker';

/// Build emoji alternation pattern from MarkerColor.values (n8n pattern:
/// adding a new MarkerColor enum value auto-updates the regex).
String _buildEmojiPattern() {
  final emojis =
      MarkerColor.values.map((c) => RegExp.escape(c.emoji)).join('|');
  return '($emojis)';
}

/// Regex for marker lines after markdown list-item parsing strips `- `.
/// Input to inline parser is e.g. `🔴 P3-2  selected text...`
/// Groups: 1=emoji, 2=page, 3=subNumber (optional), 4=text (optional)
final _markerRegex = RegExp(
  '^${_buildEmojiPattern()}\\s+P(\\d+)(?:-(\\d+))?(?:\\s{2}(.+))?\$',
);

/// Self-contained PDF marker line rendering extension.
///
/// Renders `- 🔴 P3-2  text` as clickable colored badge widgets.
/// Clicking navigates to the corresponding PDF page location.
class MarkerLineExtension implements MarkdownExtension {
  MarkerLineExtension({this.onTap});

  /// Called when a marker badge is tapped.
  /// [pageNumber] = PDF page, [subNumber] = sequence within page, [color] = marker color.
  final void Function(int pageNumber, int subNumber, MarkerColor color)? onTap;

  @override
  String get name => 'marker-line';

  @override
  List<m.InlineSyntax> get inlineSyntaxes => [MarkerLineSyntax()];

  @override
  List<m.BlockSyntax> get blockSyntaxes => [];

  @override
  List<SpanNodeGeneratorWithTag> get generators {
    final config = MarkerLineConfig(onTap: onTap);
    return [
      SpanNodeGeneratorWithTag(
        tag: _markerTag,
        generator: (e, cfg, visitor) => MarkerLineNode(e.attributes, config),
      ),
    ];
  }

  @override
  List<dynamic> get themeConfigs => [];
}

class MarkerLineSyntax extends m.InlineSyntax {
  MarkerLineSyntax()
      : super('${_buildEmojiPattern()}\\s+P(\\d+)(?:-(\\d+))?(?:\\s{2}(.+))?');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final input = match.input.substring(match.start, match.end);
    final markerMatch = _markerRegex.firstMatch(input);
    if (markerMatch == null) return false;

    m.Element el = m.Element.text(_markerTag, input);
    el.attributes['emoji'] = markerMatch.group(1)!;
    el.attributes['page'] = markerMatch.group(2)!;
    el.attributes['sub'] = markerMatch.group(3) ?? '1';
    el.attributes['text'] = markerMatch.group(4) ?? '';
    parser.addNode(el);
    return true;
  }
}

class MarkerLineConfig {
  final void Function(int pageNumber, int subNumber, MarkerColor color)? onTap;
  const MarkerLineConfig({this.onTap});
}

class MarkerLineNode extends SpanNode {
  final Map<String, String> attributes;
  final MarkerLineConfig config;

  MarkerLineNode(this.attributes, this.config);

  @override
  InlineSpan build() {
    final emoji = attributes['emoji'] ?? '🔴';
    final pageStr = attributes['page'] ?? '0';
    final subStr = attributes['sub'] ?? '1';
    final text = attributes['text'] ?? '';
    final pageNumber = int.tryParse(pageStr) ?? 0;
    final subNumber = int.tryParse(subStr) ?? 1;
    final color = MarkerColor.fromEmoji(emoji);

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () => config.onTap?.call(pageNumber, subNumber, color),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'P$pageStr-$subStr',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.color,
                  ),
                ),
              ),
              if (text.isNotEmpty) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
