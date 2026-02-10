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
      panelSizes: json['panelSizes'] == null
          ? const PanelSizes()
          : PanelSizes.fromJson(json['panelSizes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WorkspaceStateImplToJson(
  _$WorkspaceStateImpl instance,
) => <String, dynamic>{
  'currentPdfPath': instance.currentPdfPath,
  'currentNoteId': instance.currentNoteId,
  'markers': instance.markers,
  'panelSizes': instance.panelSizes,
};
