import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub provider for element store
/// TODO: Replace with actual implementation when element storage is implemented
final elementStoreProvider = Provider<ElementStore>((ref) {
  return ElementStore();
});

/// Stub class for element store
/// TODO: Replace with actual implementation when element storage is implemented
class ElementStore {
  /// Get element by ID
  /// Returns null as this is a stub implementation
  dynamic getElementById(String id) {
    return null;
  }
}

/// Parse @el element reference from a line
/// Returns the element ID if the line starts with @el, otherwise returns null
///
/// Example:
/// - "@el element-123" returns "element-123"
/// - "Regular text" returns null
String? parseElementRef(String line) {
  final trimmed = line.trim();
  if (trimmed.startsWith('@el ')) {
    return trimmed.substring(4).trim();
  }
  return null;
}
