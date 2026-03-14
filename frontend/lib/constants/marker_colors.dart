import 'package:flutter/material.dart';

/// PDF marker colors used for page annotations.
/// Maps to emoji indicators: 🔴🟡🟢🔵🟣
enum MarkerColor {
  red(Color(0xFFEF4444), '🔴'),
  yellow(Color(0xFFF59E0B), '🟡'),
  green(Color(0xFF22C55E), '🟢'),
  blue(Color(0xFF3B82F6), '🔵'),
  purple(Color(0xFF8B5CF6), '🟣'),
  pen(Color(0xFF6B7280), '🖊️');

  const MarkerColor(this.color, this.emoji);

  final Color color;
  final String emoji;

  static MarkerColor fromEmoji(String emoji) {
    return MarkerColor.values.firstWhere(
      (m) => m.emoji == emoji,
      orElse: () => MarkerColor.red,
    );
  }

  static MarkerColor fromName(String name) {
    return MarkerColor.values.firstWhere(
      (m) => m.name == name,
      orElse: () => MarkerColor.red,
    );
  }
}
