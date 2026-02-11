import 'dart:io';

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'markdown_extension.dart';

/// Creates the MarkdownConfig for the note editor preview.
///
/// Merges shadcn_ui theme styles with any [themeConfigs] from registered
/// [MarkdownExtension] instances.
MarkdownConfig buildMarkdownConfig(
  BuildContext context, {
  List<MarkdownExtension> extensions = const [],
  Color? textColor,
}) {
  final theme = ShadTheme.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final config = isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
  final fg = textColor ?? theme.colorScheme.foreground;

  // Collect theme configs from all extensions
  final extensionConfigs = extensions.expand((e) => e.themeConfigs).toList();

  return config.copy(configs: [
    PConfig(textStyle: TextStyle(fontSize: 14, height: 1.7, color: fg)),
    H1Config(style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: fg)),
    H2Config(style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: fg)),
    H3Config(style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: fg)),
    H4Config(style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
    H5Config(style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
    H6Config(style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
    HrConfig(
      height: 1,
      color: theme.colorScheme.border,
    ),
    BlockquoteConfig(
      textColor: theme.colorScheme.mutedForeground,
      sideColor: theme.colorScheme.primary.withValues(alpha: 0.4),
    ),
    TableConfig(
      wrapper: (table) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: table,
      ),
    ),
    const PreConfig().copy(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          width: 1,
          color: theme.colorScheme.border,
        ),
      ),
      textStyle: TextStyle(fontSize: 13, color: fg),
    ),
    // Extension-provided theme configs (e.g., WikiLinkConfig styling)
    ...extensionConfigs,
    // Custom image handler: resolve file:// URIs to Image.file()
    ImgConfig(builder: (url, attributes) {
      final alt = attributes['alt'] ?? '';
      Widget errorWidget(Object error) => Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, color: Colors.redAccent, size: 16),
                const SizedBox(width: 4),
                Text(alt.isNotEmpty ? alt : 'Image not found',
                    style: TextStyle(color: fg, fontSize: 12)),
              ],
            ),
          );

      if (url.startsWith('file:///')) {
        final filePath = Uri.parse(url).toFilePath();
        return Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (ctx, error, stack) => errorWidget(error),
        );
      }
      if (url.startsWith('http')) {
        return Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (ctx, error, stack) => errorWidget(error),
        );
      }
      // Fallback for other paths (asset or broken)
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (ctx, error, stack) => errorWidget(error),
      );
    }),
  ]);
}

/// Creates the MarkdownGenerator by auto-collecting syntaxes and generators
/// from registered [MarkdownExtension] instances.
MarkdownGenerator buildMarkdownGenerator({
  required List<MarkdownExtension> extensions,
}) {
  // Collect syntaxes and generators from all extensions
  final inlineSyntaxes = extensions.expand((e) => e.inlineSyntaxes).toList();
  final blockSyntaxes = extensions.expand((e) => e.blockSyntaxes).toList();
  final generators = extensions.expand((e) => e.generators).toList();

  return MarkdownGenerator(
    generators: generators,
    inlineSyntaxList: inlineSyntaxes,
    blockSyntaxList: blockSyntaxes,
  );
}
