import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/marker_colors.dart';
import '../../../file_manager/pages/screens/file_browser_screen.dart';
import '../../../note_editor/pages/screens/note_editor_screen.dart';
import '../../../pdf_viewer/pages/screens/pdf_viewer_screen.dart';
import '../../models/workspace_state.dart';
import '../providers/workspace_provider.dart';
import '../widgets/resizable_panel_divider.dart';

/// Main 3-panel workspace: Sidebar + PDF Viewer + Markdown Editor.
/// This is the core screen of GMA where PDF and notes are linked.
class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  // Track current panel sizes locally for immediate UI updates
  late double _leftRatio;
  late double _centerRatio;
  late double _rightRatio;

  // PDF viewer controller for programmatic navigation (Note → PDF flow)
  late final PdfViewerController _pdfController;

  @override
  void initState() {
    super.initState();
    // Initialize with default values - will be updated in build
    _leftRatio = 0.2;
    _centerRatio = 0.4;
    _rightRatio = 0.4;

    // Initialize PDF controller
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    // PdfViewerController doesn't require disposal
    super.dispose();
  }

  void _handleLeftDividerDrag(double delta, double totalWidth) {
    setState(() {
      final deltaRatio = delta / totalWidth;
      final newLeft = (_leftRatio + deltaRatio).clamp(0.1, 0.5);
      final newCenter = (_centerRatio - deltaRatio).clamp(0.2, 0.6);

      // Ensure ratios sum to 1.0
      final sum = newLeft + newCenter + _rightRatio;
      _leftRatio = newLeft / sum;
      _centerRatio = newCenter / sum;
      _rightRatio = _rightRatio / sum;
    });

    // Save to provider (persisted via Hive)
    ref.read(workspaceProviderProvider.notifier).savePanelSizes(
          PanelSizes(
            left: _leftRatio,
            center: _centerRatio,
            right: _rightRatio,
          ),
        );
  }

  void _handleRightDividerDrag(double delta, double totalWidth) {
    setState(() {
      final deltaRatio = delta / totalWidth;
      final newCenter = (_centerRatio + deltaRatio).clamp(0.2, 0.6);
      final newRight = (_rightRatio - deltaRatio).clamp(0.2, 0.6);

      // Ensure ratios sum to 1.0
      final sum = _leftRatio + newCenter + newRight;
      _leftRatio = _leftRatio / sum;
      _centerRatio = newCenter / sum;
      _rightRatio = newRight / sum;
    });

    // Save to provider (persisted via Hive)
    ref.read(workspaceProviderProvider.notifier).savePanelSizes(
          PanelSizes(
            left: _leftRatio,
            center: _centerRatio,
            right: _rightRatio,
          ),
        );
  }

  /// Handle PDF text selection and create a marker in the note editor.
  /// This is the core bidirectional linking flow: PDF → Note.
  void _handleTextSelection({
    required int pageNumber,
    required MarkerColor color,
    String? selectedText,
    PdfRect? textRect,
  }) {
    try {
      // Call workspace provider to create marker
      // This will add the marker to the workspace state and eventually
      // insert a marker line in the note editor (e.g., "- 🔴 P3 Selected text...")
      ref.read(workspaceProviderProvider.notifier).createMarker(
            pageNumber: pageNumber,
            color: color,
            selectedText: selectedText,
            textRect: textRect,
          );
    } catch (e) {
      // Show error notification if marker creation fails
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Marker Creation Failed'),
            description: Text('Failed to create marker: ${e.toString()}'),
          ),
        );
      }
    }
  }

  /// Handle marker click in note editor and navigate PDF viewer.
  /// This is the core bidirectional linking flow: Note → PDF.
  Future<void> _handleMarkerClick(String markerId) async {
    // Check if PDF is loaded before attempting navigation
    final workspaceState = ref.read(workspaceProviderProvider).valueOrNull;
    if (workspaceState?.currentPdfPath == null) {
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('No PDF Loaded'),
            description: Text('Please open a PDF file to navigate to markers.'),
          ),
        );
      }
      return;
    }

    try {
      // Get marker details from workspace provider
      final marker = await ref
          .read(workspaceProviderProvider.notifier)
          .navigateToMarker(markerId);

      if (marker == null) {
        // Marker not found - show error toast
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

      // Navigate PDF to marker's page
      // If textRect is available, navigate to exact coordinates
      if (marker.textRect != null) {
        // Navigate to specific rectangle on page
        _pdfController.goToRectInsidePage(
          pageNumber: marker.pageNumber,
          rect: marker.textRect!,
        );
      } else {
        // Navigate to page only
        _pdfController.goToPage(pageNumber: marker.pageNumber);
      }
    } catch (e) {
      // Show error notification for any navigation failures
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Navigation Error'),
            description: Text('Failed to navigate to marker: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(workspaceProviderProvider);

    return workspaceState.when(
      data: (state) {
        // Update local ratios from provider state
        _leftRatio = state.panelSizes.left;
        _centerRatio = state.panelSizes.center;
        _rightRatio = state.panelSizes.right;

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;

              return Row(
                children: [
                  // Left Panel: File Manager
                  Expanded(
                    flex: (_leftRatio * 100).round(),
                    child: const FileBrowserScreen(),
                  ),

                  // Left Divider
                  ResizablePanelDivider(
                    onDrag: (delta) => _handleLeftDividerDrag(delta, totalWidth),
                  ),

                  // Center Panel: PDF Viewer
                  Expanded(
                    flex: (_centerRatio * 100).round(),
                    child: PdfViewerScreen(
                      // Pass controller for Note → PDF navigation
                      controller: _pdfController,
                      // Wire up PDF text selection to marker creation flow
                      onTextSelectionChange: _handleTextSelection,
                    ),
                  ),

                  // Right Divider
                  ResizablePanelDivider(
                    onDrag: (delta) => _handleRightDividerDrag(delta, totalWidth),
                  ),

                  // Right Panel: Note Editor
                  Expanded(
                    flex: (_rightRatio * 100).round(),
                    child: NoteEditorScreen(
                      // Wire up marker click to PDF navigation flow
                      onMarkerClick: _handleMarkerClick,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
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
}
