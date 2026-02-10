import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/theme_provider.dart';
import '../providers/workspace_provider.dart';

/// Custom header bar for the workspace using shadcn_ui components.
/// Replaces Material AppBar with a styled container containing:
/// - Sidebar toggle button
/// - App title "GMA"
/// - Theme toggle (sun/moon icon)
/// - Settings gear icon
/// - Open PDF button
class WorkspaceHeader extends ConsumerWidget {
  const WorkspaceHeader({
    required this.sidebarVisible,
    required this.onToggleSidebar,
    super.key,
  });

  final bool sidebarVisible;
  final VoidCallback onToggleSidebar;

  /// Handle PDF file selection and loading
  Future<void> _handleOpenPdf(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'Select PDF File',
      );

      if (result != null && result.files.single.path != null) {
        final pdfPath = result.files.single.path!;

        // Load PDF into workspace
        await ref.read(workspaceProviderProvider.notifier).loadPdf(pdfPath);

        // Show success toast
        if (context.mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('PDF Loaded'),
              description: Text('Successfully loaded ${result.files.single.name}'),
            ),
          );
        }
      }
    } catch (e) {
      // Show error toast
      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('PDF Load Failed'),
            description: Text('Failed to load PDF: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeMode$Provider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.background,
        border: Border(
          bottom: BorderSide(
            color: ShadTheme.of(context).colorScheme.border,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Sidebar toggle button
            ShadButton.outline(
              onPressed: onToggleSidebar,
              size: ShadButtonSize.sm,
              child: Icon(
                sidebarVisible ? Icons.menu_open : Icons.menu,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),

            // App title
            Text(
              'GMA',
              style: ShadTheme.of(context).textTheme.h4,
            ),

            const Spacer(),

            // Theme toggle button
            ShadButton.outline(
              onPressed: () {
                ref.read(themeMode$Provider.notifier).toggleTheme();
              },
              size: ShadButtonSize.sm,
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),

            // Settings button
            ShadButton.outline(
              onPressed: () {
                context.push('/settings');
              },
              size: ShadButtonSize.sm,
              child: const Icon(
                Icons.settings,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),

            // Open PDF button
            ShadButton(
              onPressed: () => _handleOpenPdf(context, ref),
              size: ShadButtonSize.sm,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf, size: 18),
                  SizedBox(width: 8),
                  Text('Open PDF'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
