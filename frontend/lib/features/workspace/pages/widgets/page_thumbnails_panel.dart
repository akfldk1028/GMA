import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../../constants/app_colors.dart';

class PageThumbnailsPanel extends StatefulWidget {
  const PageThumbnailsPanel({
    required this.controller,
    this.isSheet = false,
    super.key,
  });

  final PdfViewerController controller;
  final bool isSheet;

  @override
  State<PageThumbnailsPanel> createState() => _PageThumbnailsPanelState();
}

class _PageThumbnailsPanelState extends State<PageThumbnailsPanel> {
  int _currentPage = 1;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _syncFromController();
  }

  @override
  void didUpdateWidget(covariant PageThumbnailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _syncFromController();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    _syncFromController();
  }

  void _syncFromController() {
    final newPage = widget.controller.isReady ? (widget.controller.pageNumber ?? 1) : 1;
    final newCount = widget.controller.isReady ? widget.controller.pageCount : 0;
    if (newPage != _currentPage || newCount != _pageCount) {
      setState(() {
        _currentPage = newPage;
        _pageCount = newCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSheet) return _buildSheetLayout();
    return _buildSidebarLayout();
  }

  Widget _buildSidebarLayout() {
    return Container(
      width: 180,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildPageList(Axis.vertical)),
        ],
      ),
    );
  }

  Widget _buildSheetLayout() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildPageGrid()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'PAGES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            '$_pageCount',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageList(Axis axis) {
    if (_pageCount == 0) {
      return const Center(
        child: Text(
          'No PDF loaded',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _pageCount,
      itemBuilder: (context, index) => _buildPageTile(index + 1),
    );
  }

  Widget _buildPageGrid() {
    if (_pageCount == 0) {
      return const Center(
        child: Text(
          'No PDF loaded',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: _pageCount,
      itemBuilder: (context, index) => _buildPageTile(index + 1),
    );
  }

  Widget _buildPageTile(int pageNum) {
    final isActive = pageNum == _currentPage;
    return Padding(
      key: ValueKey(pageNum),
      padding: widget.isSheet ? EdgeInsets.zero : const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            widget.controller.goToPage(pageNumber: pageNum);
            if (widget.isSheet) Navigator.of(context).pop();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: widget.isSheet ? null : 120,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryLight
                  : AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                    : AppColors.border,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 28,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                const SizedBox(height: 4),
                Text(
                  '$pageNum',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
