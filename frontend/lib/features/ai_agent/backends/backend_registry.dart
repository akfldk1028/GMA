import '../core/ai_backend.dart';

/// Registry for AI backends.
///
/// Backends are registered by the provider at startup via [registerBackend].
/// Pattern inspired by nanoclaw channels/registry.ts.
final Map<String, AiBackend> _registry = {};

/// Register a backend. Replaces existing backend with same ID.
void registerBackend(AiBackend backend) {
  _registry[backend.id] = backend;
}

/// All registered backends, sorted by priority (lowest first).
List<AiBackend> get registeredBackends {
  final list = _registry.values.toList();
  list.sort((a, b) => a.priority.compareTo(b.priority));
  return list;
}

/// Look up a backend by ID.
AiBackend? getBackendById(String id) => _registry[id];

/// Remove a backend from the registry.
void unregisterBackend(String id) => _registry.remove(id);

/// Clear all backends (for testing).
void clearBackendRegistry() => _registry.clear();
