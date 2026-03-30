import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';

class PdfLinkChoice {
  final String? noteId;
  final bool createNew;
  final String? noteName;

  const PdfLinkChoice({this.noteId, this.createNew = false, this.noteName});
  const PdfLinkChoice.newNote([String? name]) : noteId = null, createNew = true, noteName = name;
  const PdfLinkChoice.none() : noteId = null, createNew = false, noteName = null;
  const PdfLinkChoice.existing(String id) : noteId = id, createNew = false, noteName = null;
}

Future<PdfLinkChoice?> showPdfLinkPopup(
    BuildContext context, WidgetRef ref) async {
  return showDialog<PdfLinkChoice>(
    context: context,
    builder: (context) => const _PdfLinkDialog(),
  );
}

class _PdfLinkDialog extends ConsumerStatefulWidget {
  const _PdfLinkDialog();

  @override
  ConsumerState<_PdfLinkDialog> createState() => _PdfLinkDialogState();
}

class _PdfLinkDialogState extends ConsumerState<_PdfLinkDialog> {
  bool _showNotePicker = false;
  bool _showNameInput = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showNameInput) {
      return _buildNameInput();
    }
    if (_showNotePicker) {
      return _buildNotePicker();
    }

    return AlertDialog(
      title: const Text('Link PDF to Note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How would you like to open this PDF?'),
          const SizedBox(height: 16),
          _OptionTile(
            icon: Icons.add_circle_outline,
            label: 'Create New Note',
            subtitle: 'Start a new note linked to this PDF',
            onTap: () => setState(() => _showNameInput = true),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.link,
            label: 'Link to Existing Note',
            subtitle: 'Choose from your notes',
            onTap: () => setState(() => _showNotePicker = true),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.visibility,
            label: 'Just View PDF',
            subtitle: 'Open without linking',
            onTap: () =>
                Navigator.pop(context, const PdfLinkChoice.none()),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return AlertDialog(
      title: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _showNameInput = false),
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
          const Text('Note Name'),
        ],
      ),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter note name',
          isDense: true,
        ),
        onSubmitted: (_) => _confirmCreate(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _confirmCreate,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _confirmCreate() {
    final name = _nameController.text.trim();
    Navigator.pop(context, PdfLinkChoice.newNote(name.isEmpty ? null : name));
  }

  Widget _buildNotePicker() {
    final notesAsync = ref.watch(fileManagerProvider);

    return AlertDialog(
      title: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _showNotePicker = false),
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
          const Text('Select Note'),
        ],
      ),
      content: SizedBox(
        width: 300,
        height: 400,
        child: notesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (notes) {
            final activeNotes =
                notes.where((n) => !n.isDeleted).toList();
            if (activeNotes.isEmpty) {
              return const Center(child: Text('No notes available'));
            }
            return ListView.builder(
              itemCount: activeNotes.length,
              itemBuilder: (context, index) {
                final note = activeNotes[index];
                return ListTile(
                  leading: Icon(
                    note.hasLinkedPdf
                        ? Icons.picture_as_pdf_outlined
                        : Icons.description_outlined,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(note.title,
                      style: const TextStyle(fontSize: 14)),
                  onTap: () => Navigator.pop(
                      context, PdfLinkChoice.existing(note.id)),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDim,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
