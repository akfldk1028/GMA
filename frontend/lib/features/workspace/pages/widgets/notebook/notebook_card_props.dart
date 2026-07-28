/// Layout/visual constants for the [NotebookScrapPanel].
class NotebookConst {
  NotebookConst._();

  static const double defaultWidth = 360;
  static const double defaultHeight = 220;
  static const double cardSpacing = 12;
  static const double pad = 16; // outer padding around cards
  static const double minHeight = 32;
  static const double maxHeight = 4000;
  static const double rotationStem = 38;
  static const double cornerHandleSize = 14;
  static const double rotationHandleSize = 16;
  static const double iconButtonSize = 26;
  static const double handleMargin = 10; // around card for corner handles

  /// Extra blank space below the lowest card so users can draw/scroll
  /// past the last card.
  static const double footerSpace = 1500;
}

/// Which corner of a card a resize handle is attached to.
/// Used by NotebookScrapPanel to pick the correct sign convention when
/// converting drag deltas into width/height changes.
enum NotebookCorner { tl, tr, bl, br }

/// Per-card visual props on the notebook canvas (absolute coords).
///
/// Stored in Hive under `notebook_card_props_<noteId>` and round-tripped
/// via [toJson] / [fromJson].
class NotebookCardProps {
  NotebookCardProps({
    required this.absX,
    required this.absY,
    required this.width,
    required this.height,
    this.rotation = 0.0,
  });

  /// Canvas-absolute left.
  double absX;

  /// Canvas-absolute top.
  double absY;
  double width;
  double height;

  /// Rotation in radians.
  double rotation;

  Map<String, double> toJson() => {
        'x': absX,
        'y': absY,
        'w': width,
        'h': height,
        'r': rotation,
      };

  factory NotebookCardProps.fromJson(Map<String, double> j) =>
      NotebookCardProps(
        absX: j['x'] ?? 0,
        absY: j['y'] ?? 0,
        width: (j['w'] ?? NotebookConst.defaultWidth).clamp(80.0, 4000.0),
        height: (j['h'] ?? NotebookConst.defaultHeight)
            .clamp(NotebookConst.minHeight, NotebookConst.maxHeight),
        rotation: j['r'] ?? 0.0,
      );
}
