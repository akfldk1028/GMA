import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/backends/ollama_backend.dart';
import 'package:gma_frontend/features/ai_agent/core/ai_capability.dart';
import 'package:gma_frontend/features/ai_agent/core/ai_message.dart';

void main() {
  group('OllamaBackend', () {
    late OllamaBackend backend;

    setUp(() {
      backend = OllamaBackend(baseUrl: 'http://localhost:59999');
    });

    test('has correct id and label', () {
      expect(backend.id, 'ollama');
      expect(backend.label, 'Ollama');
    });

    test('has text capability only', () {
      expect(backend.capabilities, {AiCapability.text});
    });

    test('priority is 20 (local server)', () {
      expect(backend.priority, 20);
    });

    test('isAvailable returns false when no server running', () async {
      final available = await backend.isAvailable();
      expect(available, isFalse);
    });

    test('generate throws on unreachable server', () async {
      expect(
        () => backend.generate([
          AiMessage.text(AiRole.user, 'test'),
        ]),
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
