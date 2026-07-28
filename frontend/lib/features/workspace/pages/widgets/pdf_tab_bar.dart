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
    // Always show tab bar per 기획안 슬라이드 2 (even with 1 PDF)
    if (openPdfs.isEmpty) return const SizedBox.shrink();

    final activePath = ws.currentPdfPath;

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.sokBackground,
        border: Border(bottom: BorderSide(color: AppColors.sokDivider)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 8, top: 4),
        itemCount: openPdfs.length,
        itemBuilder: (context, index) {
          final path = openPdfs[index];
          final isActive = path == activePath;
          return _PdfTab(
            label: _extractLabel(path),
            isActive: isActive,
            onTap: () =>
                ref.read(workspaceProviderProvider.notifier).switchPdfTab(path),
            onClose: () =>
                ref.read(workspaceProviderProvider.notifier).closePdfTab(path),
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
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.only(left: 12, right: 6),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.sokHover
                : _isHovered
                ? AppColors.sokSurface
                : AppColors.sokSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.sokDivider
                  : AppColors.sokDivider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 14,
                color: widget.isActive
                    ? AppColors.sokAccent
                    : AppColors.sokSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.isActive
                      ? AppColors.sokAccent
                      : AppColors.sokPrimary,
                ),
              ),
              const SizedBox(width: 4),
              // Close button
              IconButton(
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 20,
                  height: 20,
                ),
                iconSize: 12,
                color: _isHovered || widget.isActive
                    ? AppColors.textSecondary
                    : Colors.transparent,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
