import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common_widgets/responsive.dart';
import '../../models/workspace_state.dart';
import '../providers/workspace_provider.dart';

class WorkspaceHeaderV3 extends ConsumerWidget {
  const WorkspaceHeaderV3({
    super.key,
    required this.onToggleEditor,
    required this.onTogglePageNav,
    required this.onToggleLiveScraps,
  });

  final VoidCallback onToggleEditor;
  final VoidCallback onTogglePageNav;
  final VoidCallback onToggleLiveScraps;

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
      }
    } catch (e) {
      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('PDF Load Failed'),
            description: Text('$e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceState =
        ref.watch(workspaceProviderProvider).valueOrNull;
    final isMobile = Responsive.isMobile(context);
    final theme = ShadTheme.of(context);

    String title = 'Workspace';
    if (workspaceState?.currentPdfPath != null) {
      title = p.basenameWithoutExtension(workspaceState!.currentPdfPath!);
    }

    final isPageNavOpen = workspaceState?.isPageNavOpen ?? true;
    final isLiveScrapsOpen = workspaceState?.isLiveScrapsOpen ?? true;

    final buttonSize = isMobile ? 40.0 : 32.0;
    final iconSize = isMobile ? 20.0 : 18.0;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Home
            _HeaderIconButton(
              icon: Icons.home_rounded,
              tooltip: 'Home',
              size: buttonSize,
              iconSize: iconSize,
              onTap: () => context.go('/home'),
            ),
            const SizedBox(width: 2),

            // Divider
            Container(
              width: 1,
              height: 20,
              color: theme.colorScheme.border,
            ),
            const SizedBox(width: 8),

            // Title
            Icon(
              Icons.picture_as_pdf_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Actions
            _HeaderIconButton(
              icon: Icons.file_open_rounded,
              tooltip: 'Open PDF',
              size: buttonSize,
              iconSize: iconSize,
              onTap: () => _handleOpenPdf(context, ref),
            ),
            if (!isMobile)
              _HeaderIconButton(
                icon: Icons.sticky_note_2_rounded,
                tooltip: 'Sticky Note',
                size: buttonSize,
                iconSize: iconSize,
                isActive: workspaceState?.isStickyNoteVisible ?? false,
                onTap: () => ref
                    .read(workspaceProviderProvider.notifier)
                    .toggleStickyNote(),
              ),
            _HeaderIconButton(
              icon: Icons.edit_note_rounded,
              tooltip: isMobile ? 'Editor' : 'Editor (Ctrl+E)',
              size: buttonSize,
              iconSize: iconSize,
              isActive: workspaceState?.isEditorModalOpen ?? false,
              onTap: onToggleEditor,
            ),
            const SizedBox(width: 4),
            Container(
              width: 1,
              height: 20,
              color: theme.colorScheme.border,
            ),
            const SizedBox(width: 4),

            // PDF view mode toggle
            _HeaderIconButton(
              icon: (workspaceState?.pdfViewMode ?? PdfViewMode.continuous) ==
                      PdfViewMode.continuous
                  ? Icons.view_day_rounded
                  : Icons.menu_book_rounded,
              tooltip: (workspaceState?.pdfViewMode ?? PdfViewMode.continuous) ==
                      PdfViewMode.continuous
                  ? 'Facing Pages'
                  : 'Continuous Scroll',
              size: buttonSize,
              iconSize: iconSize,
              onTap: () => ref
                  .read(workspaceProviderProvider.notifier)
                  .togglePdfViewMode(),
            ),

            // Panel toggle buttons
            _HeaderIconButton(
              icon: Icons.view_sidebar_rounded,
              tooltip: 'Page Navigator',
              size: buttonSize,
              iconSize: iconSize,
              isActive: isMobile ? false : isPageNavOpen,
              onTap: onTogglePageNav,
            ),
            _HeaderIconButton(
              icon: Icons.auto_awesome_mosaic_rounded,
              tooltip: 'Live Scraps',
              size: buttonSize,
              iconSize: iconSize,
              isActive: isMobile ? false : isLiveScrapsOpen,
              isRight: true,
              onTap: onToggleLiveScraps,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
    this.isRight = false,
    this.size = 32,
    this.iconSize = 18,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;
  final bool isRight;
  final double size;
  final double iconSize;

  // Cache the mirrored matrix to avoid per-frame allocation
  static final Matrix4 _mirror = Matrix4.diagonal3Values(-1.0, 1.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        button: true,
        child: Material(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: size,
              height: size,
              child: Transform(
                alignment: Alignment.center,
                transform: isRight ? _mirror : Matrix4.identity(),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
