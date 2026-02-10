// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkspaceStateImpl _$$WorkspaceStateImplFromJson(Map<String, dynamic> json) =>
    _$WorkspaceStateImpl(
      currentNote: json['currentNote'] == null
          ? null
          : Note.fromJson(json['currentNote'] as Map<String, dynamic>),
      currentPdf: json['currentPdf'] as String?,
      panelSizes: (json['panelSizes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$$WorkspaceStateImplToJson(
  _$WorkspaceStateImpl instance,
) => <String, dynamic>{
  'currentNote': instance.currentNote,
  'currentPdf': instance.currentPdf,
  'panelSizes': instance.panelSizes,
};
