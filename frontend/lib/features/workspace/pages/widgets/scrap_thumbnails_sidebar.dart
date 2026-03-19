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

class _ScrapThumbnailsSidebarState
    extends ConsumerState<ScrapThumbnailsSidebar> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final ws = ref.watch(workspaceProviderProvider).valueOrNull;
    final noteId = ws?.currentNoteId;
    // Use same provider as canvas for consistent element IDs
    final allElements = noteId != null
        ? ref.watch(noteScrapProvider(noteId))
        : ref.read(elementStoreProvider.notifier).all();
    var elements = allElements
        .where((e) => e.type == ElementType.capture || e.type == ElementType.lasso)
        .toList();
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
          // ─── Header: count ───
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                Text('Scraps',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground)),
                const SizedBox(width: 4),
                Text('${elements.length}',
                    style: TextStyle(
                        fontSize: 9,
                        color: theme.colorScheme.mutedForeground)),
              ],
            ),
          ),

          // ─── Flat list (markdown order) ───
          Expanded(
            child: elements.isEmpty
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
                    itemCount: elements.length,
                    itemBuilder: (context, index) {
                      final el = elements[index];
                      return _ScrapMiniPreview(
                        element: el,
                        theme: theme,
                        isSelected: selectedIds.contains(el.id),
                        onTap: widget.onElementTap != null
                            ? () => widget.onElementTap!(el.id)
                            : null,
                        capturesDir: widget.capturesDir,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScrapMiniPreview extends StatelessWidget {
  const _ScrapMiniPreview({
    required this.element,
    required this.theme,
    this.isSelected = false,
    this.onTap,
    this.capturesDir,
  });
  final ScrapElement element;
  final ShadThemeData theme;
  final bool isSelected;
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
