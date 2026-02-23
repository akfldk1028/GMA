import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';

/// Category for grouping blocks in the insert menu.
enum BlockCategory {
  structural('Structural'),
  visual('Visual'),
  callout('Callout');

  const BlockCategory(this.label);
  final String label;
}

/// Self-describing block definition — each block type provides ALL its own
/// metadata, rendering, unwrap logic, and template.
///
/// To add a new block type:
/// 1. Create a class extending BlockDefinition in blocks/
/// 2. Add one line to block_registry.dart
/// That's it.
abstract class BlockDefinition {
  /// Primary type name used in `:::` syntax (e.g. 'concept', 'flow').
  String get typeName;

  /// Alternative names that resolve to this block (e.g. 'definition' → concept).
  List<String> get aliases => const [];

  /// Category for menu grouping.
  BlockCategory get category;

  /// Accent color for the block.
  Color get color;

  /// Icon for the block header / insert menu.
  IconData get icon;

  /// Display label (e.g. 'Concept', 'Flow').
  String get label;

  /// Template string inserted by the block insert menu.
  String get template;

  /// Build the widget for rendering this block.
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  });

  /// Convert this block to standard Markdown (unwrap).
  String unwrap(String title, String content);
}
