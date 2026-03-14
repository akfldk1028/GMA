import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

import '../note_editor/utils/markdown_extension.dart';
import 'block_registry.dart';
import 'blocks/concept_block.dart';
import 'parser/container_block_parser.dart';

const _containerTag = 'gma-container';

class GmaMdExtension implements MarkdownExtension {
  GmaMdExtension({this.innerExtensions = const []});

  final List<MarkdownExtension> innerExtensions;

  @override
  String get name => 'gma-md';

  @override
  List<m.InlineSyntax> get inlineSyntaxes => [];

  @override
  List<m.BlockSyntax> get blockSyntaxes => [ContainerBlockSyntax()];

  @override
  List<SpanNodeGeneratorWithTag> get generators => [
        SpanNodeGeneratorWithTag(
          tag: _containerTag,
          generator: (e, config, visitor) =>
              _ContainerBlockNode(e, config, innerExtensions),
        ),
      ];

  @override
  List<dynamic> get themeConfigs => [];
}

class _ContainerBlockNode extends SpanNode {
  final m.Element element;
  final MarkdownConfig config;
  final List<MarkdownExtension> innerExtensions;

  _ContainerBlockNode(this.element, this.config, this.innerExtensions);

  @override
  InlineSpan build() {
    final typeName = element.attributes['blockType'] ?? '';
    final title = element.attributes['title'] ?? '';
    final content = element.textContent;

    // Registry lookup — no switch needed
    final def = lookupBlock(typeName);
    final Widget widget;
    if (def != null) {
      widget = def.buildWidget(
        title: title,
        content: content,
        innerExtensions: innerExtensions,
      );
    } else {
      // Unknown type fallback
      widget = ConceptBlock().buildWidget(
        title: '$typeName: $title',
        content: content,
        innerExtensions: innerExtensions,
      );
    }

    return WidgetSpan(child: widget);
  }
}
