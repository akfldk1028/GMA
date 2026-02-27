import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../workspace/pages/providers/workspace_provider.dart';

part 'scrapnote_provider.g.dart';

/// ScrapNote provider managing element navigation and sidebar mode.
/// Delegates to WorkspaceProvider for actual state changes.
@Riverpod(keepAlive: true)
class ScrapnoteProvider extends _$ScrapnoteProvider {
  @override
  void build() {
    // Stateless helper — no state to initialize
  }

  /// Navigate to an element by looking it up in ElementStore,
  /// loading the associated PDF if needed, and returning the page number.
  Future<int?> navigateToElement(String elementId) async {
    try {
      return await ref
          .read(workspaceProviderProvider.notifier)
          .navigateToElement(elementId);
    } catch (e) {
      debugPrint('Failed to navigate to element $elementId: $e');
      return null;
    }
  }

  /// Toggle sidebar mode between fileBrowser and elementNavigator.
  void toggleSidebarMode() {
    ref.read(workspaceProviderProvider.notifier).toggleSidebarMode();
  }
}
