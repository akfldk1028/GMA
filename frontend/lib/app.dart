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
      title: 'LinkNote',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Material ThemeData bridge — violet accent for Material widgets
      materialThemeBuilder: (context, theme) {
        final isDark = switch (themeMode) {
          ThemeMode.dark => true,
          ThemeMode.light => false,
          ThemeMode.system =>
            MediaQuery.platformBrightnessOf(context) == Brightness.dark,
        };
        return isDark ? AppTheme.materialDark : AppTheme.materialLight;
      },
      routerConfig: router,
    );
  }
}
