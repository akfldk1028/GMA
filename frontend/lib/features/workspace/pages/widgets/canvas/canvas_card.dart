import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../scrapnote/models/element_model.dart';

class CanvasScrapCard extends StatelessWidget {
  const CanvasScrapCard({
    super.key,
    required this.element,
    this.capturesDir,
  });

  final ScrapElement element;
  final String? capturesDir;

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
    final isHighlight = element.type == ElementType.highlight;
    if (isHighlight) return _buildHighlightCard();

    final imgPath = _resolvedImagePath;
    final isLasso = element.type == ElementType.lasso;

    return Container(
      decoration: BoxDecoration(
        color: isLasso ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: isLasso ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isLasso
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: imgPath != null
                  ? Image.file(
                      File(imgPath),
                      width: double.infinity,
                      fit: BoxFit.fill,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            // Memo text (if any)
            if (element.selectedText != null && element.selectedText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  element.selectedText!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Modern highlight card: thin vertical accent on the left, larger text,
  /// rounded corners, subtle shadow. Sized to fit content (the parent panel
  /// computes the card height from the text in `_ensurePropsFor`).
  Widget _buildHighlightCard() {
    final text = element.selectedText ?? '';
    final accent = _highlightColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(width: 3, color: accent),
              // Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Text(
                    text.isNotEmpty ? text : 'Highlight',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade900,
                      height: 1.45,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _highlightColor {
    // Try to match element's color info -- default to a calm amber
    return const Color(0xFFF59E0B);
  }

  Widget _placeholder() {
    return Container(
      height: 80,
      color: Colors.grey.shade50,
      child: Center(
        child: Icon(Icons.image, size: 24, color: Colors.grey.shade300),
      ),
    );
  }
}
