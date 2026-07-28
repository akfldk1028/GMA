import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../../providers/home_state_provider.dart';
import '../../providers/pdf_thumbnail_provider.dart';

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

    await ref.read(workspaceProviderProvider.notifier).loadNote(widget.note.id);
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final thumbHeight = (constraints.maxHeight - 64)
                .clamp(112.0, 156.0)
                .toDouble();

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: AppColors.sokSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.sokAccent
                      : _isHovered
                      ? AppColors.sokBorderHover
                      : AppColors.sokDivider,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: _isHovered ? AppColors.sokFloatingShadow : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: thumbHeight,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        DecoratedBox(
                          decoration: const BoxDecoration(
                            color: AppColors.sokPreviewBackdrop,
                          ),
                          child: SizedBox.expand(
                            child: widget.note.hasLinkedPdf
                                ? _PdfThumbnail(
                                    pdfPath: widget.note.linkedPdfPath!,
                                  )
                                : widget.note.hasCoverImage
                                ? _CoverImageThumbnail(
                                    path: widget.note.coverImagePath!,
                                  )
                                : const _PlaceholderThumbnail(),
                          ),
                        ),
                        if (widget.note.isPinned)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.push_pin,
                              size: 15,
                              color: AppColors.sokAccent,
                            ),
                          ),
                        if (isMultiSelect)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.sokAccent
                                    : AppColors.sokSurface,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.sokAccent
                                      : AppColors.sokSecondary,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sokPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(widget.note.modifiedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.sokSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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

class _PlaceholderThumbnail extends StatelessWidget {
  const _PlaceholderThumbnail();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.sokThumbnailDark),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ThumbnailLine(widthFactor: 0.74, opacity: 0.80, height: 8),
            SizedBox(height: 8),
            _ThumbnailLine(widthFactor: 0.58),
            SizedBox(height: 8),
            _ThumbnailLine(widthFactor: 0.82),
            SizedBox(height: 8),
            _ThumbnailLine(widthFactor: 0.68),
            SizedBox(height: 8),
            _ThumbnailLine(widthFactor: 0.78),
            SizedBox(height: 8),
            _ThumbnailLine(widthFactor: 0.52),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailLine extends StatelessWidget {
  const _ThumbnailLine({
    required this.widthFactor,
    this.opacity = 0.22,
    this.height = 5,
  });

  final double widthFactor;
  final double opacity;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

/// Async PDF first-page thumbnail with loading/error fallback.
class _PdfThumbnail extends ConsumerWidget {
  const _PdfThumbnail({required this.pdfPath});
  final String pdfPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbAsync = ref.watch(pdfThumbnailProvider(pdfPath));
    return thumbAsync.when(
      data: (bytes) {
        if (bytes == null) return _fallbackIcon();
        // SizedBox.expand forces both width and height to fill the parent.
        // Without it, Image.memory sized only by width: infinity falls back
        // to intrinsic height — so PPT-aspect (16:9) PDFs only fill ~half
        // the portrait card cell. With both axes constrained, BoxFit.cover
        // properly crops the image to fill the cell.
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox.expand(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        );
      },
      loading: () => Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
        ),
      ),
      error: (err, st) => _fallbackIcon(),
    );
  }

  static Widget _fallbackIcon() => Center(
    child: Icon(
      Icons.picture_as_pdf_outlined,
      size: 32,
      color: AppColors.textMuted.withValues(alpha: 0.4),
    ),
  );
}

/// Direct file thumbnail used as a fallback when the note has no linked
/// PDF but contains capture/lasso images. Just shows the first image
/// referenced in the note body.
class _CoverImageThumbnail extends StatelessWidget {
  const _CoverImageThumbnail({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _fallback();
    final file = File(path);
    if (!file.existsSync()) return _fallback();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SizedBox.expand(
        child: Image.file(
          file,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (ctx, err, st) => _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() => Center(
    child: Icon(
      Icons.image_outlined,
      size: 32,
      color: AppColors.textMuted.withValues(alpha: 0.4),
    ),
  );
}
