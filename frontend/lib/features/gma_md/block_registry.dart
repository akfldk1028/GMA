import 'package:flutter/material.dart';

import 'blocks/callout_block.dart';
import 'blocks/compare_block.dart';
import 'blocks/concept_block.dart';
import 'blocks/example_block.dart';
import 'blocks/flow_block.dart';
import 'blocks/graph_block.dart';
import 'blocks/mindmap_block.dart';
import 'blocks/proof_block.dart';
import 'blocks/scrapnote_block.dart';
import 'blocks/summary_block.dart';
import 'blocks/theorem_block.dart';
import 'blocks/timeline_block.dart';
import 'models/block_definition.dart';

// ┌──────────────────────────────────────────────────────┐
// │  BLOCK REGISTRY                                      │
// │  To add a new block: create 1 file, add 1 line here. │
// └──────────────────────────────────────────────────────┘
final blockRegistry = <BlockDefinition>[
  // Structural
  ConceptBlock(),
  TheoremBlock(),
  ProofBlock(),
  ExampleBlock(),
  SummaryBlock(),
  ScrapnoteBlock(),
  // Visual
  FlowBlock(),
  GraphBlock(),
  CompareBlock(),
  TimelineBlock(),
  MindmapBlock(),
  // Callout
  CalloutBlock(typeName: 'note', color: const Color(0xFF3B82F6), icon: Icons.edit_note, label: 'Note'),
  CalloutBlock(typeName: 'tip', color: const Color(0xFF06B6D4), icon: Icons.tips_and_updates, label: 'Tip', aliases: ['hint', 'important']),
  CalloutBlock(typeName: 'warning', color: const Color(0xFFF97316), icon: Icons.warning_amber, label: 'Warning', aliases: ['caution', 'attention']),
  CalloutBlock(typeName: 'question', color: const Color(0xFFEAB308), icon: Icons.help_outline, label: 'Question', aliases: ['help', 'faq']),
  CalloutBlock(typeName: 'danger', color: const Color(0xFFEF4444), icon: Icons.dangerous, label: 'Danger', aliases: ['error']),
  CalloutBlock(typeName: 'quote', color: const Color(0xFF6B7280), icon: Icons.format_quote, label: 'Quote', aliases: ['cite']),
];

// ── Lookup helpers ──────────────────────────────────────

Map<String, BlockDefinition>? _byName;

void _ensureIndex() {
  if (_byName != null) return;
  _byName = {};
  for (final def in blockRegistry) {
    _byName![def.typeName] = def;
    for (final alias in def.aliases) {
      _byName![alias] = def;
    }
  }
}

/// Resolve a type name (or alias) to a BlockDefinition.
BlockDefinition? lookupBlock(String typeName) {
  _ensureIndex();
  return _byName![typeName.toLowerCase()];
}

/// All definitions grouped by category.
Map<String, List<BlockDefinition>> get blocksByCategory {
  final result = <String, List<BlockDefinition>>{};
  for (final def in blockRegistry) {
    result.putIfAbsent(def.category.label, () => []).add(def);
  }
  return result;
}
