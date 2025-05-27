import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_leafguard/utils/routes.dart';
import 'package:ui_leafguard/views/tutoriel/tutoriel_screen.dart';

void main() {
  group('Routes Configuration', () {
    testWidgets('Initial route is /onboarding if showOnboarding is true', (tester) async {
      final router = Routes.routerConfiguration(showOnboarding: true);
      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}
