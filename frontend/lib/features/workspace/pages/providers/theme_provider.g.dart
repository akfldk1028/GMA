// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isDarkThemeHash() => r'f40c8a1f888dbbe58fb21cd024e00d654a0b16d3';

/// Helper provider to check if dark theme is active
///
/// Copied from [isDarkTheme].
@ProviderFor(isDarkTheme)
final isDarkThemeProvider = AutoDisposeProvider<bool>.internal(
  isDarkTheme,
  name: r'isDarkThemeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isDarkThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsDarkThemeRef = AutoDisposeProviderRef<bool>;
String _$themeMode$Hash() => r'884016ec5f4e0801353943c4df76589cb7185cfb';

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
///
/// Copied from [ThemeMode$].
@ProviderFor(ThemeMode$)
final themeMode$Provider =
    AutoDisposeNotifierProvider<ThemeMode$, ThemeMode>.internal(
      ThemeMode$.new,
      name: r'themeMode$Provider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeMode$Hash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeMode$ = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
