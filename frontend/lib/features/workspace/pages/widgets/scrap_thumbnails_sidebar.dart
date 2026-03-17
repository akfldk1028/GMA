import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../providers/workspace_provider.dart';

/// Left sidebar showing ScrapNote page thumbnails.
///
/// 기획안 슬라이드 1: 좌측에 페이지별 스크랩 썸네일 세로 목록.
/// Each entry shows a mini preview of scraps on that page.
/// Sidebar tab mode per 기획안 슬라이드 1 (연결/삽입/편)
enum _SidebarTab { linked, insert, edit }

class ScrapThumbnailsSidebar extends ConsumerStatefulWidget {
  const ScrapThumbnailsSidebar({
    super.key,
    this.width = 140,
    this.onPageTap,
  });

  final double width;
  final void Function(int page)? onPageTap;

  @override
  ConsumerState<ScrapThumbnailsSidebar> createState() =>
      _ScrapThumbnailsSidebarState();
}

class _ScrapThumbnailsSidebarState
    extends ConsumerState<ScrapThumbnailsSidebar> {
  _SidebarTab _currentTab = _SidebarTab.linked;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final ws = ref.watch(workspaceProviderProvider).valueOrNull;
    ref.watch(elementStoreProvider);
    final elements = ref.read(elementStoreProvider.notifier).all();
    final selectedIds = ws?.selectedScrapIds ?? {};

    if (ws == null) return const SizedBox.shrink();

    final pageMap = <int, List<ScrapElement>>{};
    for (final el in elements) {
      pageMap.putIfAbsent(el.pageNumber, () => []).add(el);
    }
    final sortedPages = pageMap.keys.toList()..sort();

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          right: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Column(
        children: [
          // ─── 3-tab header (연결/삽입/편) ───
          _SidebarTabBar(
            theme: theme,
            currentTab: _currentTab,
            onTabChanged: (tab) => setState(() => _currentTab = tab),
          ),

          // ─── Tab content ───
          Expanded(
            child: sortedPages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No scraps yet',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 6),
                    itemCount: sortedPages.length,
                    itemBuilder: (context, index) {
                      final page = sortedPages[index];
                      final scraps = pageMap[page]!;
                      return _PageThumbnailCard(
                        pageNumber: page,
                        scrapCount: scraps.length,
                        scraps: scraps,
                        selectedIds: selectedIds,
                        onTap: () => widget.onPageTap?.call(page),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTabBar extends StatelessWidget {
  const _SidebarTabBar({
    required this.theme,
    required this.currentTab,
    required this.onTabChanged,
  });

  final ShadThemeData theme;
  final _SidebarTab currentTab;
  final void Function(_SidebarTab) onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Linked',
            isActive: currentTab == _SidebarTab.linked,
            onTap: () => onTabChanged(_SidebarTab.linked),
            theme: theme,
          ),
          _TabItem(
            label: 'Insert',
            isActive: currentTab == _SidebarTab.insert,
            onTap: () => onTabChanged(_SidebarTab.insert),
            theme: theme,
          ),
          _TabItem(
            label: 'Edit',
            isActive: currentTab == _SidebarTab.edit,
            onTap: () => onTabChanged(_SidebarTab.edit),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

class _PageThumbnailCard extends StatelessWidget {
  const _PageThumbnailCard({
    required this.pageNumber,
    required this.scrapCount,
    required this.scraps,
    required this.selectedIds,
    required this.onTap,
  });

  final int pageNumber;
  final int scrapCount;
  final List<ScrapElement> scraps;
  final Set<String> selectedIds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page label + count badge
              Row(
                children: [
                  Text(
                    'P$pageNumber',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$scrapCount',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Scrap content previews (show first 3, with selection highlight)
              for (var i = 0; i < scraps.length && i < 3; i++)
                _ScrapMiniPreview(
                  element: scraps[i],
                  theme: theme,
                  isSelected: selectedIds.contains(scraps[i].id),
                ),
              if (scrapCount > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '+${scrapCount - 3} more',
                    style: TextStyle(
                      fontSize: 8,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrapMiniPreview extends StatelessWidget {
  const _ScrapMiniPreview({
    required this.element,
    required this.theme,
    this.isSelected = false,
  });
  final ScrapElement element;
  final ShadThemeData theme;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isCapture = element.type == ElementType.capture;
    final text = element.selectedText;

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : isCapture
                    ? Colors.amber
                    : element.type == ElementType.drawing
                        ? Colors.blue
                        : Colors.green,
            width: isSelected ? 3 : 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCapture
                ? Icons.crop_rounded
                : element.type == ElementType.drawing
                    ? Icons.draw_rounded
                    : Icons.highlight_rounded,
            size: 9,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text != null && text.isNotEmpty
                  ? text
                  : isCapture
                      ? 'Capture'
                      : 'Scrap',
              style: TextStyle(
                fontSize: 8,
                color: theme.colorScheme.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
