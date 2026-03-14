import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../../pdf_viewer/drawing/pages/widgets/drawing_toolbar_widgets.dart';
import '../../../scrapnote/models/scrapnote_canvas_model.dart';
import '../../../scrapnote/pages/providers/scrapnote_canvas_provider.dart';
import '../../../scrapnote/pages/widgets/scrapnote_canvas.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../providers/workspace_provider.dart';

// @MX:NOTE: [AUTO] ScrapnotePanel is the side-panel replacement for LiveScrapsPanel.
// Uses local StatefulWidget state for drawing mode — completely isolated from PDF drawingModeProvider.

/// Compact scrapnote canvas panel embedded in the workspace right sidebar.
///
/// Drawing state is managed locally via [_ScrapnotePanelState] — it does NOT
/// share [drawingModeProvider] used by the PDF drawing overlay.
///
/// When [isSheet] is true the panel renders without the fixed-width sidebar
/// chrome (used for the mobile bottom-sheet variant).
class ScrapnotePanel extends ConsumerStatefulWidget {
  const ScrapnotePanel({
    super.key,
    this.isSheet = false,
    this.onElementTap,
  });

  final bool isSheet;
  final void Function(CanvasElement element)? onElementTap;

  @override
  ConsumerState<ScrapnotePanel> createState() => _ScrapnotePanelState();
}

class _ScrapnotePanelState extends ConsumerState<ScrapnotePanel> {
  // --- Local drawing state (isolated from PDF drawingModeProvider) ---
  bool _isDrawingActive = false;
  String _currentToolId = 'pen';
  int _colorValue = 0xFF000000;
  double _strokeSize = 3.0;

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(workspaceProviderProvider).valueOrNull;

    // Derive scrapnoteId from the current PDF path via pdfRegistryProv
    String? scrapnoteId;
    if (workspaceState?.currentPdfPath != null) {
      scrapnoteId = ref
          .read(pdfRegistryProvProvider.notifier)
          .getIdByPath(workspaceState!.currentPdfPath!);
    }

    if (widget.isSheet) {
      return _buildSheetLayout(scrapnoteId);
    }
    return _buildSidebarLayout(scrapnoteId);
  }

  // ─── Sidebar layout (desktop right panel) ─────────────────

  Widget _buildSidebarLayout(String? scrapnoteId) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isDrawingActive) _buildToolbar(),
          Expanded(child: _buildCanvas(scrapnoteId)),
        ],
      ),
    );
  }

  // ─── Sheet layout (mobile bottom-sheet) ───────────────────

  Widget _buildSheetLayout(String? scrapnoteId) {
    return Column(
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        _buildHeader(),
        if (_isDrawingActive) _buildToolbar(),
        Expanded(child: _buildCanvas(scrapnoteId)),
      ],
    );
  }

  // ─── Header ───────────────────────────────────────────────

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
            'SCRAPNOTE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // Toggle drawing mode button
          GestureDetector(
            onTap: () {
              setState(() {
                _isDrawingActive = !_isDrawingActive;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _isDrawingActive
                    ? AppColors.primaryLight
                    : AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isDrawingActive
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: _isDrawingActive
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _isDrawingActive ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _isDrawingActive
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Compact toolbar ──────────────────────────────────────

  static const _tools = [
    (id: 'pen', icon: Icons.edit_rounded, label: 'Pen'),
    (id: 'highlighter', icon: Icons.format_color_fill_rounded, label: 'Highlight'),
    (id: 'eraser', icon: Icons.auto_fix_high_rounded, label: 'Eraser'),
  ];

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Tool buttons (shared ToolbarIconButton, compact mode)
          for (final tool in _tools)
            ToolbarIconButton(
              icon: tool.icon,
              tooltip: tool.label,
              isActive: _currentToolId == tool.id,
              onTap: () => setState(() => _currentToolId = tool.id),
              compact: true,
            ),
          const ToolbarDivider(compact: true),
          // Color swatches (shared ToolbarColorDot, compact mode)
          for (final color in kCompactPaletteColors)
            ToolbarColorDot(
              color: Color(color),
              isSelected: _colorValue == color,
              onTap: () => setState(() => _colorValue = color),
              compact: true,
            ),
          const ToolbarDivider(compact: true),
          // Size buttons (shared ToolbarSizeDot, compact mode)
          for (final size in kCompactStrokeSizes)
            ToolbarSizeDot(
              strokeSize: size,
              isSelected: _strokeSize == size,
              onTap: () => setState(() => _strokeSize = size),
              compact: true,
            ),
        ],
      ),
    );
  }

  // ─── Canvas area ──────────────────────────────────────────

  Widget _buildCanvas(String? scrapnoteId) {
    if (scrapnoteId == null) {
      return _buildNoPdfPlaceholder();
    }

    return _ScrapnoteCanvasConsumer(
      scrapnoteId: scrapnoteId,
      isDrawingActive: _isDrawingActive,
      toolId: _currentToolId,
      colorValue: _colorValue,
      strokeSize: _strokeSize,
    );
  }

  Widget _buildNoPdfPlaceholder() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 32,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 8),
            Text(
              'No PDF loaded',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Open a PDF to start your scrapnote canvas',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Canvas consumer (watches provider for a given scrapnoteId) ───────────

class _ScrapnoteCanvasConsumer extends ConsumerWidget {
  const _ScrapnoteCanvasConsumer({
    required this.scrapnoteId,
    required this.isDrawingActive,
    required this.toolId,
    required this.colorValue,
    required this.strokeSize,
  });

  final String scrapnoteId;
  final bool isDrawingActive;
  final String toolId;
  final int colorValue;
  final double strokeSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasAsync =
        ref.watch(scrapnoteCanvasStateProvider(scrapnoteId));

    return canvasAsync.when(
      data: (canvasData) {
        return ClipRect(
          child: ScrapnoteCanvas(
            strokes: canvasData.strokes,
            elements: canvasData.elements,
            isActive: isDrawingActive,
            onStrokeCompleted: (stroke) {
              ref
                  .read(scrapnoteCanvasStateProvider(scrapnoteId).notifier)
                  .addStroke(stroke);
            },
            toolId: toolId,
            colorValue: colorValue,
            strokeSize: strokeSize,
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Failed to load canvas: $e',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Old helper widgets (_ToolConfig, _ColorConfig, _SizeConfig, _ToolButton,
// _ColorSwatch, _SizeButton) removed — replaced by shared components from
// drawing_toolbar_widgets.dart (ToolbarIconButton, ToolbarColorDot,
// ToolbarSizeDot, ToolbarDivider).
