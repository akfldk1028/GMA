import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../ai_assistant/pages/widgets/ai_chat_panel.dart';

class DashboardRightPanel extends StatefulWidget {
  const DashboardRightPanel({super.key, this.isSheet = false});

  final bool isSheet;

  @override
  State<DashboardRightPanel> createState() => _DashboardRightPanelState();
}

class _DashboardRightPanelState extends State<DashboardRightPanel> {
  bool _showAiChat = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isSheet ? null : 300,
      decoration: widget.isSheet
          ? null
          : BoxDecoration(
              color: AppColors.surface,
              border: const Border(
                left: BorderSide(color: AppColors.border, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
      child: Column(
        mainAxisSize: widget.isSheet ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Drag handle for sheet mode
          if (widget.isSheet)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          if (_showAiChat)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AiChatPanel(
                  onClose: () => setState(() => _showAiChat = false),
                ),
              ),
            )
          else ...[
            // ── AI Assistant gradient button ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _showAiChat = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.warmGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: AppColors.gradientPink.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Research AI Assistant',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Divider(color: AppColors.border, height: 1),

            // ── Upcoming Deadlines ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Deadlines',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DeadlineItem(
                    title: 'ML Paper Review',
                    date: 'Mar 15',
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 10),
                  _DeadlineItem(
                    title: 'Research Presentation',
                    date: 'Mar 22',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 1),

            // ── Recent Activity ──
            if (!widget.isSheet)
              Expanded(
                child: _buildRecentActivity(),
              )
            else
              _buildRecentActivity(),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          _ActivityItem(
            icon: Icons.edit_note_rounded,
            text: 'Edited "Research Notes"',
            time: '2h ago',
          ),
          const SizedBox(height: 12),
          _ActivityItem(
            icon: Icons.add_circle_outline_rounded,
            text: 'Created new scrap',
            time: '5h ago',
          ),
          const SizedBox(height: 12),
          _ActivityItem(
            icon: Icons.picture_as_pdf_rounded,
            text: 'Opened "paper.pdf"',
            time: 'Yesterday',
          ),
        ],
      ),
    );
  }
}

class _DeadlineItem extends StatelessWidget {
  const _DeadlineItem({
    required this.title,
    required this.date,
    required this.color,
  });

  final String title;
  final String date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.text,
    required this.time,
  });

  final IconData icon;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.surfaceDim,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: AppColors.textMuted),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
