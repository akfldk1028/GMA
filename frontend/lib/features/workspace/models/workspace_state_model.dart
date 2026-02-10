import 'package:freezed_annotation/freezed_annotation.dart';
import '../../note_editor/models/note_model.dart';

part 'workspace_state_model.freezed.dart';
part 'workspace_state_model.g.dart';

@freezed
class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState({
    Note? currentNote,
    String? currentPdf,
    required Map<String, double> panelSizes,
  }) = _WorkspaceState;

  factory WorkspaceState.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceStateFromJson(json);
}
