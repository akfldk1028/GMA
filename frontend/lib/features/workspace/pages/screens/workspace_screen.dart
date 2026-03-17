import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common_widgets/responsive.dart';
import '../../../pdf_viewer/pages/providers/pdf_document_provider.dart';
import '../../../pdf_viewer/pages/screens/pdf_viewer_screen.dart';
import '../../../scrapnote/pages/widgets/confirm_scrap_popup.dart';
import '../../../scrapnote/pages/widgets/element_navigator_drawer.dart';
import '../../../scrapnote/providers/scrap_insertion_provider.dart';
import '../../../../constants/marker_colors.dart';
import '../../models/workspace_state.dart';
import '../providers/workspace_provider.dart';
import '../widgets/file_browser_drawer.dart';
// MarkerEditModal replaced by ScrapBoardPopup
import '../widgets/note_editor_modal.dart';
import '../widgets/pdf_tab_bar.dart';
import '../widgets/scrap_board_popup.dart';
import '../widgets/workspace_canvas_panel.dart';
import '../widgets/scrap_thumbnails_sidebar.dart';
import '../widgets/sticky_note_widget.dart';
import '../widgets/workspace_unified_header.dart';

/// Main workspace screen: new 3-panel layout per 260316 기획안.
///
/// Desktop layout:
/// ┌──────────────────────────────────────────────────────────┐
/// │ UnifiedHeader (< 제목 | 도구들 | ⋮)                       │
/// ├──────────────────────────────────────────────────────────┤
/// │ PdfTabBar (열린 PDF 탭)                                   │
/// ├──────────┬────────────────────────────┬───────────────────┤
/// │ Scrap    │                            │  ScrapNote        │
/// │ Thumbs   │  PDF Viewer                │  Card Panel       │
/// │ Sidebar  │  (비례 조절)                │  (접기/위치전환)   │
/// │ (140px)  │                            │  (flex)           │
/// └──────────┴────────────────────────────┴───────────────────┘
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
    debugPrint('[WorkspaceScreen._handleAddMarkerPressed] page: $pageNumber, text: ${selectedText != null ? selectedText.substring(0, selectedText.length.clamp(0, 50)) : null}, hasRect: ${textRect != null}');
    final ws = ref.read(workspaceProviderProvider).valueOrNull;
    debugPrint('[WorkspaceScreen._handleAddMarkerPressed] quickScrapMode: ${ws?.isQuickScrapMode}, noteId: ${ws?.currentNoteId}');

    // Quick scrap mode: create instantly without popup (슬라이드 10~12)
    if (ws?.isQuickScrapMode == true) {
      debugPrint('[WorkspaceScreen._handleAddMarkerPressed] quick scrap mode, creating instantly');
      ref.read(workspaceProviderProvider.notifier).createMarker(
            pageNumber: pageNumber,
            color: MarkerColor.green,
            selectedText: selectedText,
            textRect: textRect,
          );
      return;
    }

    // Normal mode: open ScrapBoardPopup (슬라이드 7~9)
    debugPrint('[WorkspaceScreen._handleAddMarkerPressed] normal mode, opening scrap board');
    ref.read(workspaceProviderProvider.notifier).openScrapBoard(
          pageNumber: pageNumber,
          selectedText: selectedText,
          textRect: textRect,
        );
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

  // ─── Scrap board confirm → create marker + element ──────

  Future<void> _confirmScrapCreation(
      WorkspaceState state, String memo) async {
    debugPrint('[WorkspaceScreen._confirmScrapCreation] memo: ${memo.substring(0, memo.length.clamp(0, 50))}, pendingPage: ${state.pendingScrapPageNumber}, pendingText: ${state.pendingScrapText?.substring(0, (state.pendingScrapText?.length ?? 0).clamp(0, 50))}');
    final pageNumber = state.pendingScrapPageNumber;
    if (pageNumber == null) {
      debugPrint('[WorkspaceScreen._confirmScrapCreation] pageNumber is null, returning');
      return;
    }

    final text = memo.isNotEmpty ? memo : state.pendingScrapText;
    debugPrint('[WorkspaceScreen._confirmScrapCreation] creating marker on page $pageNumber with text: ${text != null ? text.substring(0, text.length.clamp(0, 50)) : null}');
    await ref.read(workspaceProviderProvider.notifier).createMarker(
          pageNumber: pageNumber,
          color: MarkerColor.green,
          selectedText: text,
          textRect: state.pendingScrapTextRect,
          capturedImagePath: state.pendingScrapImagePath,
        );
  }

  // ─── Scrap confirm popup overlay ─────────────────────────

  Widget _buildConfirmScrapPopup() {
    final proposal = ref.watch(activeScrapProposalProvider);
    if (proposal == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      right: 24,
      child: ConfirmScrapPopup(
        proposal: proposal,
        onAccept: () {
          ref.read(scrapInsertionServiceProvider).accept();
          ref.read(activeScrapProposalProvider.notifier).clear();
        },
        onReject: () {
          ref.read(scrapInsertionServiceProvider).reject();
          ref.read(activeScrapProposalProvider.notifier).clear();
        },
      ),
    );
  }

  // ─── Menu action handler ───────────────────────────────

  Future<void> _handleOpenPdf() async {
    debugPrint('[WorkspaceScreen._handleOpenPdf] opening file picker');
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'Select PDF File',
      );
      if (result != null && result.files.single.path != null) {
        final pdfPath = result.files.single.path!;
        debugPrint('[WorkspaceScreen._handleOpenPdf] selected: $pdfPath');
        await ref.read(workspaceProviderProvider.notifier).loadPdf(pdfPath);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('PDF Load Failed'),
            description: Text('$e'),
          ),
        );
      }
    }
  }

  void _handleMenuAction(String action) {
    debugPrint('[WorkspaceScreen._handleMenuAction] action: $action');
    final notifier = ref.read(workspaceProviderProvider.notifier);
    switch (action) {
      case 'swap':
        notifier.swapLayout();
        break;
      case 'editor':
        final s = ref.read(workspaceProviderProvider).valueOrNull;
        if (s?.isEditorModalOpen == true) {
          notifier.closeEditorModal();
        } else {
          notifier.openEditorModal();
        }
        break;
      case 'open_pdf':
        _handleOpenPdf();
        break;
      case 'scrapnote_manage':
        // TODO: ScrapNote management screen
        break;
      case 'settings':
        // TODO: Settings
        break;
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

  // ─── Title helper ─────────────────────────────────────────

  String _getTitle(WorkspaceState state) {
    if (state.currentPdfPath != null) {
      return p.basenameWithoutExtension(state.currentPdfPath!);
    }
    return 'Workspace';
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
              Column(
                children: [
                  // Unified header
                  WorkspaceUnifiedHeader(
                    title: _getTitle(state),
                    noteId: state.currentNoteId,
                    pageNumber: _pdfController.isReady
                        ? _pdfController.pageNumber
                        : null,
                    onToggleScrapnote: () => notifier.toggleLiveScraps(),
                    onOpenPdf: _handleOpenPdf,
                    onMenuAction: _handleMenuAction,
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
                ],
              ),

              // Overlay: Sidebar drawers
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

              // Overlay: Note editor modal
              if (state.isEditorModalOpen)
                NoteEditorModal(
                  noteId: state.currentNoteId,
                  onClose: () => notifier.closeEditorModal(),
                  onMarkerClick: _handleMarkerClick,
                ),

              // Overlay: Scrap board popup (replaces MarkerEditModal)
              if (state.isScrapBoardOpen)
                ScrapBoardPopup(
                  pageNumber: state.pendingScrapPageNumber,
                  highlightedText: state.pendingScrapText,
                  capturedImagePath: state.pendingScrapImagePath,
                  onConfirm: (memo) async {
                    await _confirmScrapCreation(state, memo);
                    notifier.closeScrapBoard();
                  },
                  onCancel: () => notifier.closeScrapBoard(),
                ),

              // Overlay: Scrap confirm popup (legacy, kept for capture flow)
              _buildConfirmScrapPopup(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Desktop workspace ────────────────────────────────────

  Widget _buildDesktopWorkspace(BuildContext context, WorkspaceState state) {
    final notifier = ref.read(workspaceProviderProvider.notifier);
    final isFocusPdf = state.focusedPanel == FocusedPanel.pdf;

    // Flex ratios based on focused panel
    final pdfFlex = isFocusPdf ? 3 : 2;
    final scrapFlex = isFocusPdf ? 1 : 2;

    // Build PDF viewer (Listener instead of GestureDetector to not block scroll)
    final pdfViewer = Expanded(
      flex: pdfFlex,
      child: Listener(
        onPointerDown: (_) => notifier.setFocusedPanel(FocusedPanel.pdf),
        child: PdfViewerScreen(
          controller: _pdfController,
          onAddMarkerPressed: _handleAddMarkerPressed,
          noteId: state.currentNoteId,
          externalToolbar: true,
        ),
      ),
    );

    // Build ScrapNote canvas panel
    final scrapPanel = state.isLiveScrapsOpen
        ? Expanded(
            flex: scrapFlex,
            child: Listener(
              onPointerDown: (_) =>
                  notifier.setFocusedPanel(FocusedPanel.scrapnote),
              child: WorkspaceCanvasPanel(
                noteId: state.currentNoteId,
                pdfPath: state.currentPdfPath,
                pdfController: _pdfController,
                onNavigateToPage: (page) {
                  _pdfController.goToPage(pageNumber: page);
                },
              ),
            ),
          )
        : const SizedBox.shrink();

    // Determine order based on swap
    final isSwapped = state.isLayoutSwapped;
    final leftPanel = isSwapped ? scrapPanel : pdfViewer;
    final rightPanel = isSwapped ? pdfViewer : scrapPanel;

    return Focus(
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Base layer ──
            Column(
              children: [
                // Unified header (tools integrated)
                WorkspaceUnifiedHeader(
                  title: _getTitle(state),
                  noteId: state.currentNoteId,
                  pageNumber: _pdfController.isReady
                      ? _pdfController.pageNumber
                      : null,
                  onToggleScrapnote: () => notifier.toggleLiveScraps(),
                  onOpenPdf: _handleOpenPdf,
                  onMenuAction: _handleMenuAction,
                ),

                // PDF tab bar
                const PdfTabBar(),

                // Main content: Thumbnails + PDF + ScrapNote
                Expanded(
                  child: Row(
                    children: [
                      // Left: Scrap thumbnails sidebar
                      if (state.isPageNavOpen)
                        ScrapThumbnailsSidebar(
                          onPageTap: (page) {
                            _pdfController.goToPage(pageNumber: page);
                          },
                        ),

                      // Center + Right: PDF and ScrapNote (swappable)
                      leftPanel,
                      rightPanel,
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

            // ── Overlay: Scrap board popup (replaces MarkerEditModal) ──
            if (state.isScrapBoardOpen)
              ScrapBoardPopup(
                pageNumber: state.pendingScrapPageNumber,
                highlightedText: state.pendingScrapText,
                capturedImagePath: state.pendingScrapImagePath,
                onConfirm: (memo) async {
                  await _confirmScrapCreation(state, memo);
                  notifier.closeScrapBoard();
                },
                onCancel: () => notifier.closeScrapBoard(),
              ),

            // ── Overlay: Scrap confirm popup (legacy) ──
            _buildConfirmScrapPopup(),
          ],
        ),
      ),
    );
  }
}
