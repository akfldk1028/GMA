/// Metadata for available Gemma models.
class GemmaModelInfo {
  const GemmaModelInfo({
    required this.id,
    required this.label,
    required this.downloadUrl,
    required this.sizeBytes,
    required this.effectiveParams,
  });

  final String id;
  final String label;
  final String downloadUrl;
  final int sizeBytes;
  final String effectiveParams;

  double get sizeGB => sizeBytes / (1024 * 1024 * 1024);
}

/// E4B model — the only model GMA uses (planner decision 2026-04-07).
const gemmaE4B = GemmaModelInfo(
  id: 'e4b',
  label: 'Gemma 4 E4B',
  downloadUrl:
      'https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-e4b-it.litertlm',
  sizeBytes: 4617089843, // ~4.3 GB
  effectiveParams: '4.5B',
);
