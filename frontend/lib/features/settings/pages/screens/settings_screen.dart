import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../workspace/pages/providers/theme_provider.dart';

/// Settings screen with theme, about, and keyboard shortcuts.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeMode$Provider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ShadButton.outline(
                    onPressed: () => context.pop(),
                    size: ShadButtonSize.sm,
                    child: const Icon(Icons.arrow_back, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Text('Settings', style: theme.textTheme.h4),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Appearance section
                      _SectionHeader(title: 'Appearance', theme: theme),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        theme: theme,
                        children: [
                          _SettingsRow(
                            theme: theme,
                            icon: Icons.palette_outlined,
                            title: 'Theme',
                            subtitle: _themeModeLabel(themeMode),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ThemeButton(
                                  label: 'Light',
                                  icon: Icons.light_mode,
                                  isSelected: themeMode == ThemeMode.light,
                                  onTap: () => ref
                                      .read(themeMode$Provider.notifier)
                                      .setThemeMode(ThemeMode.light),
                                  theme: theme,
                                ),
                                const SizedBox(width: 4),
                                _ThemeButton(
                                  label: 'Dark',
                                  icon: Icons.dark_mode,
                                  isSelected: themeMode == ThemeMode.dark,
                                  onTap: () => ref
                                      .read(themeMode$Provider.notifier)
                                      .setThemeMode(ThemeMode.dark),
                                  theme: theme,
                                ),
                                const SizedBox(width: 4),
                                _ThemeButton(
                                  label: 'System',
                                  icon: Icons.settings_brightness,
                                  isSelected: themeMode == ThemeMode.system,
                                  onTap: () => ref
                                      .read(themeMode$Provider.notifier)
                                      .setThemeMode(ThemeMode.system),
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Editor section
                      _SectionHeader(title: 'Editor', theme: theme),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        theme: theme,
                        children: [
                          _SettingsRow(
                            theme: theme,
                            icon: Icons.text_fields,
                            title: 'Font Family',
                            subtitle: 'Monospace',
                          ),
                          _divider(theme),
                          _SettingsRow(
                            theme: theme,
                            icon: Icons.format_size,
                            title: 'Font Size',
                            subtitle: '14px',
                          ),
                          _divider(theme),
                          _SettingsRow(
                            theme: theme,
                            icon: Icons.save_outlined,
                            title: 'Auto-save',
                            subtitle: 'Save after 2 seconds of inactivity',
                            trailing: ShadSwitch(
                              value: true,
                              onChanged: (_) {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Keyboard Shortcuts section
                      _SectionHeader(title: 'Keyboard Shortcuts', theme: theme),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        theme: theme,
                        children: [
                          _ShortcutRow(theme: theme, label: 'Open PDF', shortcut: 'Ctrl+O'),
                          _divider(theme),
                          _ShortcutRow(theme: theme, label: 'Save Note', shortcut: 'Ctrl+S'),
                          _divider(theme),
                          _ShortcutRow(theme: theme, label: 'New Note', shortcut: 'Ctrl+N'),
                          _divider(theme),
                          _ShortcutRow(theme: theme, label: 'Toggle Sidebar', shortcut: 'Ctrl+B'),
                          _divider(theme),
                          _ShortcutRow(theme: theme, label: 'Toggle Theme', shortcut: 'Ctrl+Shift+T'),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // About section
                      _SectionHeader(title: 'About', theme: theme),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        theme: theme,
                        children: [
                          _SettingsRow(
                            theme: theme,
                            icon: Icons.info_outline,
                            title: 'GMA',
                            subtitle: 'PDF-Linked Markdown Annotation App',
                          ),
                          _divider(theme),
                          _SettingsRow(
                            theme: theme,
                            icon: Icons.tag,
                            title: 'Version',
                            subtitle: '1.0.0',
                          ),
                          _divider(theme),
                          _SettingsRow(
                            theme: theme,
                            icon: Icons.code,
                            title: 'Built with',
                            subtitle: 'Flutter + pdfrx + shadcn_ui',
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  static Widget _divider(ShadThemeData theme) {
    return Divider(height: 1, color: theme.colorScheme.border);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});
  final String title;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.large.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.theme, required this.children});
  final ShadThemeData theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final ShadThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: theme.textTheme.muted.copyWith(fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      onPressed: onTap,
      size: ShadButtonSize.sm,
      backgroundColor: isSelected ? theme.colorScheme.primary : null,
      foregroundColor: isSelected ? theme.colorScheme.primaryForeground : null,
      child: Icon(icon, size: 16),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.theme,
    required this.label,
    required this.shortcut,
  });
  final ShadThemeData theme;
  final String label;
  final String shortcut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.small),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: theme.colorScheme.muted,
            ),
            child: Text(
              shortcut,
              style: theme.textTheme.muted.copyWith(
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
