import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/file_manager_provider.dart';

class NoteCreateDialog extends ConsumerStatefulWidget {
  const NoteCreateDialog({super.key});

  @override
  ConsumerState<NoteCreateDialog> createState() => _NoteCreateDialogState();
}

class _NoteCreateDialogState extends ConsumerState<NoteCreateDialog> {
  final _formKey = GlobalKey<ShadFormState>();
  final _titleController = TextEditingController();
  final _pdfPathController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _pdfPathController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      dialogTitle: 'Select PDF File',
    );

    if (result != null && result.files.single.path != null) {
      _pdfPathController.text = result.files.single.path!;
    }
  }

  Future<void> _handleCreate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.invalidate(createNoteMutationProvider);
    final mutation = ref.read(createNoteMutationProvider.notifier);
    try {
      await mutation.call(
        title: _titleController.text.trim(),
        linkedPdfPath: _pdfPathController.text.trim().isEmpty
            ? null
            : _pdfPathController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Success'),
            description: Text('Note created successfully.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Create Failed'),
            description: Text('Failed to create note: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createNoteMutationProvider);
    final isLoading = createState.isLoading;

    return ShadDialog(
      title: const Text('Create New Note'),
      description: const Text('Enter details for the new note.'),
      child: ShadForm(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            ShadInputFormField(
              id: 'title',
              label: const Text('Note Title'),
              placeholder: const Text('My new note'),
              controller: _titleController,
              validator: (v) => v.isEmpty ? 'Title is required' : null,
              enabled: !isLoading,
            ),
            const SizedBox(height: 12),
            ShadInputFormField(
              id: 'pdfPath',
              label: const Text('Linked PDF (Optional)'),
              placeholder: const Text('Path to PDF file'),
              controller: _pdfPathController,
              enabled: !isLoading,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ShadButton.secondary(
                onPressed: isLoading ? null : _pickPdfFile,
                size: ShadButtonSize.sm,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open, size: 16),
                    SizedBox(width: 4),
                    Text('Browse PDF'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShadButton.outline(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ShadButton(
                  onPressed: isLoading ? null : _handleCreate,
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
