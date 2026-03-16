import 'package:flutter/material.dart';

import '../../note_editor/utils/markdown_extension.dart';
import '../models/block_definition.dart';
import '../parser/timeline_parser.dart';
import '_block_base.dart';
import 'inner_markdown_content.dart';

class TimelineBlock extends BlockDefinition {
  @override
  String get typeName => 'timeline';
  @override
  BlockCategory get category => BlockCategory.visual;
  @override
  Color get color => const Color(0xFFEC4899);
  @override
  IconData get icon => Icons.timeline;
  @override
  String get label => 'Timeline';
  @override
  String get template =>
      '::: timeline 제목\n2024.01 | 첫 번째 사건\n2024.06 | 두 번째 사건\n2024.12 | 세 번째 사건\n:::\n';

  @override
  Widget buildWidget({
    required String title,
    required String content,
    required List<MarkdownExtension> innerExtensions,
  }) {
    final events = TimelineParser.parse(content);
    if (events.isEmpty) return const SizedBox.shrink();

    return BlockBase(
      color: color,
      icon: icon,
      title: title.isNotEmpty ? title : label,
      child: Column(
        children: [
          for (int i = 0; i < events.length; i++)
            _TimelineRow(
              event: events[i],
              color: color,
              isLast: i == events.length - 1,
              innerExtensions: innerExtensions,
            ),
        ],
      ),
    );
  }

  @override
  String unwrap(String title, String content) {
    final sb = StringBuffer();
    if (title.isNotEmpty) sb.writeln('## $title\n');
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final pipeIdx = trimmed.indexOf('|');
      if (pipeIdx < 0) {
        sb.writeln('- $trimmed');
      } else {
        final date = trimmed.substring(0, pipeIdx).trim();
        final desc = trimmed.substring(pipeIdx + 1).trim();
        sb.writeln('- $date: $desc');
      }
    }
    return sb.toString().trimRight();
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.color,
    required this.isLast,
    required this.innerExtensions,
  });

  final dynamic event;
  final Color color;
  final bool isLast;
  final List<MarkdownExtension> innerExtensions;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: Text(
                event.date,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: InnerMarkdownContent(
                content: event.description,
                extensions: innerExtensions,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
