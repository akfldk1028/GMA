import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

import 'markdown_extension.dart';

const _wikiLinkTag = 'wl';

/// Self-contained Wiki-link rendering extension.
///
/// Supports `[[note-name]]` and `[[note-name|display text]]` syntax.
class WikiLinkExtension implements MarkdownExtension {
  WikiLinkExtension({this.onTap});

  final void Function(String target)? onTap;

  @override
  String get name => 'wiki-link';

  @override
  List<m.InlineSyntax> get inlineSyntaxes => [WikiLinkSyntax()];

  @override
  List<m.BlockSyntax> get blockSyntaxes => [];

  @override
  List<SpanNodeGeneratorWithTag> get generators {
    final config = WikiLinkConfig(onTap: onTap);
    return [
      SpanNodeGeneratorWithTag(
        tag: _wikiLinkTag,
        generator: (e, cfg, visitor) => WikiLinkNode(e.attributes, config),
      ),
    ];
  }

  @override
  List<dynamic> get themeConfigs => [
        WikiLinkConfig(
          style: const TextStyle(
            color: Color(0xff0969da),
            decoration: TextDecoration.underline,
          ),
          onTap: onTap,
        ),
      ];
}

class WikiLinkSyntax extends m.InlineSyntax {
  WikiLinkSyntax() : super(r'\[\[(.*?)\]\]');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    m.Element el = m.Element.withTag(_wikiLinkTag);
    final input = match.input;
    el.attributes['id'] = input.substring(match.start + 2, match.end - 2);
    parser.addNode(el);
    return true;
  }
}

class WikiLinkConfig implements LeafConfig {
  final TextStyle style;
  final ValueCallback<String>? onTap;

  const WikiLinkConfig({
    this.style = const TextStyle(
      color: Color(0xff0969da),
      decoration: TextDecoration.underline,
    ),
    this.onTap,
  });

  @nonVirtual
  @override
  String get tag => _wikiLinkTag;
}

class WikiLinkNode extends ElementNode {
  final Map<String, String> attribute;
  final WikiLinkConfig wikiLinkConfig;

  String get wikiLinkId => attribute['id'] ?? '';

  WikiLinkNode(this.attribute, this.wikiLinkConfig);

  @override
  InlineSpan build() {
    String displayName = wikiLinkId;
    int pipeIndex = wikiLinkId.lastIndexOf('|');
    if (pipeIndex != -1 && pipeIndex < wikiLinkId.length - 1) {
      displayName = wikiLinkId.substring(pipeIndex + 1).trim();
    }

    return TextSpan(
      text: displayName,
      style: parentStyle?.merge(wikiLinkConfig.style) ?? wikiLinkConfig.style,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          if (wikiLinkConfig.onTap != null) {
            String linkTarget = wikiLinkId;
            if (pipeIndex != -1) {
              linkTarget = wikiLinkId.substring(0, pipeIndex).trim();
            }
            wikiLinkConfig.onTap?.call(linkTarget);
          }
        },
    );
  }

  @override
  TextStyle get style =>
      parentStyle?.merge(wikiLinkConfig.style) ?? wikiLinkConfig.style;
}
