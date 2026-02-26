import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// TODO: Import dependencies when available (subtask-1-3 and previous specs)
// import '../../workspace/models/workspace_state.dart';
// import '../../workspace/pages/providers/workspace_provider.dart';
// import 'element_store.dart';
// import '../models/pdf_registry.dart';

part 'scrapnote_provider.g.dart';

/// ScrapNote provider managing element navigation and sidebar mode
/// This is a stateless helper that delegates to workspace_provider
@riverpod
class ScrapnoteProvider extends _$ScrapnoteProvider {
  @override
  FutureOr<void> build() async {
    // Stateless helper - no state to initialize
    return;
  }

  /// Navigate to an element by looking it up in ElementStore,
  /// loading the associated PDF if needed, and returning the page number
  /// for the caller to navigate to.
  ///
  /// Returns the page number to navigate to, or null if element not found.
  Future<int?> navigateToElement(String elementId) async {
    try {
      // TODO: Once element_store and pdf_registry are implemented, use:
      // final elementStore = ref.read(elementStoreProvider);
      // final element = elementStore.getElementById(elementId);
      // if (element == null) return null;
      //
      // final pdfRegistry = ref.read(pdfRegistryProvider);
      // final pdfPath = pdfRegistry.getPathById(element.pdfId);
      // if (pdfPath == null) return null;
      //
      // final workspaceProvider = ref.read(workspaceProviderProvider.notifier);
      // final currentState = ref.read(workspaceProviderProvider).valueOrNull;
      //
      // // Load PDF if it's different from the current one
      // if (currentState?.currentPdfPath != pdfPath) {
      //   await workspaceProvider.loadPdf(pdfPath);
      // }
      //
      // return element.pageNumber;

      debugPrint('ScrapnoteProvider.navigateToElement($elementId) - stub implementation');
      return null;
    } catch (e) {
      debugPrint('Failed to navigate to element $elementId: $e');
      return null;
    }
  }

  /// Toggle sidebar mode between fileBrowser and elementNavigator
  /// This method will call workspace_provider.toggleSidebarMode() once
  /// that method is added in subtask-1-3
  Future<void> toggleSidebarMode() async {
    try {
      // TODO: Once workspace_provider.toggleSidebarMode() is added (subtask-1-3), use:
      // final workspaceProvider = ref.read(workspaceProviderProvider.notifier);
      // await workspaceProvider.toggleSidebarMode();

      debugPrint('ScrapnoteProvider.toggleSidebarMode() - stub implementation');
    } catch (e) {
      debugPrint('Failed to toggle sidebar mode: $e');
      rethrow;
    }
  }
}
