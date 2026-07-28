import '../backends/backend_registry.dart';
import '../core/ai_backend.dart';
import '../core/ai_capability.dart';

/// Exception when no backend can satisfy the required capabilities.
class AiBackendUnavailableException implements Exception {
  AiBackendUnavailableException(this.required);
  final Set<AiCapability> required;

  @override
  String toString() =>
      'No available backend for capabilities: $required';
}

/// Selects the best available backend for a set of required capabilities.
///
/// Priority order: on-device (0) > cloud (10) > local-server (20).
class BackendSelector {
  BackendSelector._();

  /// Find the best available backend that supports all [required] capabilities.
  static Future<AiBackend> select(Set<AiCapability> required) async {
    final candidates = registeredBackends
        .where((b) => required.every((c) => b.capabilities.contains(c)))
        .toList();

    for (final backend in candidates) {
      if (await backend.isAvailable()) return backend;
    }

    throw AiBackendUnavailableException(required);
  }
}
