import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sidebar_provider.g.dart';

enum SidebarFilter { all, capture, highlight, pen }

class SidebarState {
  const SidebarState({
    this.filter = SidebarFilter.all,
    this.isOpen = true,
  });

  final SidebarFilter filter;
  final bool isOpen;

  SidebarState copyWith({
    SidebarFilter? filter,
    bool? isOpen,
  }) {
    return SidebarState(
      filter: filter ?? this.filter,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

@Riverpod(keepAlive: true)
class SidebarProvider extends _$SidebarProvider {
  @override
  SidebarState build() => const SidebarState();

  void setFilter(SidebarFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void toggleSidebar() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  /// Returns filtered elements. Empty list until scrapnote is implemented.
  List<dynamic> getFilteredElements() => const [];

  /// Human-readable label for a [SidebarFilter] value.
  static String getElementLabel(SidebarFilter filter) {
    switch (filter) {
      case SidebarFilter.all:
        return 'All';
      case SidebarFilter.capture:
        return 'Capture';
      case SidebarFilter.highlight:
        return 'Highlight';
      case SidebarFilter.pen:
        return 'Pen';
    }
  }
}
