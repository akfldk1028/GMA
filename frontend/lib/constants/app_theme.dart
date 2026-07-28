import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final _textTheme = ShadTextTheme(
    family: 'Inter',
    h1: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3),
    h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    h4: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );

  /// Material ThemeData bridge — ensures Material widgets (ElevatedButton,
  /// CircularProgressIndicator, TextField, etc.) use violet accent colors
  /// instead of the default blue.
  static final ThemeData materialLight = ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        brightness: Brightness.light,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppColors.primary.withValues(alpha: 0.4),
          cursorColor: AppColors.primary,
          selectionHandleColor: AppColors.primary,
        ),
      );

  static final ThemeData materialDark = ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        brightness: Brightness.dark,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppColors.primary.withValues(alpha: 0.4),
          cursorColor: AppColors.primary,
          selectionHandleColor: AppColors.primary,
        ),
      );

  static final ShadThemeData light = ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadVioletColorScheme.light(),
        textTheme: _textTheme,
      );

  static final ShadThemeData dark = ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadVioletColorScheme.dark(),
        textTheme: _textTheme,
      );
}
