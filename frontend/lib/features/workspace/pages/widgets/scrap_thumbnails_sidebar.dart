import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/note_scrap_provider.dart';
import '../providers/workspace_provider.dart';

/// Left sidebar showing ScrapNote page thumbnails.
///
/// 기획안 슬라이드 1: 좌측에 페이지별 스크랩 썸네일 세로 목록.
/// Each entry shows a mini preview of scraps on that page.
class ScrapThumbnailsSidebar extends ConsumerStatefulWidget {
  const ScrapThumbnailsSidebar({
    super.key,
    this.width = 140,
    this.onPageTap,
    this.onElementTap,
    this.capturesDir,
    this.canvasOrder,
  });

  final double width;
  final void Function(int page)? onPageTap;
  final void Function(String elementId)? onElementTap;
  final String? capturesDir;
  /// Canvas-provided element order (y→x sorted). If set, overrides provider order.
  final List<String>? canvasOrder;

  @override
  ConsumerState<ScrapThumbnailsSidebar> createState() =>
      _ScrapThumbnailsSidebarState();
}

enum _SidebarTab { all, capture, highlight }

class _FlatEntry {
  final Widget widget;
  _FlatEntry({required this.widget});
}

class _SidebarItem {
  final List<ScrapElement> elements;
  final bool isGroup;
  final int groupIndex;

  _SidebarItem({
    required this.elements,
    this.isGroup = false,
    this.groupIndex = 0,
  });
}

class _ScrapThumbnailsSidebarState
    extends ConsumerState<ScrapThumbnailsSidebar> {
  _SidebarTab _currentTab = _SidebarTab.all;
  final Set<int> _expandedGroups = {}; // group indices that are expanded

  List<ScrapElement> _filterElements(List<ScrapElement> elements) {
    switch (_currentTab) {
      case _SidebarTab.all:
        return elements;
      case _SidebarTab.capture:
        return elements
            .where((e) =>
                e.type == ElementType.capture || e.type == ElementType.lasso)
            .toList();
      case _SidebarTab.highlight:
        return elements
            .where((e) => e.type == ElementType.highlight)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final ws = ref.watch(workspaceProviderProvider).valueOrNull;
    final noteId = ws?.currentNoteId;
    // Use same provider as canvas for consistent element IDs
    final allElements = noteId != null
        ? ref.watch(noteScrapProvider(noteId))
        : ref.read(elementStoreProvider.notifier).all();
    var elements = allElements.toList();
    // If canvas provides order, sort elements to match
    if (widget.canvasOrder != null && widget.canvasOrder!.isNotEmpty) {
      final orderMap = <String, int>{};
      for (var i = 0; i < widget.canvasOrder!.length; i++) {
        orderMap[widget.canvasOrder![i]] = i;
      }
      elements.sort((a, b) {
        final ai = orderMap[a.id] ?? 999;
        final bi = orderMap[b.id] ?? 999;
        return ai.compareTo(bi);
      });
    }
    final filtered = _filterElements(elements);

    if (ws == null) return const SizedBox.shrink();

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
          // ─── Tab bar ───
          Container(
            height: 30,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                _buildTab(theme, _SidebarTab.all, '전체',
                    elements.length),
                _buildTab(theme, _SidebarTab.capture, '캡처',
                    elements
                        .where((e) =>
                            e.type == ElementType.capture ||
                            e.type == ElementType.lasso)
                        .length),
                _buildTab(theme, _SidebarTab.highlight, '하이라이트',
                    elements
                        .where((e) => e.type == ElementType.highlight)
                        .length),
              ],
            ),
          ),

          // ─── Flat list (markdown order) ───
          Expanded(
            child: filtered.isEmpty
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
                    itemCount: _buildFlatList(filtered, ws.scrapGroups).length,
                    itemBuilder: (context, index) {
                      final flatItems = _buildFlatList(filtered, ws.scrapGroups);
                      final entry = flatItems[index];
                      return entry.widget;
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Flat list entry for ListView
  List<_FlatEntry> _buildFlatList(
      List<ScrapElement> filtered, List<List<String>> groups) {
    final items = _buildSidebarItems(filtered, groups);
    final entries = <_FlatEntry>[];
    var orderIdx = 1;

    for (final item in items) {
      if (item.isGroup) {
        final isExpanded = _expandedGroups.contains(item.groupIndex);
        final selectedIds = ref.read(workspaceProviderProvider).valueOrNull?.selectedScrapIds ?? {};
        final isAnySelected = item.elements.any((e) => selectedIds.contains(e.id));

        // Group header (always visible)
        entries.add(_FlatEntry(widget: _buildGroupHeader(
          item, isExpanded, isAnySelected, orderIdx,
        )));

        // Children (only when expanded)
        if (isExpanded) {
          for (final el in item.elements) {
            entries.add(_FlatEntry(widget: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _ScrapMiniPreview(
                element: el,
                theme: ShadTheme.of(context),
                orderIndex: orderIdx,
                isSelected: selectedIds.contains(el.id),
                isGrouped: true,
                onTap: () {
                  ref.read(workspaceProviderProvider.notifier)
                      .toggleScrapSelection(el.id);
                  widget.onElementTap?.call(el.id);
                },
                capturesDir: widget.capturesDir,
              ),
            )));
          }
        }
        orderIdx++;
      } else {
        final el = item.elements.first;
        final selectedIds = ref.read(workspaceProviderProvider).valueOrNull?.selectedScrapIds ?? {};
        entries.add(_FlatEntry(widget: _ScrapMiniPreview(
          element: el,
          theme: ShadTheme.of(context),
          orderIndex: orderIdx,
          isSelected: selectedIds.contains(el.id),
          isGrouped: false,
          onTap: () {
            ref.read(workspaceProviderProvider.notifier)
                .toggleScrapSelection(el.id);
            widget.onElementTap?.call(el.id);
          },
          capturesDir: widget.capturesDir,
        )));
        orderIdx++;
      }
    }
    return entries;
  }

  Widget _buildGroupHeader(
      _SidebarItem item, bool isExpanded, bool isAnySelected, int orderIdx) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedGroups.remove(item.groupIndex);
          } else {
            _expandedGroups.add(item.groupIndex);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: isAnySelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(
              color: isAnySelected
                  ? theme.colorScheme.primary
                  : Colors.blue.shade400,
              width: isAnySelected ? 3 : 2,
            ),
          ),
        ),
        child: Row(
          children: [
            // Expand/collapse arrow
            Icon(
              isExpanded ? Icons.expand_more : Icons.chevron_right,
              size: 12,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 2),
            // Order badge
            Container(
              width: 14, height: 14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('$orderIdx',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700)),
            ),
            const SizedBox(width: 3),
            Icon(Icons.layers, size: 11, color: Colors.blue.shade400),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Group ${item.groupIndex} (${item.elements.length})',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build merged sidebar items — grouped elements collapse into one entry.
  List<_SidebarItem> _buildSidebarItems(
      List<ScrapElement> filtered, List<List<String>> groups) {
    final items = <_SidebarItem>[];
    final consumed = <String>{};

    for (final el in filtered) {
      if (consumed.contains(el.id)) continue;

      // Check if this element belongs to a group
      List<String>? group;
      int? groupIdx;
      for (var gi = 0; gi < groups.length; gi++) {
        if (groups[gi].contains(el.id)) {
          group = groups[gi];
          groupIdx = gi;
          break;
        }
      }

      if (group != null) {
        // Collect all group members that are in filtered
        final groupElements = filtered
            .where((e) => group!.contains(e.id))
            .toList();
        for (final ge in groupElements) {
          consumed.add(ge.id);
        }
        items.add(_SidebarItem(
          elements: groupElements,
          isGroup: true,
          groupIndex: groupIdx! + 1,
        ));
      } else {
        consumed.add(el.id);
        items.add(_SidebarItem(elements: [el]));
      }
    }
    return items;
  }

  Widget _buildTab(
      ShadThemeData theme, _SidebarTab tab, String label, int count) {
    final isActive = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = tab),
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
            '$label $count',
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground,
            ),
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
    required this.orderIndex,
    this.isSelected = false,
    this.isGrouped = false,
    this.onTap,
    this.capturesDir,
  });
  final ScrapElement element;
  final ShadThemeData theme;
  final int orderIndex;
  final bool isSelected;
  final bool isGrouped;
  final VoidCallback? onTap;
  final String? capturesDir;

  String? get _resolvedImagePath {
    final img = element.imagePath;
    if (img == null || img.isEmpty) return null;
    if (p.isAbsolute(img)) {
      if (File(img).existsSync()) return img;
      return null;
    }
    if (capturesDir != null) {
      final resolved = p.join(capturesDir!, img);
      if (File(resolved).existsSync()) return resolved;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCapture = element.type == ElementType.capture;
    final isLasso = element.type == ElementType.lasso;
    final text = element.selectedText;
    final imgPath = _resolvedImagePath;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                      : Colors.green,
              width: isSelected ? 3 : 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Order number badge
                Container(
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '$orderIndex',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  isCapture
                      ? Icons.crop_rounded
                      : isLasso
                          ? Icons.gesture
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
                            : isLasso
                                ? 'Lasso'
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
            if (imgPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.file(
                    File(imgPath),
                    width: double.infinity,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
