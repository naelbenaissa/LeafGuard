import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_leafguard/utils/routes.dart';
import 'package:ui_leafguard/views/tutoriel/tutoriel_screen.dart';

void main() {
  // Groupe de tests pour vérifier la configuration des routes
  group('Routes Configuration', () {

    // Test : Vérifie que la route initiale est /onboarding si showOnboarding est vrai
    testWidgets('Initial route is /onboarding if showOnboarding is true', (tester) async {
      // Arrange : configuration du router avec showOnboarding à true
      final router = Routes.routerConfiguration(showOnboarding: true);

      // Act : construction de l'application avec la configuration du routeur
      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ));
      await tester.pumpAndSettle(); // Attendre que l'UI soit stable

      // Assert : vérifier que l'écran d'onboarding est bien affiché
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}
