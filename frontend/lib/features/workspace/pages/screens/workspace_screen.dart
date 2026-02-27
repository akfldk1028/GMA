import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../pdf_viewer/drawing/pages/widgets/drawing_toolbar.dart';
import '../../../pdf_viewer/pages/screens/pdf_viewer_screen.dart';
import '../../../pdf_viewer/pages/widgets/marker_pills_strip.dart';
import '../../models/pdf_marker_model.dart';
import '../../models/workspace_state.dart';
import '../providers/workspace_provider.dart';
import '../widgets/file_browser_drawer.dart';
import '../widgets/marker_edit_modal.dart';
import '../widgets/note_editor_modal.dart';
import '../widgets/workspace_header_v2.dart';

/// Main workspace screen: PDF fullscreen + marker pills + overlay modals.
///
/// Base Layout (Column → Row):
/// ┌──────────────────────────────────────────┐
/// │ WorkspaceHeaderV2 (48px)                 │
/// ├──────────────────────────────────────────┤
/// │ DrawingToolbar (when note loaded)        │
/// ├────┬─────────────────────────────────────┤
/// │ M  │                                     │
/// │ A  │  PDF Viewer (2-page facing layout)  │
/// │ R  │                                     │
/// │ K  │                                     │
/// │ E  │                                     │
/// │ R  │                                     │
/// │ S  │                                     │
/// │~72 │                                     │
/// └────┴─────────────────────────────────────┘
///
/// Overlay Stack (conditional, on top of base):
/// + FileBrowserDrawer  — left slide-in, 300px
/// + NoteEditorModal    — center modal, 85%×90%
/// + MarkerEditModal    — center dialog, 420px wide
class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  // PDF viewer controller for programmatic navigation (Note → PDF flow)
  late final PdfViewerController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    // PdfViewerController doesn't have a dispose() method - managed by pdfrx
    super.dispose();
  }

  // ─── Text selection → modal flow ─────────────────────────

  /// New modal flow: text selection → open marker edit modal.
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

  /// Marker pill tap → jump PDF to that page/rect.
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

  /// Marker pill long-press → open editor modal.
  void _handleMarkerPillLongPress(PdfMarker marker) {
    ref.read(workspaceProviderProvider.notifier).openEditorModal();
  }

  // ─── Marker click in note editor → PDF jump ──────────────

  /// Handle marker click in note editor and navigate PDF viewer.
  /// Supports 'page:N-S' format (page N, sub-number S) from preview.
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
      // Handle 'page:N-S' format from markdown preview marker clicks
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

          if (subNumber <= pageMarkers.length) {
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

      // Try element navigation first (ScrapNote element ID)
      final elementPage = await ref
          .read(workspaceProviderProvider.notifier)
          .navigateToElement(markerId);
      if (elementPage != null) {
        if (!mounted) return;
        _pdfController.goToPage(pageNumber: elementPage);
        return;
      }

      // Handle UUID-based marker ID
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

      // Check mounted before updating PDF controller after async operation
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

    // Esc → close any open modal/drawer
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

    // Ctrl+E → toggle editor modal
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

    // Ctrl+B → toggle file browser
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
    final notifier = ref.read(workspaceProviderProvider.notifier);

    return Focus(
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Base layer: Header + Toolbar + MarkerStrip + PDF ──
            Column(
              children: [
                // Header
                WorkspaceHeaderV2(
                  onToggleFileBrowser: () => notifier.toggleFileBrowser(),
                  onToggleEditor: () {
                    if (state.isEditorModalOpen) {
                      notifier.closeEditorModal();
                    } else {
                      notifier.openEditorModal();
                    }
                  },
                ),

                // Drawing toolbar row (always rendered, collapsed when inactive)
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
                          horizontal: 8, vertical: 4),
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

                // Main content: Marker pills strip + PDF viewer
                Expanded(
                  child: Row(
                    children: [
                      // Marker pills strip (left edge)
                      MarkerPillsStrip(
                        onMarkerTap: _handleMarkerPillTap,
                        onMarkerLongPress: _handleMarkerPillLongPress,
                      ),

                      // PDF viewer (fills remaining space)
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
                ),
              ],
            ),

            // ── Overlay: File browser drawer ──
            if (state.isFileBrowserOpen)
              FileBrowserDrawer(
                onClose: () => notifier.closeFileBrowser(),
                onNoteSelected: (note) {
                  notifier.loadNote(note.id);
                  if (note.hasLinkedPdf) {
                    notifier.loadPdf(note.linkedPdfPath!);
                  }
                },
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
