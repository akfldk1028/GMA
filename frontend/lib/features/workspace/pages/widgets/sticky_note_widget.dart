import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../gma_md/gma_md.dart';
import '../../../note_editor/pages/providers/note_editor_provider.dart';
import '../../../note_editor/pages/screens/note_editor_screen.dart';
import '../../../note_editor/utils/latex_renderer.dart';
import '../../../note_editor/utils/markdown_config.dart';
import '../../../note_editor/utils/markdown_extension.dart';
import '../../../note_editor/utils/marker_line_renderer.dart';
import '../../../note_editor/utils/wiki_link_renderer.dart';
import '../providers/workspace_provider.dart';

/// Draggable floating window that renders GMA-MD content on top of the PDF viewer.
class StickyNoteWidget extends ConsumerStatefulWidget {
  const StickyNoteWidget({
    super.key,
    required this.noteId,
    this.onMarkerClick,
  });

  final String? noteId;
  final OnMarkerClickCallback? onMarkerClick;

  @override
  ConsumerState<StickyNoteWidget> createState() => _StickyNoteWidgetState();
}

class _StickyNoteWidgetState extends ConsumerState<StickyNoteWidget> {
  static const double _headerHeight = 36;
  static const double _minWidth = 200;
  static const double _minHeight = 150;
  static const double _resizeHandleSize = 16;

  Offset _position = Offset.zero;
  Size _size = const Size(350, 400);
  bool _isCollapsed = false;
  bool _positioned = false;

  late List<MarkdownExtension> _extensions = _buildExtensions();

  List<MarkdownExtension> _buildExtensions() {
    final inner = <MarkdownExtension>[
      LatexExtension(),
      MarkerLineExtension(
        onTap: (pageNumber, subNumber, color) {
          widget.onMarkerClick?.call('page:$pageNumber-$subNumber');
        },
      ),
      WikiLinkExtension(
        onTap: (target) {},
      ),
    ];
    return [
      GmaMdExtension(innerExtensions: inner),
      ...inner,
    ];
  }

  @override
  void didUpdateWidget(covariant StickyNoteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onMarkerClick != widget.onMarkerClick) {
      _extensions = _buildExtensions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenSize = MediaQuery.sizeOf(context);

    // Initial position: top-right corner
    if (!_positioned) {
      _position = Offset(screenSize.width - _size.width - 16, 64);
      _positioned = true;
    }

    // Clamp position to screen bounds
    final clampedX = _position.dx.clamp(0.0, screenSize.width - 80);
    final clampedY = _position.dy.clamp(0.0, screenSize.height - _headerHeight);

    // Read note content from the editor controller
    final content = widget.noteId != null
        ? ref.watch(noteEditorProvider(widget.noteId!))?.text ?? ''
        : '';

    final displayHeight = _isCollapsed ? _headerHeight : _size.height;

    return Positioned(
      left: clampedX,
      top: clampedY,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
        child: Container(
          width: _size.width,
          height: displayHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header bar (draggable)
              _buildHeader(context, theme),
              // Content area
              if (!_isCollapsed)
                Expanded(
                  child: Stack(
                    children: [
                      _buildContent(context, theme, content),
                      // Resize handle (bottom-right)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: _buildResizeHandle(theme),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ShadThemeData theme) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
        });
      },
      child: Container(
        height: _headerHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.3),
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 14,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Note',
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Collapse/expand toggle
            _HeaderButton(
              icon: _isCollapsed
                  ? Icons.expand_more
                  : Icons.expand_less,
              tooltip: _isCollapsed ? 'Expand' : 'Collapse',
              onTap: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            // Open editor modal
            _HeaderButton(
              icon: Icons.edit_note,
              tooltip: 'Open Editor',
              onTap: () {
                ref
                    .read(workspaceProviderProvider.notifier)
                    .openEditorModal();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ShadThemeData theme,
    String content,
  ) {
    if (content.isEmpty) {
      return Center(
        child: Text(
          'No content',
          style: theme.textTheme.muted.copyWith(fontSize: 12),
        ),
      );
    }

    final config = buildMarkdownConfig(context, extensions: _extensions);
    final generator = buildMarkdownGenerator(extensions: _extensions);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: MarkdownWidget(
        data: content,
        shrinkWrap: false,
        selectable: true,
        config: config,
        markdownGenerator: generator,
      ),
    );
  }

  Widget _buildResizeHandle(ShadThemeData theme) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _size = Size(
            (_size.width + details.delta.dx).clamp(_minWidth, 800.0),
            (_size.height + details.delta.dy).clamp(_minHeight, 800.0),
          );
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeDownRight,
        child: SizedBox(
          width: _resizeHandleSize,
          height: _resizeHandleSize,
          child: CustomPaint(
            painter: _ResizeHandlePainter(
              color: theme.colorScheme.mutedForeground.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

/// Paints the diagonal resize lines at bottom-right corner.
class _ResizeHandlePainter extends CustomPainter {
  _ResizeHandlePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Three diagonal lines
    for (int i = 0; i < 3; i++) {
      final offset = 4.0 + i * 3.0;
      canvas.drawLine(
        Offset(size.width, offset),
        Offset(offset, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ResizeHandlePainter oldDelegate) =>
      color != oldDelegate.color;
}
