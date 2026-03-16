import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../constants/app_colors.dart';
import '../providers/workspace_provider.dart';

/// Horizontal tab bar showing currently open PDF documents.
///
/// Each tab displays the PDF filename with a close button.
/// Tapping a tab switches to that PDF; tapping close removes it.
class PdfTabBar extends ConsumerWidget {
  const PdfTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProviderProvider).valueOrNull;
    if (ws == null) return const SizedBox.shrink();

    final openPdfs = ws.openPdfPaths;
    if (openPdfs.length <= 1) return const SizedBox.shrink();

    final activePath = ws.currentPdfPath;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 4),
        itemCount: openPdfs.length,
        itemBuilder: (context, index) {
          final path = openPdfs[index];
          final isActive = path == activePath;
          return _PdfTab(
            label: _extractLabel(path),
            isActive: isActive,
            onTap: () => ref
                .read(workspaceProviderProvider.notifier)
                .switchPdfTab(path),
            onClose: () => ref
                .read(workspaceProviderProvider.notifier)
                .closePdfTab(path),
          );
        },
      ),
    );
  }

  String _extractLabel(String pdfPath) {
    if (pdfPath.startsWith('assets/')) {
      return p.basenameWithoutExtension(pdfPath);
    }
    final name = p.basenameWithoutExtension(pdfPath);
    return name.length > 24 ? '${name.substring(0, 22)}...' : name;
  }
}

class _PdfTab extends StatefulWidget {
  const _PdfTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  State<_PdfTab> createState() => _PdfTabState();
}

class _PdfTabState extends State<_PdfTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          padding: const EdgeInsets.only(left: 10, right: 4),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : _isHovered
                    ? AppColors.surfaceHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 13,
                color: widget.isActive
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      widget.isActive ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              // Close button
              InkWell(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: _isHovered || widget.isActive
                        ? AppColors.textSecondary
                        : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
