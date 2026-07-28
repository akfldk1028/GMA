import 'package:flutter_test/flutter_test.dart';
import 'package:gma_frontend/features/ai_agent/skills/agent_skill.dart';

void main() {
  group('AgentSkill', () {
    test('can be constructed with all required fields', () {
      final skill = AgentSkill(
        id: 'test-skill',
        label: 'Test',
        description: 'A test skill',
        triggers: ['test', 'demo'],
        systemPrompt: 'You are a test agent.',
      );

      expect(skill.id, 'test-skill');
      expect(skill.label, 'Test');
      expect(skill.triggers, ['test', 'demo']);
      expect(skill.outputBlockType, isNull);
      expect(skill.validator, isNull);
    });

    test('optional fields work correctly', () {
      final skill = AgentSkill(
        id: 'test',
        label: 'Test',
        description: 'desc',
        triggers: ['t'],
        systemPrompt: 'prompt',
        outputBlockType: 'flow',
        validator: (output) => output.contains(':::'),
      );

      expect(skill.outputBlockType, 'flow');
      expect(skill.validator!('::: flow\n:::'), isTrue);
      expect(skill.validator!('no block'), isFalse);
    });
  });
}
