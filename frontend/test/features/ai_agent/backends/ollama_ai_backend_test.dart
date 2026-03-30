import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/backends/ollama_ai_backend.dart';

void main() {
  group('OllamaAiBackend', () {
    late OllamaAiBackend backend;

    setUp(() {
      backend = OllamaAiBackend();
    });

    test('has correct id and label', () {
      expect(backend.id, 'ollama');
      expect(backend.label, 'Ollama');
    });

    test('isAvailable returns false when no server running', () async {
      // Use a port that's definitely not running Ollama
      final available = await backend.isAvailable(
        baseUrl: 'http://localhost:59999',
      );
      expect(available, isFalse);
    });

    test('generate throws on unreachable server', () async {
      expect(
        () => backend.generate(
          [{'role': 'user', 'content': 'test'}],
          baseUrl: 'http://localhost:59999',
        ),
        throwsException,
      );
    });
  });

  group('kDefaultAgentModel', () {
    test('is qwen2.5:3b', () {
      expect(kDefaultAgentModel, 'qwen2.5:3b');
    });
  });
}
