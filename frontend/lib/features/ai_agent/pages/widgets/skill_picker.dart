import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../skills/agent_skill.dart';
import '../../skills/skill_registry.dart';

/// Show the skill picker as a bottom-anchored popup.
void showSkillPicker({
  required BuildContext context,
  required void Function(String skillId) onSkillSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SkillPickerSheet(
      onSkillSelected: (id) {
        Navigator.pop(ctx);
        onSkillSelected(id);
      },
    ),
  );
}

class _SkillPickerSheet extends StatelessWidget {
  const _SkillPickerSheet({required this.onSkillSelected});

  final void Function(String skillId) onSkillSelected;

  @override
  Widget build(BuildContext context) {
    // Group: visual vs reading
    final visual = skillRegistry.where((s) => s.id.startsWith('draw-')).toList();
    final reading = skillRegistry.where((s) => !s.id.startsWith('draw-')).toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 360),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'AI Skills',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategory('Diagram', Icons.dashboard, visual),
                  const SizedBox(height: 12),
                  _buildCategory('Analysis', Icons.menu_book, reading),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
    String title,
    IconData icon,
    List<AgentSkill> skills,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map<Widget>((s) {
            return InkWell(
              onTap: () => onSkillSelected(s.id),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
