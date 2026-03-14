import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../note_editor/pages/screens/note_editor_screen.dart';

/// Center modal overlay for NoteEditorScreen.
/// On desktop: covers 85% width / 90% height with dimmed background.
/// On mobile: full screen, no dismiss-on-tap.
class NoteEditorModal extends ConsumerStatefulWidget {
  const NoteEditorModal({
    super.key,
    required this.noteId,
    required this.onClose,
    required this.onMarkerClick,
  });

  final String? noteId;
  final VoidCallback onClose;
  final OnMarkerClickCallback? onMarkerClick;

  @override
  ConsumerState<NoteEditorModal> createState() => _NoteEditorModalState();
}

class _NoteEditorModalState extends ConsumerState<NoteEditorModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _animController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = Responsive.isMobile(context);

    final modalWidth = isMobile ? screenSize.width : screenSize.width * 0.85;
    final modalHeight =
        isMobile ? screenSize.height : screenSize.height * 0.90;
    final borderRadius = isMobile ? 0.0 : 16.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
        children: [
          // Dimmed background — tap to close (disabled on mobile)
          GestureDetector(
            onTap: isMobile ? null : _close,
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          // Center modal
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: modalWidth,
                height: modalHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: isMobile
                      ? null
                      : Border.all(color: theme.colorScheme.border),
                  boxShadow: isMobile
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Modal header with title + close
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: theme.colorScheme.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note,
                              size: 18,
                              color: theme.colorScheme.mutedForeground),
                          const SizedBox(width: 8),
                          Text('Note Editor',
                              style: theme.textTheme.small.copyWith(
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          ShadButton.ghost(
                            onPressed: _close,
                            size: ShadButtonSize.sm,
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                    // NoteEditorScreen content
                    Expanded(
                      child: NoteEditorScreen(
                        noteId: widget.noteId,
                        onMarkerClick: widget.onMarkerClick,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
