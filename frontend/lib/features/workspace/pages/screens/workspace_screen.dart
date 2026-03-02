import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../pdf_viewer/drawing/pages/widgets/drawing_toolbar.dart';
import '../../../pdf_viewer/pages/screens/pdf_viewer_screen.dart';
import '../../../pdf_viewer/pages/widgets/marker_pills_strip.dart';
import '../../../scrapnote/pages/widgets/element_navigator_drawer.dart';
import '../../models/pdf_marker_model.dart';
import '../../models/workspace_state.dart';
import '../providers/workspace_provider.dart';
import '../widgets/file_browser_drawer.dart';
import '../widgets/live_scraps_panel.dart';
import '../widgets/marker_edit_modal.dart';
import '../widgets/note_editor_modal.dart';
import '../widgets/page_thumbnails_panel.dart';
import '../widgets/sticky_note_widget.dart';
import '../widgets/workspace_header_v3.dart';

/// Main workspace screen: 3-panel layout with PDF + page nav + live scraps.
///
/// Desktop layout:
/// ┌──────────────────────────────────────────────────────────┐
/// │ WorkspaceHeaderV3 (48px)                                │
/// ├──────────────────────────────────────────────────────────┤
/// │ DrawingToolbar (when note loaded)                       │
/// ├────────┬──────┬─────────────────────────┬───────────────┤
/// │ Page   │ M    │                         │ Live          │
/// │ Thumb  │ A    │  PDF Viewer             │ Scraps        │
/// │ nails  │ R    │  (pdfrx)                │ Panel         │
/// │ (180)  │ K    │                         │ (280)         │
/// │        │ E    │                         │               │
/// │ Toggle │ R    │                         │ Toggle        │
/// │ able   │ S    │                         │ able          │
/// │        │~72px │                         │               │
/// └────────┴──────┴─────────────────────────┴───────────────┘
///
/// Mobile layout:
/// ┌──────────────────┐
/// │ Header (48px)    │
/// ├──────────────────┤
/// │ DrawingToolbar   │
/// ├──────────────────┤
/// │                  │
/// │  PDF Viewer      │
/// │  (full width)    │
/// │                  │
/// ├──────────────────┤
/// │ MarkerPillsStrip │
/// │ (horizontal,52px)│
/// └──────────────────┘
class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  late final PdfViewerController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  // ─── Text selection → modal flow ─────────────────────────

  void _handleAddMarkerPressed({
    required int pageNumber,
    String? selectedText,
    PdfRect? textRect,
  }) {
    ref.read(workspaceProviderProvider.notifier).openMarkerEditModal(
          pageNumber: pageNumber,
          selectedText: selectedText,
          textRect: textRect,
        );
  }

  // ─── Marker pill interactions ────────────────────────────

  void _handleMarkerPillTap(PdfMarker marker) {
    if (marker.textRect != null) {
      _pdfController.goToRectInsidePage(
        pageNumber: marker.pageNumber,
        rect: marker.textRect!,
      );
    } else {
      _pdfController.goToPage(pageNumber: marker.pageNumber);
    }
  }

  void _handleMarkerPillLongPress(PdfMarker marker) {
    ref.read(workspaceProviderProvider.notifier).openEditorModal();
  }

  // ─── Marker click in note editor → PDF jump ──────────────

  Future<void> _handleMarkerClick(String markerId) async {
    final workspaceState = ref.read(workspaceProviderProvider).valueOrNull;
    if (workspaceState?.currentPdfPath == null) {
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('No PDF Loaded'),
            description:
                Text('Please open a PDF file to navigate to markers.'),
          ),
        );
      }
      return;
    }

    try {
      if (markerId.startsWith('page:')) {
        final pagePart = markerId.substring(5);
        final parts = pagePart.split('-');
        final pageNumber = int.tryParse(parts[0]);
        final subNumber =
            parts.length > 1 ? (int.tryParse(parts[1]) ?? 1) : 1;

        if (pageNumber != null && pageNumber > 0) {
          final pageMarkers = workspaceState?.markers
                  .where((m) => m.pageNumber == pageNumber)
                  .toList() ??
              [];

          if (subNumber >= 1 && subNumber <= pageMarkers.length) {
            final marker = pageMarkers[subNumber - 1];
            if (marker.textRect != null) {
              _pdfController.goToRectInsidePage(
                pageNumber: pageNumber,
                rect: marker.textRect!,
              );
              return;
            }
          }
          _pdfController.goToPage(pageNumber: pageNumber);
          return;
        }
      }

      final elementPage = await ref
          .read(workspaceProviderProvider.notifier)
          .navigateToElement(markerId);
      if (elementPage != null) {
        if (!mounted) return;
        _pdfController.goToPage(pageNumber: elementPage);
        return;
      }

      final marker = await ref
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(markerId);

      if (marker == null) {
        if (mounted) {
          ShadToaster.of(context).show(
            const ShadToast.destructive(
              title: Text('Marker Not Found'),
              description: Text('The selected marker could not be found.'),
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      if (marker.textRect != null) {
        _pdfController.goToRectInsidePage(
          pageNumber: marker.pageNumber,
          rect: marker.textRect!,
        );
      } else {
        _pdfController.goToPage(pageNumber: marker.pageNumber);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Navigation Error'),
            description:
                Text('Failed to navigate to marker: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // ─── Keyboard shortcuts ──────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final notifier = ref.read(workspaceProviderProvider.notifier);

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      final s = ref.read(workspaceProviderProvider).valueOrNull;
      if (s == null) return KeyEventResult.ignored;
      if (s.isMarkerEditModalOpen) {
        notifier.closeMarkerEditModal();
        return KeyEventResult.handled;
      }
      if (s.isEditorModalOpen) {
        notifier.closeEditorModal();
        return KeyEventResult.handled;
      }
      if (s.isFileBrowserOpen) {
        notifier.closeFileBrowser();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.keyE &&
        HardwareKeyboard.instance.isControlPressed) {
      final s = ref.read(workspaceProviderProvider).valueOrNull;
      if (s == null) return KeyEventResult.ignored;
      if (s.isEditorModalOpen) {
        notifier.closeEditorModal();
      } else {
        notifier.openEditorModal();
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyB &&
        HardwareKeyboard.instance.isControlPressed) {
      notifier.toggleFileBrowser();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ─── Mobile bottom sheet helpers ──────────────────────────

  void _showPageThumbnailsSheet(BuildContext context) {
    final theme = ShadTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageThumbnailsPanel(
                controller: _pdfController,
                isSheet: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLiveScrapsSheet(BuildContext context) {
    final theme = ShadTheme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, controller) {
          final notifier = ref.read(workspaceProviderProvider.notifier);
          return LiveScrapsPanel(
            isSheet: true,
            onElementTap: (element) async {
              Navigator.of(ctx).pop();
              final page = await notifier.navigateToElement(element.id);
              if (page != null && mounted) {
                await _pdfController.goToPage(pageNumber: page);
              }
            },
          );
        },
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final workspaceAsync = ref.watch(workspaceProviderProvider);

    return workspaceAsync.when(
      data: (state) => _buildWorkspace(context, state),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(
            'Error loading workspace: $error',
            style: ShadTheme.of(context).textTheme.p,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspace(BuildContext context, WorkspaceState state) {
    final isMobile = Responsive.isMobile(context);
    return isMobile
        ? _buildMobileWorkspace(context, state)
        : _buildDesktopWorkspace(context, state);
  }

  // ─── Mobile workspace ─────────────────────────────────────

  Widget _buildMobileWorkspace(BuildContext context, WorkspaceState state) {
    final notifier = ref.read(workspaceProviderProvider.notifier);

    return Focus(
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // ── Base layer: Header + Toolbar + PDF ──
              Column(
                children: [
                  // Header V3 (with mobile sheet callbacks)
                  WorkspaceHeaderV3(
                    onToggleEditor: () {
                      if (state.isEditorModalOpen) {
                        notifier.closeEditorModal();
                      } else {
                        notifier.openEditorModal();
                      }
                    },
                    onTogglePageNav: () => _showPageThumbnailsSheet(context),
                    onToggleLiveScraps: () => _showLiveScrapsSheet(context),
                  ),

                  // Drawing toolbar (scrollable on mobile)
                  if (state.currentNoteId != null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: ShadTheme.of(context).colorScheme.border,
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        child: DrawingToolbar(
                          noteId: state.currentNoteId,
                          pageNumber: _pdfController.isReady
                              ? _pdfController.pageNumber
                              : null,
                        ),
                      ),
                    ),

                  // PDF viewer (full width)
                  Expanded(
                    child: PdfViewerScreen(
                      controller: _pdfController,
                      onAddMarkerPressed: _handleAddMarkerPressed,
                      noteId: state.currentNoteId,
                      externalToolbar: true,
                    ),
                  ),

                  // Marker pills strip (horizontal at bottom)
                  MarkerPillsStrip(
                    axis: Axis.horizontal,
                    onMarkerTap: _handleMarkerPillTap,
                    onMarkerLongPress: _handleMarkerPillLongPress,
                  ),
                ],
              ),

              // ── Overlay: Sidebar drawers ──
              if (state.isFileBrowserOpen &&
                  state.sidebarMode == SidebarMode.fileBrowser)
                FileBrowserDrawer(
                  onClose: () => notifier.closeFileBrowser(),
                  onNoteSelected: (note) async {
                    await notifier.loadNote(note.id);
                    if (note.hasLinkedPdf) {
                      await notifier.loadPdf(note.linkedPdfPath!);
                    }
                  },
                ),
              if (state.isFileBrowserOpen &&
                  state.sidebarMode == SidebarMode.elementNavigator)
                ElementNavigatorDrawer(
                  onClose: () => notifier.closeFileBrowser(),
                  onElementTap: (element) async {
                    final page =
                        await notifier.navigateToElement(element.id);
                    if (page != null && mounted) {
                      await _pdfController.goToPage(pageNumber: page);
                    }
                  },
                ),

              // ── Overlay: Note editor modal (full screen on mobile) ──
              if (state.isEditorModalOpen)
                NoteEditorModal(
                  noteId: state.currentNoteId,
                  onClose: () => notifier.closeEditorModal(),
                  onMarkerClick: _handleMarkerClick,
                ),

              // ── Overlay: Marker edit modal ──
              if (state.isMarkerEditModalOpen)
                MarkerEditModal(
                  onClose: () => notifier.closeMarkerEditModal(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Desktop workspace ────────────────────────────────────

  Widget _buildDesktopWorkspace(BuildContext context, WorkspaceState state) {
    final notifier = ref.read(workspaceProviderProvider.notifier);

    return Focus(
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Base layer: Header + Toolbar + 3-panel layout ──
            Column(
              children: [
                // Header V3
                WorkspaceHeaderV3(
                  onToggleEditor: () {
                    if (state.isEditorModalOpen) {
                      notifier.closeEditorModal();
                    } else {
                      notifier.openEditorModal();
                    }
                  },
                  onTogglePageNav: () => notifier.togglePageNav(),
                  onToggleLiveScraps: () => notifier.toggleLiveScraps(),
                ),

                // Drawing toolbar
                if (state.currentNoteId != null)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: ShadTheme.of(context).colorScheme.border,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DrawingToolbar(
                            noteId: state.currentNoteId,
                            pageNumber: _pdfController.isReady
                                ? _pdfController.pageNumber
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main content: Page Nav + Markers + PDF + Live Scraps
                Expanded(
                  child: Row(
                    children: [
                      // Page thumbnails panel (togglable)
                      if (state.isPageNavOpen)
                        PageThumbnailsPanel(controller: _pdfController),

                      // Marker pills strip
                      MarkerPillsStrip(
                        onMarkerTap: _handleMarkerPillTap,
                        onMarkerLongPress: _handleMarkerPillLongPress,
                      ),

                      // PDF viewer
                      Expanded(
                        child: PdfViewerScreen(
                          controller: _pdfController,
                          onAddMarkerPressed: _handleAddMarkerPressed,
                          noteId: state.currentNoteId,
                          externalToolbar: true,
                        ),
                      ),

                      // Live scraps panel (togglable)
                      if (state.isLiveScrapsOpen)
                        LiveScrapsPanel(
                          onElementTap: (element) async {
                            final page = await notifier
                                .navigateToElement(element.id);
                            if (page != null && mounted) {
                              await _pdfController.goToPage(
                                  pageNumber: page);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Overlay: Sidebar drawers ──
            if (state.isFileBrowserOpen &&
                state.sidebarMode == SidebarMode.fileBrowser)
              FileBrowserDrawer(
                onClose: () => notifier.closeFileBrowser(),
                onNoteSelected: (note) async {
                  await notifier.loadNote(note.id);
                  if (note.hasLinkedPdf) {
                    await notifier.loadPdf(note.linkedPdfPath!);
                  }
                },
              ),
            if (state.isFileBrowserOpen &&
                state.sidebarMode == SidebarMode.elementNavigator)
              ElementNavigatorDrawer(
                onClose: () => notifier.closeFileBrowser(),
                onElementTap: (element) async {
                  final page = await notifier.navigateToElement(element.id);
                  if (page != null && mounted) {
                    await _pdfController.goToPage(pageNumber: page);
                  }
                },
              ),

            // ── Overlay: Sticky note ──
            if (state.isStickyNoteVisible && state.currentNoteId != null)
              StickyNoteWidget(
                noteId: state.currentNoteId,
                onMarkerClick: _handleMarkerClick,
              ),

            // ── Overlay: Note editor modal ──
            if (state.isEditorModalOpen)
              NoteEditorModal(
                noteId: state.currentNoteId,
                onClose: () => notifier.closeEditorModal(),
                onMarkerClick: _handleMarkerClick,
              ),

            // ── Overlay: Marker edit modal ──
            if (state.isMarkerEditModalOpen)
              MarkerEditModal(
                onClose: () => notifier.closeMarkerEditModal(),
              ),
          ],
        ),
      ),
    );
  }
}
