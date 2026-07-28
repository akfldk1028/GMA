import '../core/ai_capability.dart';

/// Definition of an AI agent skill.
///
/// Each skill knows:
/// - When to activate (trigger keywords)
/// - What system prompt to use
/// - What GMA MD block to output
/// - How to validate the output
/// - What capabilities it requires from the backend
///
/// Pattern: nanoclaw container/skills/ — one folder per skill, self-registration.
class AgentSkill {
  const AgentSkill({
    required this.id,
    required this.label,
    required this.description,
    required this.triggers,
    required this.systemPrompt,
    this.outputBlockType,
    this.validator,
    this.requiredCapabilities = const {AiCapability.text},
    this.enabled = true,
  });

  /// Unique skill ID, e.g. 'draw-flow'.
  final String id;

  /// Display label, e.g. '플로우차트'.
  final String label;

  /// Short description for skill picker UI.
  final String description;

  /// Keywords that trigger this skill.
  /// Intent parser matches user input against these.
  final List<String> triggers;

  /// System prompt injected before user message.
  /// Contains block syntax rules and output format instructions.
  final String systemPrompt;

  /// Expected output block type (e.g. 'flow', 'mindmap').
  /// Used for validation. Null means free-form text output.
  final String? outputBlockType;

  /// Optional validator function.
  /// Returns true if the LLM output is valid for this skill.
  final bool Function(String output)? validator;

  /// Backend capabilities this skill needs (default: text only).
  /// BackendSelector uses this to find a matching backend.
  final Set<AiCapability> requiredCapabilities;

  /// Whether this skill is enabled by the user.
  final bool enabled;
}
