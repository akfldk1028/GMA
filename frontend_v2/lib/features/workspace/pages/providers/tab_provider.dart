import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/open_pdf_tab.dart';

part 'tab_provider.g.dart';

class TabBarState {
  const TabBarState({
    this.tabs = const [],
    this.activeIndex = 0,
  });

  final List<OpenPdfTab> tabs;
  final int activeIndex;

  OpenPdfTab? get activeTab =>
      tabs.isNotEmpty && activeIndex >= 0 && activeIndex < tabs.length
          ? tabs[activeIndex]
          : null;

  bool get showTabBar => tabs.length > 1;

  TabBarState copyWith({
    List<OpenPdfTab>? tabs,
    int? activeIndex,
  }) {
    return TabBarState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

// @MX:ANCHOR: Primary tab state provider — accessed by PdfTabBar, PanelManager, and WorkspaceScreen
// @MX:REASON: fan_in >= 3 callers
@Riverpod(keepAlive: true)
class TabProvider extends _$TabProvider {
  @override
  TabBarState build() => const TabBarState();

  /// Adds a new tab or activates an existing one with the same [pdfPath].
  OpenPdfTab addTab(String pdfPath) {
    final existing = state.tabs.indexWhere((t) => t.path == pdfPath);
    if (existing != -1) {
      state = state.copyWith(activeIndex: existing);
      return state.tabs[existing];
    }

    final tab = OpenPdfTab(
      path: pdfPath,
      title: p.basenameWithoutExtension(pdfPath),
    );
    final newTabs = List<OpenPdfTab>.from(state.tabs)..add(tab);
    state = state.copyWith(tabs: newTabs, activeIndex: newTabs.length - 1);
    return tab;
  }

  /// Switches to the tab at [index]. Returns the tab, or null if invalid.
  OpenPdfTab? switchTab(int index) {
    if (index < 0 || index >= state.tabs.length) return null;
    state = state.copyWith(activeIndex: index);
    return state.tabs[index];
  }

  /// Closes the tab at [index]. Returns the removed tab, or null if invalid.
  OpenPdfTab? closeTab(int index) {
    if (index < 0 || index >= state.tabs.length) return null;
    final removed = state.tabs[index];
    final newTabs = List<OpenPdfTab>.from(state.tabs)..removeAt(index);
    int newIndex = state.activeIndex;
    if (newTabs.isEmpty) {
      newIndex = 0;
    } else if (newIndex >= newTabs.length) {
      newIndex = newTabs.length - 1;
    }
    state = state.copyWith(tabs: newTabs, activeIndex: newIndex);
    return removed;
  }

  /// Updates the page number for the currently active tab.
  void updateActiveTabPage(int pageNumber) {
    final active = state.activeTab;
    if (active == null) return;
    final updated = active.copyWith(lastPageNumber: pageNumber);
    final newTabs = List<OpenPdfTab>.from(state.tabs);
    newTabs[state.activeIndex] = updated;
    state = state.copyWith(tabs: newTabs);
  }
}
