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
        return '모든 노트';
      case HomeTab.trash:
        return '휴지통';
      case HomeTab.folders:
        if (homeState.currentFolderId != null) {
          ref.watch(folderStoreProvider);
          final folder = ref
              .read(folderStoreProvider.notifier)
              .getById(homeState.currentFolderId!);
          return folder?.name ?? '폴더';
        }
        return '폴더';
    }
  }

  Future<void> _handleNewNote() async {
    final controller = TextEditingController(
      text: DateFormat('yyyyMMdd_HHmm').format(DateTime.now()),
    );
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Note', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Note name',
            isDense: true,
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;

    try {
      ref.invalidate(createNoteMutationProvider);
      final mutation = ref.read(createNoteMutationProvider.notifier);
      final note = await mutation.call(title: title);
      if (mounted) {
        // Use loadNote instead of resetForNewNote — loadNote's generation
        // guard cancels any in-flight session restore, and it properly
        // clears the previous PDF (sets currentPdfPath=null when no
        // linkedPdfPath in frontmatter).
        await ref.read(workspaceProviderProvider.notifier).loadNote(note.id);
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
          final pdfTitle =
              linkChoice.noteName ??
              '${p.basenameWithoutExtension(pdfPath)}_note';
          final note = await mutation.call(
            title: pdfTitle,
            linkedPdfPath: pdfPath,
          );
          await ref.read(workspaceProviderProvider.notifier).loadNote(note.id);
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
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.sokBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.sokDivider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Tab title
          Expanded(child: _buildTitle(homeState, ref)),
          // Action icons
          if (!isTrash) ...[
            IconButton(
              onPressed: _handleNewNote,
              icon: const _NewNoteIcon(),
              tooltip: '새 노트',
              color: AppColors.sokPrimary,
              style: _iconButtonStyle,
            ),
            IconButton(
              onPressed: () {
                ref
                    .read(homeStateProvider.notifier)
                    .setViewMode(
                      homeState.viewMode == ViewMode.grid
                          ? ViewMode.list
                          : ViewMode.grid,
                    );
              },
              icon: Icon(
                homeState.viewMode == ViewMode.grid
                    ? Icons.grid_view_rounded
                    : Icons.view_list_rounded,
                size: 22,
              ),
              tooltip: homeState.viewMode == ViewMode.grid ? '격자 보기' : '목록 보기',
              color: AppColors.sokPrimary,
              style: _iconButtonStyle,
            ),
          ],
          IconButton(
            onPressed: () => setState(() => _isSearching = true),
            icon: const Icon(Icons.search, size: 22),
            tooltip: '검색',
            color: AppColors.sokPrimary,
            style: _iconButtonStyle,
          ),
          OverflowMenu(
            isTrash: isTrash,
            onOpenPdf: isTrash ? null : _handleOpenPdf,
            onCreateFolder: homeState.activeTab == HomeTab.folders
                ? () => showFolderCreateDialog(context, ref)
                : null,
          ),
        ],
      ),
    );
  }

  static final ButtonStyle _iconButtonStyle = IconButton.styleFrom(
    fixedSize: const Size(40, 40),
    minimumSize: const Size(40, 40),
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    hoverColor: AppColors.sokHover,
    highlightColor: AppColors.sokHover,
  );

  Widget _buildTitle(HomeStateData homeState, WidgetRef ref) {
    final title = _getTitle(homeState, ref);

    if (homeState.activeTab == HomeTab.trash) {
      final trashAsync = ref.watch(trashNotesProvider);
      final count = trashAsync.valueOrNull?.length ?? 0;
      return Text(
        '$title  $count개',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.sokPrimary,
        ),
      );
    }

    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.sokPrimary,
      ),
    );
  }
}

class _NewNoteIcon extends StatelessWidget {
  const _NewNoteIcon();

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? AppColors.sokPrimary;

    return Icon(LucideIcons.filePlusCorner, size: 22, color: color);
  }
}
