import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';

import '../../providers/home_state_provider.dart';

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({super.key, required this.note});

  final NoteMetadata note;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  bool _isHovered = false;

  Future<void> _onTap() async {
    final homeState = ref.read(homeStateProvider);
    if (homeState.isMultiSelectMode) {
      ref.read(homeStateProvider.notifier).toggleNoteSelection(widget.note.id);
      return;
    }

    await ref
        .read(workspaceProviderProvider.notifier)
        .loadNote(widget.note.id);
    if (!mounted) return;
    if (widget.note.hasLinkedPdf) {
      await ref
          .read(workspaceProviderProvider.notifier)
          .loadPdf(widget.note.linkedPdfPath!);
      if (!mounted) return;
    }
    context.go('/workspace');
  }

  void _onLongPress() {
    ref.read(homeStateProvider.notifier).toggleNoteSelection(widget.note.id);
  }


  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    final isSelected = homeState.selectedNoteIds.contains(widget.note.id);
    final isMultiSelect = homeState.isMultiSelectMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _onTap,
        onLongPress: _onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : _isHovered
                      ? AppColors.border
                      : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: _isHovered ? AppColors.cardShadowHover : AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail area
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDim,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                      child: Center(
                        child: Icon(
                          widget.note.hasLinkedPdf
                              ? Icons.picture_as_pdf_outlined
                              : Icons.description_outlined,
                          size: 32,
                          color: AppColors.textMuted.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    // Pin indicator
                    if (widget.note.isPinned)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(Icons.push_pin,
                            size: 14, color: AppColors.primary),
                      ),
                    // Multi-select checkbox
                    if (isMultiSelect)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
              // Title + date
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(widget.note.modifiedAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return DateFormat('M/d').format(date);
  }
}
