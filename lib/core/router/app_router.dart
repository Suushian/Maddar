import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madaar/core/widgets/floating_glass_dock.dart';
import 'package:madaar/core/widgets/universal_quick_add.dart';
import 'package:madaar/features/finance/presentation/finance_page.dart';
import 'package:madaar/features/habits/presentation/habits_page.dart';
import 'package:madaar/features/journal/presentation/journal_page.dart';
import 'package:madaar/features/settings/presentation/settings_page.dart';
import 'package:madaar/features/tasks/presentation/tasks_page.dart';
import 'package:madaar/features/today/presentation/today_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/today',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell shell,
      ) {
        return _AppShell(shell: shell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/today',
              builder: (BuildContext context, GoRouterState state) =>
                  const TodayPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/tasks',
              builder: (BuildContext context, GoRouterState state) =>
                  const TasksPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/habits',
              builder: (BuildContext context, GoRouterState state) =>
                  const HabitsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/finance',
              builder: (BuildContext context, GoRouterState state) =>
                  const FinancePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/journal',
              builder: (BuildContext context, GoRouterState state) =>
                  const JournalPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) =>
          const SettingsPage(),
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  static const List<int> _quickAddTabs = <int>[0, 0, 3, 1, 2];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: FloatingGlassDock(
        currentIndex: shell.currentIndex,
        onDestinationSelected: (int index) => shell.goBranch(index),
        onQuickAdd: () => UniversalQuickAdd.show(
          context,
          initialTab: _quickAddTabs[shell.currentIndex],
        ),
      ),
    );
  }
}
