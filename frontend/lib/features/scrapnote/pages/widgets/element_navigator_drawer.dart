import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../gma_md/widgets/element_card.dart';
import '../../../note_editor/pages/providers/note_editor_provider.dart';
import '../../../scraps_library/pages/providers/scraps_filter_provider.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../../../../constants/app_colors.dart';
import '../../models/element_model.dart';
import '../../providers/element_store.dart';
import '../../utils/element_ref_parser.dart';

/// Drawer that shows all ScrapElements referenced in the current note.
/// Slides in from the left, same pattern as FileBrowserDrawer.
class ElementNavigatorDrawer extends ConsumerStatefulWidget {
  const ElementNavigatorDrawer({
    super.key,
    required this.onClose,
    required this.onElementTap,
  });

  final VoidCallback onClose;
  final void Function(ScrapElement element) onElementTap;

  @override
  ConsumerState<ElementNavigatorDrawer> createState() =>
      _ElementNavigatorDrawerState();
}

class _ElementNavigatorDrawerState
    extends ConsumerState<ElementNavigatorDrawer>
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
    if (!mounted) return;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final ws = ref.watch(workspaceProviderProvider).valueOrNull;
    final noteId = ws?.currentNoteId;
    final activeFilter = ref.watch(scrapsFilterProvider);

    // Get element IDs from current note content
    final allElements = <ScrapElement>[];
    if (noteId != null) {
      final controller = ref.watch(noteEditorProvider(noteId));
      final content = controller?.text ?? '';
      final ids = ElementRefParser.extractElementIds(content);
      // Watch revision counter so we rebuild when elements change
      ref.watch(elementStoreProvider);
      final store = ref.read(elementStoreProvider.notifier);
      for (final id in ids) {
        final el = store.getById(id);
        if (el != null) allElements.add(el);
      }
    }

    // Apply filter
    final elements = activeFilter == null
        ? allElements
        : allElements.where((e) => e.type == activeFilter).toList();

    return FadeTransition(
      opacity: _fadeAnim,
      child: Stack(
        children: [
          // Dimmed background — tap to close
          GestureDetector(
            onTap: _close,
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          // Slide-in drawer (left 300px)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 300,
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
                    // Header
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: theme.colorScheme.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.collections_bookmark, size: 16),
                          const SizedBox(width: 8),
                          Text('Elements', style: theme.textTheme.small),
                          const Spacer(),
                          ShadButton.ghost(
                            onPressed: _close,
                            size: ShadButtonSize.sm,
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                    // Filter tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: _ElementFilterTabs(
                        activeFilter: activeFilter,
                        onFilterChanged: (type) => ref
                            .read(scrapsFilterProvider.notifier)
                            .setFilter(type),
                      ),
                    ),
                    // Element list
                    Expanded(
                      child: elements.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  noteId == null
                                      ? 'No note open'
                                      : activeFilter != null
                                          ? 'No ${activeFilter.name} elements.'
                                          : 'No elements in this note.\nUse @el <id> in a :::scrapnote block.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.mutedForeground,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount: elements.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 4),
                              itemBuilder: (context, index) {
                                final el = elements[index];
                                return ElementCard(
                                  element: el,
                                  onTap: () {
                                    widget.onElementTap(el);
                                  },
                                );
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

/// Compact filter tabs for the element navigator drawer.
class _ElementFilterTabs extends StatelessWidget {
  const _ElementFilterTabs({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final ElementType? activeFilter;
  final ValueChanged<ElementType?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isActive: activeFilter == null,
            onTap: () => onFilterChanged(null),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Highlight',
            icon: Icons.format_quote_rounded,
            isActive: activeFilter == ElementType.highlight,
            onTap: () => onFilterChanged(ElementType.highlight),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Capture',
            icon: Icons.image_rounded,
            isActive: activeFilter == ElementType.capture,
            onTap: () => onFilterChanged(ElementType.capture),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Drawing',
            icon: Icons.brush_rounded,
            isActive: activeFilter == ElementType.drawing,
            onTap: () => onFilterChanged(ElementType.drawing),
          ),
        ],
      ),
    );
  }
}

/// Single filter chip with hover and active states.
class _FilterChip extends StatefulWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: widget.isActive ? AppColors.primaryGradient : null,
            color: widget.isActive
                ? null
                : _isHovered
                    ? AppColors.surfaceHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isActive
                  ? Colors.transparent
                  : _isHovered
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 12,
                  color: widget.isActive ? Colors.white : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isActive
                      ? Colors.white
                      : _isHovered
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
