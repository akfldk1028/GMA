import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../file_manager/models/note_metadata_model.dart';

/// A tree node representing either a folder or a file in the directory structure
class _TreeNode {
  final String name;
  final bool isFolder;
  final NoteMetadata? note; // null for folders
  final Map<String, _TreeNode> children = {};

  _TreeNode({
    required this.name,
    required this.isFolder,
    this.note,
  });
}

/// A widget that displays notes in an expandable folder tree structure.
///
/// Features:
/// - Displays directory hierarchy with expandable folders
/// - Shows folder and file icons
/// - Highlights the currently selected note
/// - Calls [onNoteSelected] when a note is tapped
class FileTreeWidget extends StatefulWidget {
  const FileTreeWidget({
    required this.notes,
    required this.onNoteSelected,
    this.selectedNoteId,
    this.rootPath,
    super.key,
  });

  final List<NoteMetadata> notes;
  final void Function(NoteMetadata note) onNoteSelected;
  final String? selectedNoteId;
  final String? rootPath; // Optional root path to trim from display

  @override
  State<FileTreeWidget> createState() => _FileTreeWidgetState();
}

class _FileTreeWidgetState extends State<FileTreeWidget> {
  final Set<String> _expandedFolders = {};

  @override
  Widget build(BuildContext context) {
    // Build the tree structure from notes
    final root = _buildTree();

    if (root.children.isEmpty) {
      return Center(
        child: Text(
          'No notes found',
          style: ShadTheme.of(context).textTheme.muted,
        ),
      );
    }

    return ListView(
      children: root.children.values.map((node) {
        return _buildTreeNode(context, node, '');
      }).toList(),
    );
  }

  /// Builds a tree structure from the flat list of notes
  _TreeNode _buildTree() {
    final root = _TreeNode(name: 'root', isFolder: true);

    for (final note in widget.notes) {
      // Get relative path from root if provided
      String relativePath = note.filePath;
      if (widget.rootPath != null) {
        relativePath = path.relative(note.filePath, from: widget.rootPath);
      }

      // Split path into segments
      final segments = path.split(relativePath);

      // Navigate/create folders in the tree
      _TreeNode current = root;
      for (int i = 0; i < segments.length - 1; i++) {
        final segment = segments[i];
        if (!current.children.containsKey(segment)) {
          current.children[segment] = _TreeNode(
            name: segment,
            isFolder: true,
          );
        }
        current = current.children[segment]!;
      }

      // Add the file (note) to the last folder
      final filename = segments.last;
      current.children[filename] = _TreeNode(
        name: filename,
        isFolder: false,
        note: note,
      );
    }

    return root;
  }

  /// Recursively builds the tree UI for a node
  Widget _buildTreeNode(
    BuildContext context,
    _TreeNode node,
    String parentPath,
  ) {
    final theme = ShadTheme.of(context);
    final currentPath = parentPath.isEmpty ? node.name : '$parentPath/${node.name}';

    if (node.isFolder) {
      final isExpanded = _expandedFolders.contains(currentPath);

      return ExpansionTile(
        key: PageStorageKey(currentPath),
        initiallyExpanded: isExpanded,
        leading: Icon(
          isExpanded ? Icons.folder_open : Icons.folder,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        title: Text(
          node.name,
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedFolders.add(currentPath);
            } else {
              _expandedFolders.remove(currentPath);
            }
          });
        },
        children: node.children.values.map((child) {
          return _buildTreeNode(context, child, currentPath);
        }).toList(),
      );
    } else {
      // This is a file (note)
      final note = node.note!;
      final isSelected = widget.selectedNoteId == note.id;

      return ListTile(
        dense: true,
        leading: Icon(
          Icons.insert_drive_file,
          color: theme.colorScheme.mutedForeground,
          size: 18,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                note.title,
                style: theme.textTheme.small.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (note.hasLinkedPdf) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.picture_as_pdf,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.accent.withValues(alpha: 0.1),
        onTap: () => widget.onNoteSelected(note),
      );
    }
  }
}
