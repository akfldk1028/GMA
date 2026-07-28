import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../common_widgets/app_shell.dart';
import '../main.dart' show talker;
import '../features/dashboard/pages/screens/dashboard_screen.dart';
import '../features/home/pages/screens/home_screen.dart';
import '../features/note_editor/pages/screens/note_editor_screen.dart';
import '../features/knowledge_graph/pages/screens/knowledge_graph_screen.dart';
import '../features/scraps_library/pages/screens/scraps_library_screen.dart';
import '../features/settings/pages/screens/settings_screen.dart';
import '../features/splash/pages/screens/splash_screen.dart';
import '../features/workspace/pages/screens/workspace_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    observers: [TalkerRouteObserver(talker)],
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Shell route: sidebar-based pages
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/scraps',
            name: 'scraps',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ScrapsLibraryScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/knowledge-graph',
            name: 'knowledge-graph',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const KnowledgeGraphScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
      // Redirect old file-browser to home
      GoRoute(
        path: '/file-browser',
        redirect: (context, state) => '/home',
      ),
      // Workspace: no sidebar
      GoRoute(
        path: '/workspace',
        name: 'workspace',
        builder: (context, state) => const WorkspaceScreen(),
      ),
      GoRoute(
        path: '/note/:id',
        name: 'note',
        builder: (context, state) => NoteEditorScreen(
          noteId: state.pathParameters['id'],
        ),
      ),
      // Debug log viewer (Talker)
      GoRoute(
        path: '/logs',
        name: 'logs',
        builder: (context, state) => TalkerScreen(talker: talker),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}
