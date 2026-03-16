import 'package:flutter/material.dart';

import '../../models/scrapnote_canvas_model.dart';

/// Widget for rendering a highlight text card element on the scrapnote canvas.
///
/// Shows the selected text in a card with a color indicator strip on the left,
/// a source page number indicator, and supports long-press to enter drag mode
/// for repositioning.
class HighlightCardWidget extends StatefulWidget {
  const HighlightCardWidget({
    super.key,
    required this.element,
    this.onReposition,
  });

  final CanvasElement element;

  /// Called when the user drags the element after a long-press.
  /// Provides the element id and the new (x, y) position.
  final void Function(String id, double x, double y)? onReposition;

  @override
  State<HighlightCardWidget> createState() => _HighlightCardWidgetState();
}

class _HighlightCardWidgetState extends State<HighlightCardWidget> {
  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final colorValue = widget.element.colorValue;
    final stripColor = colorValue != null ? Color(colorValue) : Colors.yellow;

    return GestureDetector(
      onLongPressStart: (_) {
        setState(() => _isDragging = true);
      },
      onLongPressEnd: (_) {
        if (_isDragging) {
          widget.onReposition?.call(
            widget.element.id,
            widget.element.x + _dragOffset.dx,
            widget.element.y + _dragOffset.dy,
          );
          setState(() {
            _isDragging = false;
            _dragOffset = Offset.zero;
          });
        }
      },
      onPanUpdate: _isDragging
          ? (details) {
              setState(() {
                _dragOffset += details.delta;
              });
              widget.onReposition?.call(
                widget.element.id,
                widget.element.x + _dragOffset.dx,
                widget.element.y + _dragOffset.dy,
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _isDragging ? Colors.blue : Colors.grey.shade300,
            width: _isDragging ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color indicator strip on the left
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: stripColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
            ),
            // Content: text + page number
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ClipRect(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Selected text
                      if (widget.element.selectedText != null &&
                          widget.element.selectedText!.isNotEmpty)
                        Flexible(
                          child: Text(
                            widget.element.selectedText!,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // Page number badge
                      if (widget.element.sourcePageNumber != null) ...[
                        const SizedBox(height: 4),
                        _PageIndicator(
                          pageNumber: widget.element.sourcePageNumber!,
                          color: stripColor,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small badge showing the source page number (e.g., "P5").
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.pageNumber, required this.color});

  final int pageNumber;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        'P$pageNumber',
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black87 : color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
