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
            // No header -- clean card
            // Image -- fill remaining space
            Expanded(
              child: imgPath != null
                  ? Image.file(
                      File(imgPath),
                      width: double.infinity,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard() {
    final text = element.selectedText ?? '';
    // Determine highlight color from associated marker color
    final highlightColor = _highlightColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
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
            // Left accent bar only
            Container(
              height: 3,
              color: highlightColor.withValues(alpha: 0.5),
            ),
            // Text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  text.isNotEmpty ? text : 'Highlight',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _highlightColor {
    // Try to match element's color info -- default to primary purple
    return Colors.purple.shade400;
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
