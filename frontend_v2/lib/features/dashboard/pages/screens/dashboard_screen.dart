import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_app/features/pdf_viewer/pages/screens/pdf_viewer_screen.dart';
import 'package:gma_app/features/workspace/pages/providers/tab_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _openSampleAndNavigate(BuildContext context, WidgetRef ref) {
    ref.read(assetPdfModeProvider.notifier).state = true;
    ref.read(tabProviderProvider.notifier).addTab('assets/sample.pdf');
    context.go('/workspace');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'GMA SecPlan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dual-Panel Document Editor',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),
            ShadButton(
              onPressed: () => _openSampleAndNavigate(context, ref),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf, size: 18),
                  SizedBox(width: 8),
                  Text('Open Sample PDF'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ShadButton.outline(
              onPressed: () => context.go('/workspace'),
              child: const Text('Empty Workspace'),
            ),
          ],
        ),
      ),
    );
  }
}
