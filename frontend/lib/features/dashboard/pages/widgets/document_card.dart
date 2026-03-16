import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';

class DocumentCard extends ConsumerStatefulWidget {
  const DocumentCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final NoteMetadata note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  ConsumerState<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends ConsumerState<DocumentCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  static final _dateFormatter = DateFormat('MMM d');

  @override
  Widget build(BuildContext context) {
    int elementCount = 0;
    String? pdfBasename;

    if (widget.note.hasLinkedPdf) {
      pdfBasename = p.basename(widget.note.linkedPdfPath!);
      ref.watch(elementStoreProvider);
      // Safe access — registry may not be initialized yet
      final pdfId = ref
          .read(pdfRegistryProvProvider.notifier)
          .getIdByPath(widget.note.linkedPdfPath!);
      if (pdfId != null) {
        elementCount =
            ref.read(elementStoreProvider.notifier).getByPdfId(pdfId).length;
      }
    }

    final hasPdf = pdfBasename != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        onSecondaryTap: widget.onDelete,
        child: AnimatedSlide(
          offset: Offset(0, _isHovered ? -0.015 : 0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.border,
            ),
            boxShadow: _isHovered ? AppColors.cardShadowHover : AppColors.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Thumbnail area with gradient ──
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isHovered
                            ? [
                                AppColors.primary.withValues(alpha: 0.08),
                                AppColors.accentLight,
                              ]
                            : [AppColors.surfaceDim, AppColors.surfaceDim],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: AnimatedScale(
                        scale: _isHovered ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          hasPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.description_rounded,
                          size: 32,
                          color: _isHovered
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Info area ──
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasPdf) ...[
                          const SizedBox(height: 3),
                          Text(
                            pdfBasename,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              _dateFormatter.format(widget.note.modifiedAt),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Spacer(),
                            if (elementCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$elementCount',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
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
}
