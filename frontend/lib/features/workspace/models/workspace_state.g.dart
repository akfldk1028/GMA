// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PanelSizesImpl _$$PanelSizesImplFromJson(Map<String, dynamic> json) =>
    _$PanelSizesImpl(
      left: (json['left'] as num?)?.toDouble() ?? 0.2,
      center: (json['center'] as num?)?.toDouble() ?? 0.4,
      right: (json['right'] as num?)?.toDouble() ?? 0.4,
    );

Map<String, dynamic> _$$PanelSizesImplToJson(_$PanelSizesImpl instance) =>
    <String, dynamic>{
      'left': instance.left,
      'center': instance.center,
      'right': instance.right,
    };

_$WorkspaceStateImpl _$$WorkspaceStateImplFromJson(Map<String, dynamic> json) =>
    _$WorkspaceStateImpl(
      currentPdfPath: json['currentPdfPath'] as String?,
      currentNoteId: json['currentNoteId'] as String?,
      markers:
          (json['markers'] as List<dynamic>?)
              ?.map((e) => PdfMarker.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      openPdfPaths:
          (json['openPdfPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      panelSizes: json['panelSizes'] == null
          ? const PanelSizes()
          : PanelSizes.fromJson(json['panelSizes'] as Map<String, dynamic>),
      sidebarMode:
          $enumDecodeNullable(_$SidebarModeEnumMap, json['sidebarMode']) ??
          SidebarMode.fileBrowser,
      isEditorModalOpen: json['isEditorModalOpen'] as bool? ?? false,
      isFileBrowserOpen: json['isFileBrowserOpen'] as bool? ?? false,
      isMarkerEditModalOpen: json['isMarkerEditModalOpen'] as bool? ?? false,
      isStickyNoteVisible: json['isStickyNoteVisible'] as bool? ?? false,
      isPageNavOpen: json['isPageNavOpen'] as bool? ?? true,
      isLiveScrapsOpen: json['isLiveScrapsOpen'] as bool? ?? true,
      focusedPanel:
          $enumDecodeNullable(_$FocusedPanelEnumMap, json['focusedPanel']) ??
          FocusedPanel.scrapnote,
      isLayoutSwapped: json['isLayoutSwapped'] as bool? ?? false,
      selectedScrapIds:
          (json['selectedScrapIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      isQuickScrapMode: json['isQuickScrapMode'] as bool? ?? false,
      isScrapBoardOpen: json['isScrapBoardOpen'] as bool? ?? false,
      pendingScrapPageNumber: (json['pendingScrapPageNumber'] as num?)?.toInt(),
      pendingScrapText: json['pendingScrapText'] as String?,
      pendingScrapImagePath: json['pendingScrapImagePath'] as String?,
      pendingScrapTextRect: const PdfRectConverter().fromJson(
        json['pendingScrapTextRect'] as Map<String, dynamic>?,
      ),
      pendingScrapElementType: $enumDecodeNullable(
        _$ElementTypeEnumMap,
        json['pendingScrapElementType'],
      ),
      editingMarkerId: json['editingMarkerId'] as String?,
      pendingMarkerPageNumber: (json['pendingMarkerPageNumber'] as num?)
          ?.toInt(),
      pendingMarkerText: json['pendingMarkerText'] as String?,
      pendingMarkerTextRect: const PdfRectConverter().fromJson(
        json['pendingMarkerTextRect'] as Map<String, dynamic>?,
      ),
    );

Map<String, dynamic> _$$WorkspaceStateImplToJson(
  _$WorkspaceStateImpl instance,
) => <String, dynamic>{
  'currentPdfPath': instance.currentPdfPath,
  'currentNoteId': instance.currentNoteId,
  'markers': instance.markers.map((e) => e.toJson()).toList(),
  'openPdfPaths': instance.openPdfPaths,
  'panelSizes': instance.panelSizes.toJson(),
  'sidebarMode': _$SidebarModeEnumMap[instance.sidebarMode]!,
  'isEditorModalOpen': instance.isEditorModalOpen,
  'isFileBrowserOpen': instance.isFileBrowserOpen,
  'isMarkerEditModalOpen': instance.isMarkerEditModalOpen,
  'isStickyNoteVisible': instance.isStickyNoteVisible,
  'isPageNavOpen': instance.isPageNavOpen,
  'isLiveScrapsOpen': instance.isLiveScrapsOpen,
  'focusedPanel': _$FocusedPanelEnumMap[instance.focusedPanel]!,
  'isLayoutSwapped': instance.isLayoutSwapped,
  'selectedScrapIds': instance.selectedScrapIds.toList(),
  'isQuickScrapMode': instance.isQuickScrapMode,
  'isScrapBoardOpen': instance.isScrapBoardOpen,
  'pendingScrapPageNumber': instance.pendingScrapPageNumber,
  'pendingScrapText': instance.pendingScrapText,
  'pendingScrapImagePath': instance.pendingScrapImagePath,
  'pendingScrapTextRect': const PdfRectConverter().toJson(
    instance.pendingScrapTextRect,
  ),
  'pendingScrapElementType':
      _$ElementTypeEnumMap[instance.pendingScrapElementType],
  'editingMarkerId': instance.editingMarkerId,
  'pendingMarkerPageNumber': instance.pendingMarkerPageNumber,
  'pendingMarkerText': instance.pendingMarkerText,
  'pendingMarkerTextRect': const PdfRectConverter().toJson(
    instance.pendingMarkerTextRect,
  ),
};

const _$SidebarModeEnumMap = {
  SidebarMode.fileBrowser: 'fileBrowser',
  SidebarMode.elementNavigator: 'elementNavigator',
};

const _$FocusedPanelEnumMap = {
  FocusedPanel.pdf: 'pdf',
  FocusedPanel.scrapnote: 'scrapnote',
};

const _$ElementTypeEnumMap = {
  ElementType.highlight: 'highlight',
  ElementType.capture: 'capture',
  ElementType.drawing: 'drawing',
  ElementType.lasso: 'lasso',
};
