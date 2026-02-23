import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/marker_colors.dart';
import '../../models/pdf_marker_model.dart';
import '../providers/workspace_provider.dart';

/// Modal overlay for creating/editing a marker.
/// Shows captured text, color picker, and optional notes.
class MarkerEditModal extends ConsumerStatefulWidget {
  const MarkerEditModal({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  ConsumerState<MarkerEditModal> createState() => _MarkerEditModalState();
}

class _MarkerEditModalState extends ConsumerState<MarkerEditModal>
    with SingleTickerProviderStateMixin {
  MarkerColor _selectedColor = MarkerColor.red;
  bool _colorInitialized = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _animController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final workspaceState =
        ref.watch(workspaceProviderProvider).valueOrNull;
    if (workspaceState == null) return const SizedBox.shrink();

    final pageNumber = workspaceState.pendingMarkerPageNumber;
    final selectedText = workspaceState.pendingMarkerText;

    // If editing existing marker, initialize color once
    PdfMarker? existingMarker;
    if (workspaceState.editingMarkerId != null) {
      existingMarker = workspaceState.markers
          .where((m) => m.id == workspaceState.editingMarkerId)
          .firstOrNull;
      if (existingMarker != null && !_colorInitialized) {
        _selectedColor = existingMarker.color;
        _colorInitialized = true;
      }
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        onTap: _close,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Absorb taps on the modal
              child: Container(
                width: 420,
                constraints: const BoxConstraints(maxHeight: 400),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                      child: Row(
                        children: [
                          Text(
                            existingMarker != null
                                ? 'Edit Marker'
                                : 'Add Marker',
                            style: theme.textTheme.h4,
                          ),
                          if (pageNumber != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.muted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'P$pageNumber',
                                style: theme.textTheme.muted
                                    .copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            onPressed: _close,
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Selected text preview
                    if (selectedText != null && selectedText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedText,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.small.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Color picker
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Color', style: theme.textTheme.small),
                          const SizedBox(height: 8),
                          Row(
                            children: MarkerColor.values
                                .where((c) => c != MarkerColor.pen)
                                .map((color) {
                              final isSelected = _selectedColor == color;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedColor = color),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color.color.withValues(alpha: 0.2),
                                    border: Border.all(
                                      color: isSelected
                                          ? color.color
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      color.emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ShadButton.outline(
                            onPressed: _close,
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ShadButton(
                            onPressed: () => _confirm(context, ref),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(workspaceProviderProvider.notifier);
    final workspaceState = ref.read(workspaceProviderProvider).valueOrNull;
    if (workspaceState == null) return;

    final pageNumber = workspaceState.pendingMarkerPageNumber;
    if (pageNumber == null) {
      _close();
      return;
    }

    try {
      await notifier.createMarker(
        pageNumber: pageNumber,
        color: _selectedColor,
        selectedText: workspaceState.pendingMarkerText,
        textRect: workspaceState.pendingMarkerTextRect,
      );

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Marker Added'),
            description: Text(
              '${_selectedColor.emoji} P$pageNumber added to note',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to create marker: $e'),
          ),
        );
      }
    }

    _close();
  }
}
