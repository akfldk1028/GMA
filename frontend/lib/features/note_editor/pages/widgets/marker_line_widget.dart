import 'package:flutter/material.dart';
import 'package:gma_frontend/constants/marker_colors.dart';

/// A widget that displays a PDF marker line in the note editor.
///
/// Marker line format: `- 🔴 P3  Selected text...`
/// With optional image: `  ![caption](./captures/p5.png)`
///
/// Example:
/// ```dart
/// MarkerLineWidget(
///   color: MarkerColor.red,
///   pageNumber: 3,
///   text: 'Dictionary-based sentiment analysis is...',
///   onTap: () {
///     // Navigate to PDF page
///   },
/// )
/// ```
class MarkerLineWidget extends StatelessWidget {
  const MarkerLineWidget({
    super.key,
    required this.color,
    required this.pageNumber,
    this.text,
    this.imagePath,
    this.onTap,
  });

  /// The marker color (displayed as emoji).
  final MarkerColor color;

  /// The PDF page number.
  final int pageNumber;

  /// Optional selected text content.
  final String? text;

  /// Optional captured image path.
  final String? imagePath;

  /// Callback when the marker is tapped (for PDF navigation).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Marker line: emoji + page number + text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color emoji
                Text(
                  color.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                // Page number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: color.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'P$pageNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color.color,
                    ),
                  ),
                ),
                // Text content (if any)
                if (text != null && text!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            // Image embed (if any)
            if (imagePath != null && imagePath!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
