import 'package:freezed_annotation/freezed_annotation.dart';
import 'pdf_marker_model.dart';

part 'workspace_state.freezed.dart';
part 'workspace_state.g.dart';

/// Panel size configuration for the 3-panel workspace layout
@freezed
class PanelSizes with _$PanelSizes {
  const factory PanelSizes({
    @Default(0.2) double left,   // File manager sidebar (default 20%)
    @Default(0.4) double center, // PDF viewer (default 40%)
    @Default(0.4) double right,  // Note editor (default 40%)
  }) = _PanelSizes;

  factory PanelSizes.fromJson(Map<String, dynamic> json) =>
      _$PanelSizesFromJson(json);
}

/// Main workspace state managing PDF-Note linking and UI state
@freezed
class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState({
    String? currentPdfPath,
    String? currentNoteId,
    @Default([]) List<PdfMarker> markers,
    @Default(PanelSizes()) PanelSizes panelSizes,
  }) = _WorkspaceState;

  factory WorkspaceState.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceStateFromJson(json);
}
