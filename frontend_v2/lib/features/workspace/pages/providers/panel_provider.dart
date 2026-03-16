import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/secplan_state.dart';

part 'panel_provider.g.dart';

const _boxName = 'workspace_settings';
const _keyPrefix = 'panel_';

// @MX:ANCHOR: Primary panel state provider — accessed by PanelManager, SecPlanHeader, and KebabMenu
// @MX:REASON: fan_in >= 3 callers across workspace UI layer
@Riverpod(keepAlive: true)
class PanelProvider extends _$PanelProvider {
  @override
  SecPlanPanelState build() => const SecPlanPanelState();

  void setRatio(double ratio) {
    final clamped = ratio.clamp(0.25, 0.75);
    state = state.copyWith(panelRatio: clamped);
    _persist();
  }

  void swap() {
    state = state.copyWith(isSwapped: !state.isSwapped);
    _persist();
  }

  void maximize(MaximizedPanel panel) {
    state = state.copyWith(maximizedPanel: panel);
    _persist();
  }

  void restore() {
    state = state.copyWith(maximizedPanel: MaximizedPanel.none);
    _persist();
  }

  void setFocus(FocusedPanel panel) {
    state = state.copyWith(focusedPanel: panel);
  }

  void toggleRightPanel() {
    state = state.copyWith(isRightPanelVisible: !state.isRightPanelVisible);
    _persist();
  }

  Future<void> loadForDocument(String pdfPath) async {
    final key = _keyPrefix + p.basename(pdfPath);
    final box = await _openBox();
    final stored = box.get(key);
    if (stored is Map) {
      final ratio = (stored['panelRatio'] as num?)?.toDouble() ?? 0.5;
      final isSwapped = (stored['isSwapped'] as bool?) ?? false;
      final isRightVisible = (stored['isRightPanelVisible'] as bool?) ?? true;
      state = SecPlanPanelState(
        panelRatio: ratio.clamp(0.25, 0.75),
        isSwapped: isSwapped,
        isRightPanelVisible: isRightVisible,
      );
    } else {
      state = const SecPlanPanelState();
    }
  }

  Future<void> _persist() async {
    final box = await _openBox();
    // Store under a generic key for simplicity; per-document key set in loadForDocument
    await box.put('${_keyPrefix}current', {
      'panelRatio': state.panelRatio,
      'isSwapped': state.isSwapped,
      'isRightPanelVisible': state.isRightPanelVisible,
    });
  }

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return Hive.openBox(_boxName);
  }
}
