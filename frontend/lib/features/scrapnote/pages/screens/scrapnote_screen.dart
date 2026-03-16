import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pdf_viewer/drawing/pages/providers/drawing_provider.dart';
import '../../../pdf_viewer/drawing/tools/tool_registry.dart';
import '../providers/scrapnote_canvas_provider.dart';
import '../widgets/scrapnote_canvas.dart';

/// Full-screen view for editing a scrapnote canvas.
///
/// Displays an [AppBar] with a back button and "Scrapnote" title,
/// a simplified drawing toolbar (pen/highlighter/eraser + color + size),
/// and the [ScrapnoteCanvas] taking up the remaining space.
///
/// Receives [scrapnoteId] as a parameter from routing.
// @MX:ANCHOR: [AUTO] ScrapnoteScreen — entry point for full-screen scrapnote editing. Routed via /scrapnote/:id.
// @MX:REASON: High fan_in — app_router.dart and any navigation entry point depend on this screen.
class ScrapnoteScreen extends ConsumerWidget {
  const ScrapnoteScreen({super.key, required this.scrapnoteId});

  final String scrapnoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasAsync = ref.watch(scrapnoteCanvasStateProvider(scrapnoteId));
    final drawingMode = ref.watch(drawingModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrapnote'),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Column(
        children: [
          // Drawing toolbar
          _ScrapnoteToolbar(scrapnoteId: scrapnoteId),
          // Canvas
          Expanded(
            child: canvasAsync.when(
              data: (data) => ScrapnoteCanvas(
                strokes: data.strokes,
                elements: data.elements,
                isActive: drawingMode.isActive,
                toolId: drawingMode.currentToolId,
                colorValue: drawingMode.colorValue,
                strokeSize: drawingMode.strokeSize,
                onStrokeCompleted: (stroke) {
                  ref
                      .read(scrapnoteCanvasStateProvider(scrapnoteId).notifier)
                      .addStroke(stroke);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error loading canvas: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simplified drawing toolbar for the scrapnote screen.
///
/// Shows: draw toggle, tool buttons (pen/highlighter/eraser), color palette, stroke sizes.
class _ScrapnoteToolbar extends ConsumerWidget {
  const _ScrapnoteToolbar({required this.scrapnoteId});

  final String scrapnoteId;

  static const _paletteColors = [
    0xFF000000, // black
    0xFFEF4444, // red
    0xFF3B82F6, // blue
    0xFF22C55E, // green
    0xFFEAB308, // yellow
  ];

  static const _strokeSizes = [2.0, 4.0, 8.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingMode = ref.watch(drawingModeProvider);
    final isActive = drawingMode.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Draw mode toggle
          InkWell(
            onTap: () => ref.read(drawingModeProvider.notifier).toggleActive(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.draw,
                size: 18,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          if (isActive) ...[
            _divider(context),
            // Tool buttons from registry
            for (final tool in drawingTools)
              InkWell(
                onTap: () => ref
                    .read(drawingModeProvider.notifier)
                    .selectTool(tool.id),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: drawingMode.currentToolId == tool.id
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tool.icon,
                    size: 18,
                    color: drawingMode.currentToolId == tool.id
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            _divider(context),
            // Color palette
            if (getToolById(drawingMode.currentToolId).supportsColor)
              for (final color in _paletteColors)
                GestureDetector(
                  onTap: () =>
                      ref.read(drawingModeProvider.notifier).setColor(color),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(color),
                      border: Border.all(
                        color: drawingMode.colorValue == color
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            if (getToolById(drawingMode.currentToolId).supportsColor)
              _divider(context),
            // Stroke size
            for (final size in _strokeSizes)
              GestureDetector(
                onTap: () => ref.read(drawingModeProvider.notifier).setSize(size),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: drawingMode.strokeSize == size
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: size + 2,
                      height: size + 2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            _divider(context),
            // Undo
            InkWell(
              onTap: () => ref
                  .read(scrapnoteCanvasStateProvider(scrapnoteId).notifier)
                  .undo(),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.undo, size: 18),
              ),
            ),
            // Redo
            InkWell(
              onTap: () => ref
                  .read(scrapnoteCanvasStateProvider(scrapnoteId).notifier)
                  .redo(),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.redo, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(
        width: 1,
        height: 20,
        color: Theme.of(context).dividerColor,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}
