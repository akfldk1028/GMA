import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../file_manager/models/note_metadata_model.dart';
import '../../../file_manager/pages/screens/file_browser_screen.dart';

/// Drawer wrapper for FileBrowserScreen.
/// Slides in from the left over the PDF viewer.
class FileBrowserDrawer extends ConsumerStatefulWidget {
  const FileBrowserDrawer({
    super.key,
    required this.onClose,
    required this.onNoteSelected,
  });

  final VoidCallback onClose;
  final void Function(NoteMetadata note) onNoteSelected;

  @override
  ConsumerState<FileBrowserDrawer> createState() => _FileBrowserDrawerState();
}

class _FileBrowserDrawerState extends ConsumerState<FileBrowserDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
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

    return FadeTransition(
      opacity: _fadeAnim,
      child: Stack(
        children: [
          // Dimmed background — tap to close
          GestureDetector(
            onTap: _close,
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          // Slide-in drawer
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: Responsive.isMobile(context)
                ? MediaQuery.sizeOf(context).width * 0.85
                : 300,
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  border: Border(
                    right: BorderSide(color: theme.colorScheme.border),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(4, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drawer header with close button
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: theme.colorScheme.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text('Files', style: theme.textTheme.small),
                          const Spacer(),
                          ShadButton.ghost(
                            onPressed: _close,
                            size: ShadButtonSize.sm,
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                    // FileBrowserScreen — reused as-is
                    Expanded(
                      child: FileBrowserScreen(
                        onNoteSelected: (note) {
                          widget.onNoteSelected(note);
                          _close();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
