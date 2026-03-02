import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../../scrapnote/models/element_model.dart';
import '../../../scrapnote/providers/element_store.dart';
import '../../../scrapnote/providers/pdf_registry_provider.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';

/// Visual hierarchical tree: Note → PDF → ScrapElements
/// with painted connecting lines between nodes.
class NoteTreeSection extends ConsumerStatefulWidget {
  const NoteTreeSection({super.key});

  @override
  ConsumerState<NoteTreeSection> createState() => _NoteTreeSectionState();
}

class _NoteTreeSectionState extends ConsumerState<NoteTreeSection> {
  bool _registryReady = false;

  @override
  void initState() {
    super.initState();
    _initRegistry();
  }

  Future<void> _initRegistry() async {
    await ref.read(pdfRegistryProvProvider.notifier).ensureReady();
    if (mounted) setState(() => _registryReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(fileManagerProvider);
    ref.watch(elementStoreProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Note Connections',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/knowledge-graph'),
              child: const Text(
                'Graph View',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: (!_registryReady)
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              : notesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (notes) {
                    final linked =
                        notes.where((n) => n.hasLinkedPdf).toList();
                    if (linked.isEmpty) {
                      return Center(
                        child: Text(
                          'Open a PDF to see note connections here.',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                AppColors.textMuted.withValues(alpha: 0.7),
                          ),
                        ),
                      );
                    }
                    return _VisualTree(notes: linked);
                  },
                ),
        ),
      ],
    );
  }
}

/// A scrollable visual tree with painted connector lines.
class _VisualTree extends ConsumerWidget {
  const _VisualTree({required this.notes});
  final List<NoteMetadata> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.read(pdfRegistryProvProvider.notifier);
    final store = ref.read(elementStoreProvider.notifier);

    // Build flat list of tree rows with depth info
    final rows = <_TreeRow>[];
    for (final note in notes) {
      rows.add(_TreeRow(
        depth: 0,
        icon: Icons.description_rounded,
        color: const Color(0xFF10B981),
        label: note.title,
        isLast: false, // updated below
        onTap: () => _openNote(context, ref, note),
      ));

      if (note.linkedPdfPath != null) {
        final pdfName = _fileName(note.linkedPdfPath!);
        final pdfId = registry.getIdByPath(note.linkedPdfPath!);
        final elements = pdfId != null ? store.getByPdfId(pdfId) : <ScrapElement>[];
        elements.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

        rows.add(_TreeRow(
          depth: 1,
          icon: Icons.picture_as_pdf_rounded,
          color: const Color(0xFF3B82F6),
          label: pdfName,
          isLast: elements.isEmpty,
          onTap: () => _openNote(context, ref, note),
        ));

        for (int i = 0; i < elements.length; i++) {
          final el = elements[i];
          rows.add(_TreeRow(
            depth: 2,
            icon: _elIcon(el.type),
            color: _elColor(el.type),
            label: _elLabel(el),
            isLast: i == elements.length - 1,
            onTap: () => _navElement(context, ref, el.id),
          ));
        }
      }

      // Spacer row between note groups
      rows.add(const _TreeRow(
        depth: -1,
        icon: null,
        color: Colors.transparent,
        label: '',
        isLast: true,
      ));
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row.depth == -1) {
          return const SizedBox(height: 12);
        }
        return _VisualTreeRow(row: row);
      },
    );
  }

  String _fileName(String path) {
    final s = path.replaceAll('\\', '/').split('/');
    return s.isNotEmpty ? s.last : path;
  }

  void _openNote(BuildContext context, WidgetRef ref, NoteMetadata note) async {
    await ref.read(workspaceProviderProvider.notifier).loadNote(note.id);
    if (note.hasLinkedPdf) {
      await ref.read(workspaceProviderProvider.notifier).loadPdf(note.linkedPdfPath!);
    }
    if (context.mounted) context.go('/workspace');
  }

  void _navElement(BuildContext context, WidgetRef ref, String id) async {
    await ref.read(workspaceProviderProvider.notifier).navigateToElement(id);
    if (context.mounted) context.go('/workspace');
  }

  IconData _elIcon(ElementType t) => switch (t) {
        ElementType.highlight => Icons.highlight_rounded,
        ElementType.capture => Icons.crop_rounded,
        ElementType.drawing => Icons.draw_rounded,
      };

  Color _elColor(ElementType t) => switch (t) {
        ElementType.highlight => AppColors.primary,
        ElementType.capture => AppColors.success,
        ElementType.drawing => AppColors.warning,
      };

  String _elLabel(ScrapElement el) {
    final p = 'P${el.pageNumber}';
    if (el.selectedText != null && el.selectedText!.isNotEmpty) {
      final t = el.selectedText!.length > 35
          ? '${el.selectedText!.substring(0, 35)}...'
          : el.selectedText!;
      return '$p: $t';
    }
    return '$p ${el.type.name}';
  }
}

class _TreeRow {
  final int depth;
  final IconData? icon;
  final Color color;
  final String label;
  final bool isLast;
  final VoidCallback? onTap;

  const _TreeRow({
    required this.depth,
    required this.icon,
    required this.color,
    required this.label,
    required this.isLast,
    this.onTap,
  });
}

/// A single row in the visual tree with painted connector lines.
class _VisualTreeRow extends StatefulWidget {
  const _VisualTreeRow({required this.row});
  final _TreeRow row;

  @override
  State<_VisualTreeRow> createState() => _VisualTreeRowState();
}

class _VisualTreeRowState extends State<_VisualTreeRow> {
  bool _isHovered = false;

  static const _indentWidth = 28.0;
  static const _nodeHeight = 36.0;
  static const _lineColor = Color(0xFFCBD5E1);

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final leftPad = row.depth * _indentWidth;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: row.onTap,
        child: SizedBox(
          height: _nodeHeight,
          child: CustomPaint(
            painter: _TreeLinePainter(
              depth: row.depth,
              isLast: row.isLast,
              indentWidth: _indentWidth,
              lineColor: _lineColor,
            ),
            child: Padding(
              padding: EdgeInsets.only(left: leftPad + 8),
              child: Row(
                children: [
                  // Node dot with colored ring
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered
                          ? row.color.withValues(alpha: 0.15)
                          : row.color.withValues(alpha: 0.08),
                      border: Border.all(
                        color: row.color,
                        width: 2,
                      ),
                    ),
                    child: Icon(row.icon, size: 11, color: row.color),
                  ),
                  const SizedBox(width: 8),
                  // Label
                  Expanded(
                    child: Text(
                      row.label,
                      style: TextStyle(
                        fontSize: row.depth == 0 ? 13 : 12,
                        fontWeight:
                            row.depth == 0 ? FontWeight.w600 : FontWeight.w400,
                        color: _isHovered
                            ? AppColors.primary
                            : (row.depth == 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Depth badge
                  if (row.depth > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: row.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        row.depth == 1 ? 'PDF' : row.label.split(':').first.trim(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: row.color,
                        ),
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
}

/// Paints vertical and horizontal tree connector lines.
class _TreeLinePainter extends CustomPainter {
  final int depth;
  final bool isLast;
  final double indentWidth;
  final Color lineColor;

  _TreeLinePainter({
    required this.depth,
    required this.isLast,
    required this.indentWidth,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (depth == 0) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;

    // Horizontal line from parent's vertical to this node
    final hStart = (depth - 1) * indentWidth + indentWidth / 2 + 8;
    final hEnd = depth * indentWidth + 8;
    canvas.drawLine(Offset(hStart, midY), Offset(hEnd, midY), paint);

    // Vertical line from parent
    final vX = hStart;
    canvas.drawLine(
      Offset(vX, 0),
      Offset(vX, isLast ? midY : size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TreeLinePainter old) =>
      old.depth != depth || old.isLast != isLast;
}
