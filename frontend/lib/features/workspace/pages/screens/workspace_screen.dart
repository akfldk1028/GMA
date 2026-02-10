import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Main 3-panel workspace: Sidebar + PDF Viewer + Markdown Editor.
/// This is the core screen of GMA where PDF and notes are linked.
class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Text(
          'Workspace - 3 Panel Layout',
          style: ShadTheme.of(context).textTheme.h2,
        ),
      ),
    );
  }
}
