import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';

import '../../../../utils/file_system_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/note_scrap_provider.dart';
import '../../../scrapnote/widgets/pdf_region_image.dart';

/// Workspace scrap panel — chronological flat list with PDF region crops.
///
/// Per 기획안: 시간순 리스트 (페이지 그룹 없음).
/// P1 → P5 → P1 순서로 필기하면 그 순서 그대로 표시.
/// 각 엔트리는 PDF 영역 크롭 + 하이라이트 오버레이.
/// 탭하면 PDF 해당 페이지로 점프.
class WorkspaceCanvasPanel extends ConsumerStatefulWidget {
  const WorkspaceCanvasPanel({
    super.key,
    required this.noteId,
    required this.pdfPath,
    required this.onNavigateToPage,
    required this.pdfController,
  });

  final String? noteId;
  final String? pdfPath;
  final void Function(int pageNumber) onNavigateToPage;
  final PdfViewerController pdfController;

  @override
  ConsumerState<WorkspaceCanvasPanel> createState() =>
      _WorkspaceCanvasPanelState();
}

class _WorkspaceCanvasPanelState extends ConsumerState<WorkspaceCanvasPanel> {
  _FilterType _filter = _FilterType.all;
  PdfPageImageCache? _pageCache;

  @override
  void initState() {
    super.initState();
    _pageCache = PdfPageImageCache(widget.pdfController);
  }

  @override
  void didUpdateWidget(WorkspaceCanvasPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfController != widget.pdfController ||
        oldWidget.pdfPath != widget.pdfPath) {
      _pageCache?.dispose();
      _pageCache = PdfPageImageCache(widget.pdfController);
    }
  }

  @override
  void dispose() {
    _pageCache?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elements = widget.noteId != null
        ? ref.watch(noteScrapProvider(widget.noteId!))
        : <ScrapElement>[];

    final capturesDir =
        ref.watch(capturesDirectoryProvider).valueOrNull?.path;

    final filtered = _applyFilter(elements);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _CanvasHeader(
            filter: _filter,
            totalCount: elements.length,
            onFilterChanged: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 24),
                    cacheExtent: 200,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final el = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _ScrapEntry(
                          element: el,
                          index: index + 1,
                          capturesDir: capturesDir,
                          pageCache: _pageCache!,
                          onTap: () =>
                              widget.onNavigateToPage(el.pageNumber),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<ScrapElement> _applyFilter(List<ScrapElement> elements) {
    switch (_filter) {
      case _FilterType.all:
        return elements;
      case _FilterType.capture:
        return elements
            .where((e) =>
                e.type == ElementType.capture ||
                e.type == ElementType.drawing)
            .toList();
      case _FilterType.highlight:
        return elements
            .where((e) => e.type == ElementType.highlight)
            .toList();
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_add_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('ScrapNote',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text(
            'Select text or capture an area\nin the PDF to add scraps',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Filter ──────────────────────────────────────

enum _FilterType { all, capture, highlight }

class _CanvasHeader extends StatelessWidget {
  const _CanvasHeader({
    required this.filter,
    required this.totalCount,
    required this.onFilterChanged,
  });

  final _FilterType filter;
  final int totalCount;
  final ValueChanged<_FilterType> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _chip('All', filter == _FilterType.all,
              () => onFilterChanged(_FilterType.all)),
          const SizedBox(width: 4),
          _chip('Capture', filter == _FilterType.capture,
              () => onFilterChanged(_FilterType.capture)),
          const SizedBox(width: 4),
          _chip('Text', filter == _FilterType.highlight,
              () => onFilterChanged(_FilterType.highlight)),
          const Spacer(),
          Text('$totalCount',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.black87 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade600)),
      ),
    );
  }
}

// ─── Scrap entry: PDF region crop + text ─────────

class _ScrapEntry extends StatelessWidget {
  const _ScrapEntry({
    required this.element,
    required this.index,
    this.capturesDir,
    required this.pageCache,
    this.onTap,
  });

  final ScrapElement element;
  final int index;
  final String? capturesDir;
  final PdfPageImageCache pageCache;
  final VoidCallback? onTap;

  String? get _resolvedImagePath {
    final img = element.imagePath;
    if (img == null || img.isEmpty || kIsWeb) return null;
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'P${element.pageNumber}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '#$index',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 3),
          // PDF region crop (if rect available)
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // PDF region crop with highlight overlay
    if (element.rect != null) {
      return PdfRegionImage(
        cache: pageCache,
        pageNumber: element.pageNumber,
        rect: element.rect!,
        capturePath: _resolvedImagePath,
        maxHeight: 160,
      );
    }

    // Capture image only (no rect)
    final imgPath = _resolvedImagePath;
    if (imgPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 160),
          child: Image.file(
            File(imgPath),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildTextOnly(),
          ),
        ),
      );
    }

    return _buildTextOnly();
  }

  Widget _buildTextOnly() {
    final text = element.selectedText;
    if (text == null || text.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border:
              Border(left: BorderSide(color: Colors.grey.shade300, width: 3)),
        ),
        child: Text('P${element.pageNumber} ${element.type.name}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        border:
            Border(left: BorderSide(color: Colors.amber.shade300, width: 3)),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, color: Colors.black87, height: 1.6)),
    );
  }
}
