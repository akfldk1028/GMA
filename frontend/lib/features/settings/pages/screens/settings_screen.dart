import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../ocr/pages/providers/ocr_provider.dart';
import '../../../pdf_structure/services/pdf_structure_service.dart';
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

                      // OCR section
                      _SectionHeader(title: 'OCR (Local LLM)', theme: theme),
                      const SizedBox(height: 12),
                      _OcrSettingsSection(theme: theme),

                      const SizedBox(height: 32),

                      // PDF Structure section
                      _SectionHeader(title: 'PDF Structure Analysis', theme: theme),
                      const SizedBox(height: 12),
                      _PdfStructureSettingsSection(theme: theme),

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
          if (trailing != null) ...[trailing!],
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

/// OCR settings section — Ollama URL, model, enable toggle, connection test.
class _OcrSettingsSection extends ConsumerStatefulWidget {
  const _OcrSettingsSection({required this.theme});
  final ShadThemeData theme;

  @override
  ConsumerState<_OcrSettingsSection> createState() =>
      _OcrSettingsSectionState();
}

class _OcrSettingsSectionState extends ConsumerState<_OcrSettingsSection> {
  late TextEditingController _urlController;
  late TextEditingController _modelController;
  bool _controllersInitialized = false;
  bool _testing = false;
  bool? _testResult;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _modelController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _initControllers(OcrSettingsData settings) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;
    _urlController.text = settings.ollamaUrl;
    _modelController.text = settings.modelName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final ocrAsync = ref.watch(ocrSettingsProvider);

    return ocrAsync.when(
      loading: () => _SettingsCard(
        theme: theme,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
          ),
        ],
      ),
      error: (e, _) => _SettingsCard(
        theme: theme,
        children: [
          _SettingsRow(
            theme: theme,
            icon: Icons.error_outline,
            title: 'OCR Settings Error',
            subtitle: e.toString(),
          ),
        ],
      ),
      data: (settings) {
        _initControllers(settings);
        return _SettingsCard(
          theme: theme,
          children: [
            _SettingsRow(
              theme: theme,
              icon: Icons.document_scanner_outlined,
              title: 'Enable OCR',
              subtitle: 'Use local LLM for image-based PDF text extraction',
              trailing: ShadSwitch(
                value: settings.isEnabled,
                onChanged: (v) =>
                    ref.read(ocrSettingsProvider.notifier).setEnabled(v),
              ),
            ),
            SettingsScreen._divider(theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.dns_outlined,
                      size: 20, color: theme.colorScheme.mutedForeground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ollama Server URL',
                            style: theme.textTheme.small
                                .copyWith(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        ShadInput(
                          controller: _urlController,
                          placeholder: const Text('http://localhost:11434'),
                          onChanged: (v) => ref
                              .read(ocrSettingsProvider.notifier)
                              .setOllamaUrl(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SettingsScreen._divider(theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.smart_toy_outlined,
                      size: 20, color: theme.colorScheme.mutedForeground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Model Name',
                            style: theme.textTheme.small
                                .copyWith(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        ShadInput(
                          controller: _modelController,
                          placeholder: const Text('llava'),
                          onChanged: (v) => ref
                              .read(ocrSettingsProvider.notifier)
                              .setModelName(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SettingsScreen._divider(theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.wifi_tethering,
                      size: 20, color: theme.colorScheme.mutedForeground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Connection Test',
                            style: theme.textTheme.small
                                .copyWith(fontWeight: FontWeight.w500)),
                        Text(
                          _testResult == null
                              ? 'Check if Ollama server is reachable'
                              : _testResult!
                                  ? 'Connected successfully'
                                  : 'Connection failed',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ShadButton.outline(
                    onPressed: _testing ? null : _testConnection,
                    size: ShadButtonSize.sm,
                    child: _testing
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          )
                        : const Text('Test'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      final result =
          await ref.read(ocrSettingsProvider.notifier).testConnection();
      if (mounted) {
        setState(() {
          _testing = false;
          _testResult = result;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _testing = false;
          _testResult = false;
        });
      }
    }
  }
}

/// PDF Structure Analysis settings section.
class _PdfStructureSettingsSection extends ConsumerStatefulWidget {
  const _PdfStructureSettingsSection({required this.theme});
  final ShadThemeData theme;

  @override
  ConsumerState<_PdfStructureSettingsSection> createState() =>
      _PdfStructureSettingsSectionState();
}

class _PdfStructureSettingsSectionState
    extends ConsumerState<_PdfStructureSettingsSection> {
  bool? _javaAvailable;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _checkJava();
  }

  Future<void> _checkJava() async {
    setState(() => _checking = true);
    final ok = await PdfStructureService.isJavaAvailable();
    if (mounted) {
      setState(() {
        _javaAvailable = ok;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      theme: widget.theme,
      children: [
        _SettingsRow(
          theme: widget.theme,
          icon: Icons.account_tree_outlined,
          title: 'PDF Structure Analysis',
          subtitle: 'opendataloader-pdf (Java)',
          trailing: _checking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _javaAvailable == true
                      ? Icons.check_circle
                      : Icons.error_outline,
                  size: 18,
                  color: _javaAvailable == true
                      ? const Color(0xFF10B981)
                      : widget.theme.colorScheme.destructive,
                ),
        ),
        SettingsScreen._divider(widget.theme),
        _SettingsRow(
          theme: widget.theme,
          icon: Icons.coffee,
          title: 'Java Runtime',
          subtitle: _javaAvailable == null
              ? 'Checking...'
              : _javaAvailable == true
                  ? 'Available'
                  : 'Not found — install JDK 11+ from adoptium.net',
        ),
        SettingsScreen._divider(widget.theme),
        _SettingsRow(
          theme: widget.theme,
          icon: Icons.auto_awesome,
          title: 'Auto-analyze on PDF open',
          subtitle: 'Extract headings and structure when opening a PDF',
          trailing: ShadSwitch(
            value: true,
            onChanged: (_) {
              // TODO: persist to Hive app_settings
            },
          ),
        ),
      ],
    );
  }
}
