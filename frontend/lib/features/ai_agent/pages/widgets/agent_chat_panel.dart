import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../../ai_assistant/models/chat_message_model.dart';
import '../../providers/ai_agent_provider.dart';
import '../../services/block_extractor.dart';
import '../../skills/skill_registry.dart';
import 'model_download_widget.dart';
import 'skill_picker.dart';

class AgentChatPanel extends ConsumerStatefulWidget {
  const AgentChatPanel({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  ConsumerState<AgentChatPanel> createState() => _AgentChatPanelState();
}

class _AgentChatPanelState extends ConsumerState<AgentChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedSkillId;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    if (_selectedSkillId != null) {
      ref
          .read(aiAgentProvider.notifier)
          .executeSkillById(_selectedSkillId!, text);
      setState(() => _selectedSkillId = null);
    } else {
      ref.read(aiAgentProvider.notifier).sendMessage(text);
    }
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _insertBlock(String messageId) {
    final ok = ref
        .read(aiAgentProvider.notifier)
        .insertBlockFromMessage(messageId);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('노트에 삽입했습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentState = ref.watch(aiAgentProvider);
    final messages = agentState.messages;
    final media = MediaQuery.sizeOf(context);
    final panelWidth = (media.width - 32).clamp(320.0, 400.0).toDouble();
    final panelHeight = (media.height - 160).clamp(280.0, 520.0).toDouble();

    return Container(
      width: panelWidth,
      height: panelHeight,
      decoration: BoxDecoration(
        color: AppColors.sokSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sokDivider),
        boxShadow: AppColors.sokFloatingShadow,
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_selectedSkillId != null) _buildSkillBadge(),
          Expanded(child: _buildMessages(messages)),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.sokDivider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: AppColors.sokAccent),
          const SizedBox(width: 8),
          const Text(
            'AI Agent',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.sokPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => ref.read(aiAgentProvider.notifier).clear(),
            icon: const Icon(Icons.delete_outline, size: 16),
            iconSize: 16,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Clear chat',
            color: AppColors.sokSecondary,
          ),
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close, size: 16),
              iconSize: 16,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'Close',
              color: AppColors.sokSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildSkillBadge() {
    final skill = getSkillById(_selectedSkillId!);
    if (skill == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: AppColors.sokHover,
      child: Row(
        children: [
          const Icon(Icons.build_circle, size: 14, color: AppColors.sokAccent),
          const SizedBox(width: 4),
          Text(
            '${skill.label} 스킬',
            style: const TextStyle(fontSize: 11, color: AppColors.sokAccent),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _selectedSkillId = null),
            child: const Icon(
              Icons.close,
              size: 12,
              color: AppColors.sokAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 30,
                color: AppColors.sokAccent,
              ),
              const SizedBox(height: 8),
              const Text(
                'PDF 내용을 분석하고\n다이어그램을 생성합니다',
                style: TextStyle(fontSize: 12, color: AppColors.sokSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const ModelDownloadWidget(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: skillRegistry.take(5).map((s) {
                  return ActionChip(
                    label: Text(s.label, style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      setState(() => _selectedSkillId = s.id);
                    },
                    side: const BorderSide(color: AppColors.sokDivider),
                    backgroundColor: AppColors.sokSurface,
                    labelStyle: const TextStyle(color: AppColors.sokPrimary),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return _ChatBubble(
          key: ValueKey(msg.id),
          message: msg,
          onInsertBlock:
              msg.role == ChatRole.assistant &&
                  BlockExtractor.hasBlock(msg.content)
              ? () => _insertBlock(msg.id)
              : null,
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.sokDivider)),
      ),
      child: Row(
        children: [
          // Skill picker button
          IconButton(
            onPressed: () {
              showSkillPicker(
                context: context,
                onSkillSelected: (skillId) {
                  setState(() => _selectedSkillId = skillId);
                },
              );
            },
            icon: const Icon(Icons.dashboard_customize, size: 18),
            tooltip: 'Skills',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: AppColors.sokSecondary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: _selectedSkillId != null
                    ? '내용을 입력하세요'
                    : '메시지 입력 (또는 스킬 선택)',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.sokDisabled,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.sokDivider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.sokDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.sokAccent),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: _send,
            icon: const Icon(Icons.send_rounded, size: 18),
            tooltip: 'Send',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.sokAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(36, 36),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({super.key, required this.message, this.onInsertBlock});

  final ChatMessage message;
  final VoidCallback? onInsertBlock;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                const Padding(
                  padding: EdgeInsets.only(right: 6, top: 2),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.sokHover,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.sokAccent,
                    ),
                  ),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.sokAccent : AppColors.sokHover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    message.content,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUser ? Colors.white : AppColors.sokPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Insert block button
          if (onInsertBlock != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 30),
              child: TextButton.icon(
                onPressed: onInsertBlock,
                icon: const Icon(Icons.add_to_photos, size: 14),
                label: const Text(
                  'Insert to note',
                  style: TextStyle(fontSize: 11),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.sokAccent,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
