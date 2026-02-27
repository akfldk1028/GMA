import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// Provider that manages theme mode (light/dark) with Hive persistence.
///
/// This provider:
/// - Loads saved theme mode from Hive on initialization
/// - Persists theme changes across app restarts
/// - Provides methods to toggle or set theme mode
///
/// Usage:
/// ```dart
/// final themeMode = ref.watch(themeModeProvider);
/// ref.read(themeModeProvider.notifier).toggleTheme();
/// ```
@riverpod
class ThemeMode$ extends _$ThemeMode$ {
  static const String _boxName = 'app_settings';
  static const String _themeModeKey = 'theme_mode';

  @override
  ThemeMode build() {
    // Load theme mode from Hive synchronously
    final box = Hive.box(_boxName);
    final savedMode = box.get(_themeModeKey, defaultValue: 'light');

    return _parseThemeMode(savedMode as String);
  }

  /// Parse string to ThemeMode enum
  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  /// Convert ThemeMode enum to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Set theme mode and persist to Hive
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    // Persist to Hive
    final box = Hive.box(_boxName);
    await box.put(_themeModeKey, _themeModeToString(mode));
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Check if current theme is dark
  bool get isDark => state == ThemeMode.dark;

  /// Check if current theme is light
  bool get isLight => state == ThemeMode.light;
}

/// Helper provider to check if dark theme is active
@riverpod
bool isDarkTheme(Ref ref) {
  final themeMode = ref.watch(themeMode$Provider);
  return themeMode == ThemeMode.dark;
}
