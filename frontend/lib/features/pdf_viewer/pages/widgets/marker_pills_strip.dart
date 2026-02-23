import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../workspace/models/pdf_marker_model.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';

/// Vertical strip of marker pills on the left edge of the PDF viewer.
/// Each pill shows the marker color + page number.
/// Tap → PDF page jump, Long-press → open editor modal.
class MarkerPillsStrip extends ConsumerWidget {
  const MarkerPillsStrip({
    super.key,
    required this.onMarkerTap,
    required this.onMarkerLongPress,
  });

  final void Function(PdfMarker marker) onMarkerTap;
  final void Function(PdfMarker marker) onMarkerLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markers = ref.watch(currentMarkersProvider);
    final theme = ShadTheme.of(context);

    if (markers.isEmpty) {
      return SizedBox(
        width: 72,
        child: Center(
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'MARKERS',
              style: theme.textTheme.muted.copyWith(
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          right: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: markers.length,
        itemBuilder: (context, index) {
          return _MarkerPill(
            marker: markers[index],
            onTap: () => onMarkerTap(markers[index]),
            onLongPress: () => onMarkerLongPress(markers[index]),
          );
        },
      ),
    );
  }
}

class _MarkerPill extends StatelessWidget {
  const _MarkerPill({
    required this.marker,
    required this.onTap,
    required this.onLongPress,
  });

  final PdfMarker marker;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final color = marker.color.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Tooltip(
        message: marker.selectedText ?? 'P${marker.pageNumber}',
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                // Page number
                Text(
                  'P${marker.pageNumber}',
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Text preview (truncated)
                if (marker.selectedText != null &&
                    marker.selectedText!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    marker.selectedText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.muted.copyWith(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
