import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../auth/pages/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: authState.when(
          data: (user) {
            if (user == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not logged in',
                    style: ShadTheme.of(context).textTheme.muted,
                  ),
                  const SizedBox(height: 16),
                  ShadButton(
                    onPressed: () {},
                    child: const Text('Go to Login'),
                  ),
                ],
              );
            }
            return ShadCard(
              title: Text(user.name),
              description: Text(user.email),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ShadButton.destructive(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                  },
                  child: const Text('Logout'),
                ),
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }
}
