import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdfrx/pdfrx.dart';
import 'pdf_marker_model.dart';

part 'workspace_state.freezed.dart';
part 'workspace_state.g.dart';

/// Sidebar display mode for workspace left panel
enum SidebarMode {
  fileBrowser,
  elementNavigator,
}

/// Panel size configuration (legacy, kept for test compatibility)
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
    /// List of currently open PDF paths (tab bar)
    @Default([]) List<String> openPdfPaths,
    @Default(PanelSizes()) PanelSizes panelSizes,
    @Default(SidebarMode.fileBrowser) SidebarMode sidebarMode,
    // Modal/drawer UI state
    @Default(false) bool isEditorModalOpen,
    @Default(false) bool isFileBrowserOpen,
    @Default(false) bool isMarkerEditModalOpen,
    /// Whether the sticky note floating window is visible
    @Default(true) bool isStickyNoteVisible,
    /// Whether the left page thumbnails panel is open
    @Default(true) bool isPageNavOpen,
    /// Whether the right live scraps panel is open
    @Default(true) bool isLiveScrapsOpen,
    /// ID of the marker currently being edited in the modal (null = new marker)
    String? editingMarkerId,
    /// Pending marker data for the marker edit modal (from text selection)
    int? pendingMarkerPageNumber,
    String? pendingMarkerText,
    @PdfRectConverter() PdfRect? pendingMarkerTextRect,
  }) = _WorkspaceState;

  factory WorkspaceState.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceStateFromJson(json);
}
