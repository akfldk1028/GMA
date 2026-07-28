import 'ai_capability.dart';
import 'ai_generate_options.dart';
import 'ai_message.dart';

/// Abstract interface for AI backends (plugin pattern).
///
/// Each backend declares its capabilities and priority.
/// BackendSelector picks the best available backend for a given skill.
abstract class AiBackend {
  /// Unique identifier, e.g. 'ollama', 'gemma', 'openrouter'.
  String get id;

  /// Human-readable label.
  String get label;

  /// What this backend can do.
  Set<AiCapability> get capabilities;

  /// Selection priority — lower wins (0=on-device, 10=cloud, 20=local-server).
  int get priority;

  /// Check if this backend is ready to generate.
  Future<bool> isAvailable();

  /// Generate a response for the given messages.
  Future<String> generate(
    List<AiMessage> messages, {
    AiGenerateOptions? options,
  });
}
