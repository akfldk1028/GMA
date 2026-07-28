/// Backend-agnostic generation options.
class AiGenerateOptions {
  const AiGenerateOptions({
    this.maxTokens,
    this.temperature,
    this.topP,
  });

  final int? maxTokens;
  final double? temperature;
  final double? topP;
}
