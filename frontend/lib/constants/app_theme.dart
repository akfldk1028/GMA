import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  AppTheme._();

  static ShadThemeData get light => ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
        textTheme: ShadTextTheme(
          family: 'Inter',
          h1: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3),
          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          h4: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  static ShadThemeData get dark => ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
        textTheme: ShadTextTheme(
          family: 'Inter',
          h1: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3),
          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          h4: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );
}
