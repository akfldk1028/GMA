import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/pages/screens/dashboard_screen.dart';
import '../features/scrapnote/pages/screens/scrapnote_screen.dart';
import '../features/workspace/pages/screens/workspace_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/workspace',
        builder: (context, state) => const WorkspaceScreen(),
      ),
      GoRoute(
        path: '/scrapnote',
        builder: (context, state) {
          final pdfPath =
              state.uri.queryParameters['pdfPath'] ?? '';
          return ScrapnoteScreen(pdfPath: pdfPath);
        },
      ),
    ],
  );
});
