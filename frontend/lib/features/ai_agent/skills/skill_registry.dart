import 'agent_skill.dart';
import 'draw_flow/draw_flow_skill.dart';
import 'draw_mindmap/draw_mindmap_skill.dart';
import 'draw_graph/draw_graph_skill.dart';
import 'draw_compare/draw_compare_skill.dart';
import 'draw_timeline/draw_timeline_skill.dart';
import 'explain_page/explain_page_skill.dart';
import 'summarize/summarize_skill.dart';

// ┌──────────────────────────────────────────────────────┐
// │  SKILL REGISTRY                                      │
// │  To add a new skill: create folder + 1 line here.    │
// └──────────────────────────────────────────────────────┘
final List<AgentSkill> _skills = [
  drawFlowSkill,
  drawMindmapSkill,
  drawGraphSkill,
  drawCompareSkill,
  drawTimelineSkill,
  explainPageSkill,
  summarizeSkill,
];

/// All registered skills.
List<AgentSkill> get skillRegistry => List.unmodifiable(_skills);

/// Only enabled skills (for UI display).
List<AgentSkill> get activeSkills =>
    _skills.where((s) => s.enabled).toList();

/// Register a skill at runtime (for dynamic/plugin skills).
void registerSkill(AgentSkill skill) {
  if (_skills.any((s) => s.id == skill.id)) return;
  _skills.add(skill);
}

/// Match user input to the best skill based on trigger keywords.
AgentSkill? matchSkill(String userInput) {
  final lower = userInput.toLowerCase();
  AgentSkill? best;
  int bestScore = 0;

  for (final skill in activeSkills) {
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
  return _skills.where((s) => s.id == id).firstOrNull;
}
