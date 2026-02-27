import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/file_manager/pages/screens/file_browser_screen.dart';
import '../features/note_editor/pages/screens/note_editor_screen.dart';
import '../features/settings/pages/screens/settings_screen.dart';
import '../features/workspace/pages/screens/workspace_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/workspace',
    routes: [
      GoRoute(
        path: '/workspace',
        name: 'workspace',
        builder: (context, state) => const WorkspaceScreen(),
      ),
      GoRoute(
        path: '/file-browser',
        name: 'file-browser',
        builder: (context, state) => const FileBrowserScreen(),
      ),
      GoRoute(
        path: '/note/:id',
        name: 'note',
        builder: (context, state) => NoteEditorScreen(
          noteId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
