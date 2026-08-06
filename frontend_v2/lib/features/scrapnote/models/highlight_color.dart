import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'highlight_color.g.dart';

/// Predefined highlight color constants and session state management.
class HighlightColors {
  const HighlightColors._();

  /// Yellow — the default highlight color.
  static const int yellow = 0xFFFFEB3B;

  /// Green highlight.
  static const int green = 0xFF4CAF50;

  /// Blue highlight.
  static const int blue = 0xFF2196F3;

  /// Pink highlight.
  static const int pink = 0xFFE91E63;

  /// Orange highlight.
  static const int orange = 0xFFFF9800;

  /// The default color applied when no prior selection exists.
  static const int defaultColor = yellow;

  /// Opacity fraction applied when rendering highlights over text (0-1).
  static const double highlightOpacity = 0.4;

  /// All supported highlight colors in display order.
  static const List<int> availableColors = [
    yellow,
    green,
    blue,
    pink,
    orange,
  ];
}

/// Tracks the last-used highlight color for the current session.
/// Resets to [HighlightColors.defaultColor] on app restart.
@Riverpod(keepAlive: true)
class LastUsedHighlightColor extends _$LastUsedHighlightColor {
  @override
  int build() => HighlightColors.defaultColor;

  /// Updates the last-used color for the session.
  void setColor(int colorValue) {
    state = colorValue;
  }
}
