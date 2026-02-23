import '../models/timeline_model.dart';

/// Parses timeline content: each line is `date | description`.
class TimelineParser {
  static List<TimelineEvent> parse(String content) {
    final events = <TimelineEvent>[];
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final pipeIdx = trimmed.indexOf('|');
      if (pipeIdx < 0) continue;

      final date = trimmed.substring(0, pipeIdx).trim();
      final desc = trimmed.substring(pipeIdx + 1).trim();
      if (date.isEmpty || desc.isEmpty) continue;

      events.add(TimelineEvent(date: date, description: desc));
    }
    return events;
  }
}
