import 'package:go_router/go_router.dart';
import 'package:ui_leafguard/views/account/account.dart';
import 'package:ui_leafguard/views/plant_guide/plant_guide.dart';
import '../views/home/home.dart';

class Routes {
  static GoRouter routerConfiguration() {
    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const Home(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const Home()),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const Home(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const Home()),
        ),
        GoRoute(
          path: '/camera',
          builder: (context, state) => const Home(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const Home()),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const Home(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const Home()),
        ),
        GoRoute(
          path: '/plantsguide',
          builder: (context, state) => const PlantGuide(),
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const PlantGuide()),
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
