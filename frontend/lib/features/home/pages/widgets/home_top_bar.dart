import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../constants/app_colors.dart';
import '../../../file_manager/pages/providers/file_manager_provider.dart';
import '../../../workspace/pages/providers/workspace_provider.dart';
import '../../providers/home_note_list_provider.dart';
import '../../providers/home_state_provider.dart';
import '../../providers/folder_store.dart';
import 'folder_create_dialog.dart';
import 'overflow_menu.dart';
import 'pdf_link_popup.dart';
import 'search_overlay.dart';

class HomeTopBar extends ConsumerStatefulWidget {
  const HomeTopBar({super.key});

  @override
  ConsumerState<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends ConsumerState<HomeTopBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTitle(HomeStateData homeState, WidgetRef ref) {
    switch (homeState.activeTab) {
      case HomeTab.allNotes:
        return 'All Notes';
      case HomeTab.trash:
        return 'Trash';
      case HomeTab.folders:
        if (homeState.currentFolderId != null) {
          ref.watch(folderStoreProvider);
          final folder = ref
              .read(folderStoreProvider.notifier)
              .getById(homeState.currentFolderId!);
          return folder?.name ?? 'Folders';
        }
        return 'Folders';
    }
  }

  Future<void> _handleNewNote() async {
    try {
      final mutation = ref.read(createNoteMutationProvider.notifier);
      final title = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final note = await mutation.call(title: title);
      if (mounted) {
        ref
            .read(workspaceProviderProvider.notifier)
            .resetForNewNote(note.id);
        if (mounted) context.go('/workspace');
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Failed to create note'),
            description: Text('$e'),
          ),
        );
      }
    }
  }

  Future<void> _handleOpenPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'Select PDF File',
      );

      if (result != null && result.files.single.path != null) {
        final pdfPath = result.files.single.path!;
        if (!mounted) return;

        final linkChoice = await showPdfLinkPopup(context, ref);
        if (linkChoice == null) return;

        if (linkChoice.noteId != null) {
          // Link to existing note
          await ref
              .read(workspaceProviderProvider.notifier)
              .loadNote(linkChoice.noteId!);
        } else if (linkChoice.createNew) {
          // Create new note linked to this PDF
          final mutation = ref.read(createNoteMutationProvider.notifier);
          final pdfTitle = '${p.basenameWithoutExtension(pdfPath)}_note';
          final note = await mutation.call(
            title: pdfTitle,
            linkedPdfPath: pdfPath,
          );
          await ref
              .read(workspaceProviderProvider.notifier)
              .loadNote(note.id);
        }

        await ref.read(workspaceProviderProvider.notifier).loadPdf(pdfPath);
        if (mounted) context.go('/workspace');
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Failed to open PDF'),
            description: Text('$e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    final isTrash = homeState.activeTab == HomeTab.trash;

    if (_isSearching) {
      return SearchOverlay(
        controller: _searchController,
        onChanged: (q) =>
            ref.read(homeStateProvider.notifier).setSearchQuery(q),
        onClose: () {
          setState(() => _isSearching = false);
          _searchController.clear();
          ref.read(homeStateProvider.notifier).setSearchQuery('');
        },
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Tab title
          Expanded(
            child: _buildTitle(homeState, ref),
          ),
          // Action icons
          if (!isTrash) ...[
            IconButton(
              onPressed: _handleNewNote,
              icon: const Icon(Icons.edit_note_rounded, size: 22),
              tooltip: 'New Note',
              color: AppColors.textSecondary,
            ),
            if (homeState.activeTab == HomeTab.folders)
              IconButton(
                onPressed: () => showFolderCreateDialog(context, ref),
                icon: const Icon(Icons.create_new_folder_outlined, size: 22),
                tooltip: 'New Folder',
                color: AppColors.textSecondary,
              )
            else
              IconButton(
                onPressed: _handleOpenPdf,
                icon: const Icon(Icons.file_open_outlined, size: 22),
                tooltip: 'Open PDF',
                color: AppColors.textSecondary,
              ),
          ],
          IconButton(
            onPressed: () => setState(() => _isSearching = true),
            icon: const Icon(Icons.search, size: 22),
            tooltip: 'Search',
            color: AppColors.textSecondary,
          ),
          OverflowMenu(isTrash: isTrash),
        ],
      ),
    );
  }

  Widget _buildTitle(HomeStateData homeState, WidgetRef ref) {
    final title = _getTitle(homeState, ref);

    if (homeState.activeTab == HomeTab.trash) {
      final trashAsync = ref.watch(trashNotesProvider);
      final count = trashAsync.valueOrNull?.length ?? 0;
      return Text(
        '$title  $count files',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );
    }

    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
