import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'constants/app_theme.dart';
import 'features/workspace/pages/providers/theme_provider.dart';
import 'routing/app_router.dart';

class GmaApp extends ConsumerWidget {
  const GmaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeMode$Provider);

    return ShadApp.router(
      title: 'GMA',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
