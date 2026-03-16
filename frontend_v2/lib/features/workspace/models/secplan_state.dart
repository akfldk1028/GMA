import 'package:freezed_annotation/freezed_annotation.dart';

part 'secplan_state.freezed.dart';

enum MaximizedPanel { none, left, right }

enum FocusedPanel { left, right }

@freezed
class SecPlanPanelState with _$SecPlanPanelState {
  const factory SecPlanPanelState({
    @Default(0.5) double panelRatio,
    @Default(false) bool isSwapped,
    @Default(MaximizedPanel.none) MaximizedPanel maximizedPanel,
    @Default(FocusedPanel.left) FocusedPanel focusedPanel,
    @Default(true) bool isRightPanelVisible,
  }) = _SecPlanPanelState;
}
