import 'agent_skill.dart';
import 'draw_compare_skill.dart';
import 'draw_flow_skill.dart';
import 'draw_graph_skill.dart';
import 'draw_mindmap_skill.dart';
import 'draw_timeline_skill.dart';
import 'explain_page_skill.dart';
import 'summarize_skill.dart';

// ┌──────────────────────────────────────────────────────┐
// │  SKILL REGISTRY                                      │
// │  To add a new skill: create 1 file, add 1 line here. │
// └──────────────────────────────────────────────────────┘
final List<AgentSkill> skillRegistry = List.unmodifiable([
  // Visual (diagram) skills
  drawFlowSkill,
  drawMindmapSkill,
  drawGraphSkill,
  drawCompareSkill,
  drawTimelineSkill,
  // Reading skills
  explainPageSkill,
  summarizeSkill,
]);

/// Match user input to the best skill based on trigger keywords.
///
/// Returns null if no skill matches.
AgentSkill? matchSkill(String userInput) {
  final lower = userInput.toLowerCase();
  AgentSkill? best;
  int bestScore = 0;

  for (final skill in skillRegistry) {
    int score = 0;
    for (final trigger in skill.triggers) {
      if (lower.contains(trigger.toLowerCase())) {
        score++;
      }
    }
    if (score > bestScore) {
      bestScore = score;
      best = skill;
    }
  }

  return best;
}

/// Look up a skill by its ID.
AgentSkill? getSkillById(String id) {
  return skillRegistry.where((s) => s.id == id).firstOrNull;
}
