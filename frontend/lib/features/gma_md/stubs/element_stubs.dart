import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub for element store provider
/// TODO: Replace with actual implementation when element system is developed
final elementStoreProvider = Provider<ElementStore>((ref) {
  return ElementStore();
});

/// Stub for element store
/// TODO: Replace with actual implementation when element system is developed
class ElementStore {
  // Using the _ScrapElement type from element_card.dart
  // Since it's private, we return null for now until the actual element system is implemented
  dynamic getElementById(String id) {
    return null;
  }
}

/// Parse element reference from @el line
/// Returns element ID if line matches @el pattern, null otherwise
/// TODO: Replace with actual implementation when element system is developed
String? parseElementRef(String line) {
  final trimmed = line.trim();
  if (trimmed.startsWith('@el ')) {
    return trimmed.substring(4).trim();
  }
  return null;
}
