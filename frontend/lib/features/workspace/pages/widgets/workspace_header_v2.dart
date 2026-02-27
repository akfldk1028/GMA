import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../pdf_viewer/pages/providers/pdf_document_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/workspace_provider.dart';

/// New workspace header: [<] back + note title + [editor] [clipboard] [more].
class WorkspaceHeaderV2 extends ConsumerWidget {
  const WorkspaceHeaderV2({
    super.key,
    required this.onToggleFileBrowser,
    required this.onToggleEditor,
  });

  final VoidCallback onToggleFileBrowser;
  final VoidCallback onToggleEditor;

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

        if (context.mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('PDF Loaded'),
              description:
                  Text('Opened ${result.files.single.name}'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('PDF Load Failed'),
            description: Text('Failed to load PDF: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final themeMode = ref.watch(themeMode$Provider);
    final isDark = themeMode == ThemeMode.dark;
    final workspaceState =
        ref.watch(workspaceProviderProvider).valueOrNull;

    // Extract note title from state (use PDF filename fallback)
    String title = 'GMA';
    if (workspaceState?.currentPdfPath != null) {
      final path = workspaceState!.currentPdfPath!;
      title = path.split(RegExp(r'[/\\]')).last.replaceAll('.pdf', '');
    }

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
            // Back / file browser button
            ShadButton.ghost(
              onPressed: onToggleFileBrowser,
              size: ShadButtonSize.sm,
              child: const Icon(Icons.menu, size: 20),
            ),
            const SizedBox(width: 8),

            // Title
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Editor toggle
            ShadButton.ghost(
              onPressed: onToggleEditor,
              size: ShadButtonSize.sm,
              child: const Icon(Icons.edit_note, size: 20),
            ),

            // More menu
            ShadButton.ghost(
              onPressed: () => _showMoreMenu(context, ref, isDark),
              size: ShadButtonSize.sm,
              child: const Icon(Icons.more_vert, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref, bool isDark) {
    final button = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(button.size.width, button.size.height),
            ancestor: overlay),
        button.localToGlobal(Offset(button.size.width, button.size.height),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(value: 'open_pdf', child: Text('Open PDF')),
        PopupMenuItem(
          value: 'toggle_theme',
          child: Text(isDark ? 'Light Mode' : 'Dark Mode'),
        ),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'open_pdf':
          // ignore: use_build_context_synchronously
          _handleOpenPdf(context, ref);
        case 'toggle_theme':
          ref.read(themeMode$Provider.notifier).toggleTheme();
        case 'settings':
          // ignore: use_build_context_synchronously
          context.push('/settings');
      }
    });
  }
}
