import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../note_editor/utils/markdown_config.dart';
import '../../note_editor/utils/markdown_extension.dart';

/// Renders markdown content inside a GMA-MD block.
///
/// Uses the same markdown rendering pipeline as the main editor,
/// but excludes [GmaMdExtension] to prevent recursive `:::` parsing.
class InnerMarkdownContent extends StatelessWidget {
  const InnerMarkdownContent({
    super.key,
    required this.content,
    required this.extensions,
    this.style,
  });

  /// Raw markdown text to render.
  final String content;

  /// Extensions to use (should NOT include GmaMdExtension).
  final List<MarkdownExtension> extensions;

  /// Optional base text style override.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    final config = buildMarkdownConfig(
      context,
      extensions: extensions,
      textColor: style?.color,
    );
    final generator = buildMarkdownGenerator(extensions: extensions);

    return MarkdownWidget(
      data: content,
      shrinkWrap: true,
      selectable: true,
      config: config,
      markdownGenerator: generator,
    );
  }
}
