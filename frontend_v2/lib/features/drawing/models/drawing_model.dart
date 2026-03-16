import 'package:freezed_annotation/freezed_annotation.dart';

part 'drawing_model.freezed.dart';
part 'drawing_model.g.dart';

/// A single stroke drawn on a PDF page.
/// Uses normalized (0-1) coordinates for zoom/scroll-independent storage.
@freezed
class DrawingStroke with _$DrawingStroke {
  const factory DrawingStroke({
    required String id,
    required int pageNumber,
    required List<StrokePoint> points,
    required String toolId,
    @Default(0xFF000000) int colorValue,
    @Default(3.0) double size,
  }) = _DrawingStroke;

  factory DrawingStroke.fromJson(Map<String, dynamic> json) =>
      _$DrawingStrokeFromJson(json);
}

/// A single point in a stroke, with normalized coordinates.
@freezed
class StrokePoint with _$StrokePoint {
  const factory StrokePoint({
    required double x,
    required double y,
    double? pressure,
  }) = _StrokePoint;

  factory StrokePoint.fromJson(Map<String, dynamic> json) =>
      _$StrokePointFromJson(json);
}

/// Global drawing mode state (tool, color, size, active).
@freezed
class DrawingToolState with _$DrawingToolState {
  const factory DrawingToolState({
    @Default(false) bool isActive,
    @Default('pen') String currentToolId,
    @Default(0xFF000000) int colorValue,
    @Default(3.0) double strokeSize,
  }) = _DrawingToolState;
}

/// Per-document drawing data with undo support.
/// Not JSON-serialized directly — DrawingSerializer handles persistence.
@freezed
class DrawingData with _$DrawingData {
  const factory DrawingData({
    @Default({}) Map<int, List<DrawingStroke>> pageStrokes,
    @Default([]) List<DrawingStroke> undoStack,
  }) = _DrawingData;
}
