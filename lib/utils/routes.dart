import 'package:go_router/go_router.dart';
import 'package:ui_leafguard/views/account/account.dart';
import 'package:ui_leafguard/views/favorites/favorites.dart';
import 'package:ui_leafguard/views/plant_guide/plant_guide.dart';
import '../views/home/home.dart';
import '../views/tasks_calendar/tasks_calendar.dart';

class Routes {
  static GoRouter routerConfiguration() {
    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const HomePage()),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const TasksCalendarPage(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const TasksCalendarPage()),
        ),
        GoRoute(
          path: '/camera',
          builder: (context, state) => const HomePage(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const HomePage()),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesPage(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const FavoritesPage()),
        ),
        GoRoute(
          path: '/plantsguide',
          builder: (context, state) => const PlantGuidePage(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const PlantGuidePage()),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountPage(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const AccountPage()),
        ),],
    );
  }
}

class NoTransitionPage extends CustomTransitionPage<void> {
  NoTransitionPage({required super.child})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}
