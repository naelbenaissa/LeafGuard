import 'package:go_router/go_router.dart';

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
        // GoRoute(
        //   path: '/menuHebdo',
        //   builder: (context, state) => const MenuHebdo(),
        //   pageBuilder: (context, state) =>
        //       NoTransitionPage(child: const MenuHebdo()),
        // ),é
        // GoRoute(
        //   path: '/detail/:jour/:semaine/:annee',
        //   builder: (context, state) {
        //     final jour = state.pathParameters['jour']!;
        //     final semaine = state.pathParameters['semaine']!;
        //     final annee = state.pathParameters['annee']!;
        //     return DetailMenu(
        //       jour: jour,
        //       semaine: semaine,
        //       annee: annee,
        //     );
        //   },
        // ),
      ],
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
