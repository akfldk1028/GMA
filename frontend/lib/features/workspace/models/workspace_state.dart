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

/// Which panel is currently focused (determines size ratio)
enum FocusedPanel {
  pdf,
  scrapnote,
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
    @Default(false) bool isStickyNoteVisible,
    /// Whether the left page thumbnails panel is open
    @Default(true) bool isPageNavOpen,
    /// Whether the right live scraps panel is open
    @Default(true) bool isLiveScrapsOpen,
    /// Which panel is focused (pdf or scrapnote) — controls size ratio
    @Default(FocusedPanel.pdf) FocusedPanel focusedPanel,
    /// Whether PDF and ScrapNote positions are swapped (left↔right)
    @Default(false) bool isLayoutSwapped,
    /// Set of currently selected scrap element IDs (for edit mode)
    @Default({}) Set<String> selectedScrapIds,
    /// Quick scrap mode — skip popup, create element immediately (슬라이드 10~12)
    @Default(false) bool isQuickScrapMode,
    /// Whether the scrap board popup is open
    @Default(false) bool isScrapBoardOpen,
    /// Pending scrap data for scrap board popup
    int? pendingScrapPageNumber,
    String? pendingScrapText,
    String? pendingScrapImagePath,
    @PdfRectConverter() PdfRect? pendingScrapTextRect,
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
