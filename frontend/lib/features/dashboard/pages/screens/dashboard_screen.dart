import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../../constants/app_colors.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../../pdf_viewer/pages/providers/pdf_document_provider.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../widgets/dashboard_right_panel.dart';
import '../widgets/document_card.dart';
import '../widgets/note_tree_section.dart';
import '../widgets/recent_scraps_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _handleNewNote(BuildContext context, WidgetRef ref) async {
    try {
      final mutation = ref.read(createNoteMutationProvider.notifier);
      final title = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final note = await mutation.call(title: title);
      if (context.mounted) {
        await ref
            .read(workspaceProviderProvider.notifier)
            .loadNote(note.id);
        if (context.mounted) context.go('/workspace');
      }
    } catch (e) {
      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Failed to create note'),
            description: Text('$e'),
          ),
        );
      }
    }
  }

  Future<void> _handleOpenPdf(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'Select PDF File',
      );

      if (result != null && result.files.single.path != null) {
        final pdfPath = result.files.single.path!;
        await ref.read(workspaceProviderProvider.notifier).loadPdf(pdfPath);
        await ref.read(pdfDocumentProvider.notifier).loadFromFile(pdfPath);
        if (context.mounted) context.go('/workspace');
      }
    } catch (e) {
      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Failed to open PDF'),
            description: Text('$e'),
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteNote(
      BuildContext context, WidgetRef ref, String filePath, String title) async {
    final result = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Delete Note'),
        description: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        await ref
            .read(deleteNoteMutationProvider.notifier)
            .call(filePath: filePath);
      } catch (e) {
        if (context.mounted) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Delete Failed'),
              description: Text('$e'),
            ),
          );
        }
      }
    }
  }

  void _showAiPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => const DashboardRightPanel(isSheet: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(fileManagerProvider);
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    final padding = isMobile
        ? const EdgeInsets.fromLTRB(16, 16, 16, 16)
        : const EdgeInsets.fromLTRB(28, 28, 24, 24);

    final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: isMobile ? 160 : 220,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: isMobile ? 0.85 : 0.78,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showAiPanel(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            )
          : null,
      body: Row(
        children: [
          // ── Main content ──
          Expanded(
            flex: 3,
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ──
                  _buildHeader(context, ref, isMobile),
                  SizedBox(height: isMobile ? 20 : 28),

                  // ── Recent Documents header ──
                  Row(
                    children: [
                      const Text(
                        'Recent Documents',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/home'),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Documents grid ──
                  Expanded(
                    flex: 3,
                    child: notesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Text('Error loading notes: $err'),
                      ),
                      data: (notes) {
                        if (notes.isEmpty) {
                          return _buildEmptyState(context, ref);
                        }

                        return GridView.builder(
                          gridDelegate: gridDelegate,
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return DocumentCard(
                              key: ValueKey(note.id),
                              note: note,
                              onTap: () async {
                                await ref
                                    .read(workspaceProviderProvider.notifier)
                                    .loadNote(note.id);
                                if (note.hasLinkedPdf) {
                                  await ref
                                      .read(
                                          workspaceProviderProvider.notifier)
                                      .loadPdf(note.linkedPdfPath!);
                                  await ref
                                      .read(pdfDocumentProvider.notifier)
                                      .loadFromFile(note.linkedPdfPath!);
                                }
                                if (context.mounted) context.go('/workspace');
                              },
                              onDelete: () => _handleDeleteNote(
                                context,
                                ref,
                                note.filePath,
                                note.title,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Note Connections tree ──
                  const Expanded(
                    flex: 2,
                    child: NoteTreeSection(),
                  ),

                  const SizedBox(height: 16),

                  // ── Recent Scraps ──
                  const SizedBox(
                    height: 160,
                    child: RecentScrapsSection(),
                  ),
                ],
              ),
            ),
          ),

          // ── Right panel (hidden on mobile) ──
          if (!isMobile)
            SizedBox(
              width: isTablet ? 240 : 300,
              child: const DashboardRightPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isMobile) {
    final titleStyle = TextStyle(
      fontSize: isMobile ? 20 : 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: titleStyle),
          const SizedBox(height: 4),
          Text(
            'Welcome back! Here\'s your recent work.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.add_rounded,
                  label: 'New Note',
                  onTap: () => _handleNewNote(context, ref),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Open PDF',
                  onTap: () => _handleOpenPdf(context, ref),
                  outlined: true,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: titleStyle),
              const SizedBox(height: 4),
              Text(
                'Welcome back! Here\'s your recent work.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        _ActionButton(
          icon: Icons.add_rounded,
          label: 'New Note',
          onTap: () => _handleNewNote(context, ref),
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.picture_as_pdf_rounded,
          label: 'Open PDF',
          onTap: () => _handleOpenPdf(context, ref),
          outlined: true,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.note_add_outlined,
              size: 32,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Create your first note',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start by creating a note or opening a PDF.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.add_rounded,
                label: 'New Note',
                onTap: () => _handleNewNote(context, ref),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Open PDF',
                onTap: () => _handleOpenPdf(context, ref),
                outlined: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.outlined) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.surfaceHover : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
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

    // Primary gradient button
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
