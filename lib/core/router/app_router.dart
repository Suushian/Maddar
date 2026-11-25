import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madaar/core/widgets/floating_glass_dock.dart';
import 'package:madaar/core/utils/motion.dart';
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

class _AppShell extends StatefulWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  static const List<int> _quickAddTabs = <int>[0, 0, 3, 1, 2];

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.page,
  );
  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  int _index = -1;

  @override
  void initState() {
    super.initState();
    _index = widget.shell.currentIndex;
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant _AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shell.currentIndex != _index) {
      _index = widget.shell.currentIndex;
      if (!Motion.reduced(context)) {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (BuildContext context, Widget? child) {
        final double opacity = 0.65 + 0.35 * _curved.value;
        final double offsetY = (1 - _curved.value) * 10;
        return Scaffold(
          body: FadeTransition(
            opacity: AlwaysStoppedAnimation<double>(opacity),
            child: Transform.translate(
              offset: Offset(0, offsetY),
              child: widget.shell,
            ),
          ),
          bottomNavigationBar: FloatingGlassDock(
            currentIndex: widget.shell.currentIndex,
            onDestinationSelected: (int index) => widget.shell.goBranch(index),
            onQuickAdd: () => UniversalQuickAdd.show(
              context,
              initialTab: _quickAddTabs[widget.shell.currentIndex],
            ),
          ),
        );
      },
    );
  }
}
