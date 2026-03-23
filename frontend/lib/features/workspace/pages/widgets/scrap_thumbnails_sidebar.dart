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
    final selectedIds = ws?.selectedScrapIds ?? {};

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
                    itemCount: _buildSidebarItems(filtered, ws?.scrapGroups ?? []).length,
                    itemBuilder: (context, index) {
                      final items = _buildSidebarItems(filtered, ws?.scrapGroups ?? []);
                      final item = items[index];
                      return item.isGroup
                          ? _buildGroupedPreview(
                              item, theme, selectedIds, ref, index + 1)
                          : _ScrapMiniPreview(
                              element: item.elements.first,
                              theme: theme,
                              orderIndex: index + 1,
                              isSelected: selectedIds.contains(item.elements.first.id),
                              isGrouped: false,
                              onTap: () {
                                ref.read(workspaceProviderProvider.notifier)
                                    .toggleScrapSelection(item.elements.first.id);
                                widget.onElementTap?.call(item.elements.first.id);
                              },
                              capturesDir: widget.capturesDir,
                            );
                    },
                  ),
          ),
        ],
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

  Widget _buildGroupedPreview(
      _SidebarItem item, ShadThemeData theme,
      Set<String> selectedIds, WidgetRef ref, int orderIndex) {
    final isAnySelected = item.elements.any((e) => selectedIds.contains(e.id));
    final firstEl = item.elements.first;
    final count = item.elements.length;

    return GestureDetector(
      onTap: () {
        // Select/deselect all group members
        final notifier = ref.read(workspaceProviderProvider.notifier);
        for (final el in item.elements) {
          if (!selectedIds.contains(el.id)) {
            notifier.toggleScrapSelection(el.id);
          }
        }
        widget.onElementTap?.call(firstEl.id);
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
            // Group order badge
            Container(
              width: 14,
              height: 14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '$orderIndex',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 3),
            // Stacked group icon
            Icon(Icons.layers, size: 11, color: Colors.blue.shade400),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Group ${item.groupIndex} ($count)',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
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
