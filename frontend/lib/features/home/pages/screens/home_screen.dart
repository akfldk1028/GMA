import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GMA',
              style: ShadTheme.of(context).textTheme.h1,
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to GMA App',
              style: ShadTheme.of(context).textTheme.muted,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShadButton(
                  onPressed: () => context.push('/file-browser'),
                  child: const Text('File Browser'),
                ),
                const SizedBox(width: 12),
                ShadButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Login'),
                ),
                const SizedBox(width: 12),
                ShadButton.outline(
                  onPressed: () => context.push('/profile'),
                  child: const Text('Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
