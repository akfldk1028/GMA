import 'package:flutter/material.dart';

import '../../models/knowledge_graph_model.dart';

/// A draggable circular node widget for the knowledge graph.
class GraphNodeWidget extends StatefulWidget {
  const GraphNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final KnowledgeNode node;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  State<GraphNodeWidget> createState() => _GraphNodeWidgetState();
}

class _GraphNodeWidgetState extends State<GraphNodeWidget> {
  bool _isHovered = false;

  static const _pdfColor = Color(0xFF3B82F6);
  static const _noteColor = Color(0xFF10B981);

  double get _radius {
    // Base 24, grow with connections (max +15)
    return 24.0 + (widget.node.connectionCount.clamp(0, 10) * 1.5);
  }

  Color get _color =>
      widget.node.type == KnowledgeNodeType.pdf ? _pdfColor : _noteColor;

  @override
  Widget build(BuildContext context) {
    final diameter = _radius * 2;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: (_) => widget.onDragStart(),
        onPanUpdate: (details) => widget.onDragUpdate(details.delta),
        onPanEnd: (_) => widget.onDragEnd(),
        child: Tooltip(
          message: widget.node.label,
          waitDuration: const Duration(milliseconds: 400),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _color.withValues(alpha: _isHovered ? 0.2 : 0.12),
              border: Border.all(
                color: _color.withValues(alpha: _isHovered ? 1.0 : 0.7),
                width: _isHovered ? 2.5 : 2.0,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: _color.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.node.type == KnowledgeNodeType.pdf
                        ? Icons.picture_as_pdf_rounded
                        : Icons.description_rounded,
                    size: _radius * 0.55,
                    color: _color,
                  ),
                  if (_radius >= 28)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _truncate(widget.node.label, 10),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: _color,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen - 1)}\u2026';
  }
}
