import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/scrapnote_canvas_model.dart';

/// Widget for rendering a captured image element on the scrapnote canvas.
///
/// Displays the captured image (or a placeholder if the file does not exist),
/// a border/frame around the image, and a source page number indicator.
/// Supports long-press to enter drag mode for repositioning.
class CaptureElementWidget extends StatefulWidget {
  const CaptureElementWidget({
    super.key,
    required this.element,
    this.onReposition,
  });

  final CanvasElement element;

  /// Called when the user drags the element after a long-press.
  /// Provides the element id and the new (x, y) position.
  final void Function(String id, double x, double y)? onReposition;

  @override
  State<CaptureElementWidget> createState() => _CaptureElementWidgetState();
}

class _CaptureElementWidgetState extends State<CaptureElementWidget> {
  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
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
          border: Border.all(
            color: _isDragging ? Colors.blue : Colors.grey.shade400,
            width: _isDragging ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.shade50,
        ),
        child: Stack(
          children: [
            // Image or placeholder
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: _buildImageContent(),
              ),
            ),
            // Page number indicator
            if (widget.element.sourcePageNumber != null)
              Positioned(
                top: 4,
                right: 4,
                child: _PageIndicator(pageNumber: widget.element.sourcePageNumber!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    final path = widget.element.imagePath;
    if (path == null || path.isEmpty) {
      return _buildPlaceholder();
    }

    final file = File(path);
    if (!file.existsSync()) {
      return _buildPlaceholder();
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}

/// Small badge showing the source page number (e.g., "P3").
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.pageNumber});

  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'P$pageNumber',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
