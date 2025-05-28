import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/account/account.dart';
import 'package:ui_leafguard/views/auth/auth.dart';
import 'package:ui_leafguard/views/camera/camera.dart';
import 'package:ui_leafguard/views/favorites/favorites.dart';
import 'package:ui_leafguard/views/plant_guide/plant_guide.dart';
import 'package:ui_leafguard/views/home/home.dart';
import 'package:ui_leafguard/views/tasks_calendar/tasks_calendar.dart';
import 'package:ui_leafguard/views/tutoriel/tutoriel_screen.dart';

class Routes {
  /// Configure les routes principales de l'application avec une condition d'affichage
  /// de l'écran d'onboarding au lancement.
  static GoRouter routerConfiguration({required bool showOnboarding}) {
    return GoRouter(
      initialLocation: showOnboarding ? '/onboarding' : '/',
      routes: <RouteBase>[
        // Route vers la page d'accueil
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          pageBuilder: (context, state) => NoTransitionPage(child: const HomePage()),
        ),

        // Route vers l'écran d'onboarding
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
          pageBuilder: (context, state) => NoTransitionPage(child: const OnboardingScreen()),
        ),

        // Route vers le calendrier des tâches, accessible uniquement aux utilisateurs authentifiés
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const TasksCalendarPage(),
          pageBuilder: (context, state) => NoTransitionPage(child: const TasksCalendarPage()),
          redirect: (context, state) => isUserAuthenticated() ? null : '/auth',
        ),

        // Route vers la caméra
        GoRoute(
          path: '/camera',
          builder: (context, state) => const CameraPage(),
          pageBuilder: (context, state) => NoTransitionPage(child: const CameraPage()),
        ),

        // Route vers les favoris, accès restreint aux utilisateurs authentifiés
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesPage(),
          pageBuilder: (context, state) => NoTransitionPage(child: const FavoritesPage()),
          redirect: (context, state) => isUserAuthenticated() ? null : '/auth',
        ),

        // Route vers le guide des plantes
        GoRoute(
          path: '/plantsguide',
          builder: (context, state) => const PlantGuidePage(),
          pageBuilder: (context, state) => NoTransitionPage(child: const PlantGuidePage()),
        ),

        // Route vers la page compte, accès restreint
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountPage(),
          pageBuilder: (context, state) => NoTransitionPage(child: const AccountPage()),
          redirect: (context, state) => isUserAuthenticated() ? null : '/auth',
        ),

        // Route vers la page d'authentification
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthPage(),
          pageBuilder: (context, state) => NoTransitionPage(child: const AuthPage()),
        ),
      ],
    );
  }
}

/// Vérifie si un utilisateur est actuellement connecté via Supabase.
bool isUserAuthenticated() {
  final session = Supabase.instance.client.auth.currentSession;
  return session != null;
}

/// Page personnalisée sans animation de transition pour le routage.
class NoTransitionPage extends CustomTransitionPage<void> {
  NoTransitionPage({required super.child}) : super(
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}
