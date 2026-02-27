import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../../scrapnote/utils/element_ref_parser.dart';
import '../models/block_definition.dart';
import '_block_base.dart';

/// ScrapNote block definition.
/// Parses @el lines and renders ElementCard widgets for each element reference.
class ScrapnoteBlock extends BlockDefinition {
  @override
  String get typeName => 'scrapnote';

  @override
  List<String> get aliases => const ['scrap'];

  @override
  BlockCategory get category => BlockCategory.structural;

  @override
  Color get color => const Color(0xFF6366F1); // indigo

  @override
  IconData get icon => Icons.collections_bookmark;

  @override
  String get label => 'ScrapNote';

  @override
  String get template =>
      '::: scrapnote 스크랩노트 제목\n@el element-id\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    return BlockBase(
      color: color,
      icon: icon,
      title: title.isNotEmpty ? title : label,
      child: _ScrapnoteContent(content: content),
    );
  }

  @override
  String unwrap(String title, String content) {
    if (title.isNotEmpty) return '## $title\n\n$content';
    return content;
  }
}

/// Internal widget that renders the scrapnote content.
/// Parses @el lines and renders ElementCard for each element reference.
class _ScrapnoteContent extends ConsumerWidget {
  const _ScrapnoteContent({required this.content});

  final String content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement once elementStoreProvider is available
    // This requires ElementStore to be fully implemented with:
    // - Provider definition for elementStoreProvider
    // - ElementStore.getElementById() method
    // See: lib/features/scrapnote/providers/scrapnote_provider.dart

    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final elementId = ElementRefParser.parse(line);

      if (elementId != null) {
        // This is an @el reference - show placeholder until ElementStore is implemented
        widgets.add(
          _ElementNotFoundPlaceholder(elementId: elementId),
        );
      } else if (line.trim().isNotEmpty) {
        // Regular text line
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) {
      return const Text(
        '(empty scrapnote)',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}

/// Placeholder widget shown when an element is not found.
class _ElementNotFoundPlaceholder extends StatelessWidget {
  const _ElementNotFoundPlaceholder({required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Element not found: @el $elementId',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
