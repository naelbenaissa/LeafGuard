import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_leafguard/theme/theme_provider.dart';

void main() {
  // Initialise les bindings nécessaires pour les tests Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      // Mock des valeurs initiales de SharedPreferences pour les tests
      SharedPreferences.setMockInitialValues({
        'isDarkMode': false,           // Thème initial light
        'onboarding_complete': false,  // Onboarding non terminé
      });

      // Instanciation du ThemeProvider avant chaque test
      themeProvider = ThemeProvider();
    });

    test('valeur initiale est ThemeMode.light et onboarding false', () async {
      // Attend la fin du chargement asynchrone du constructeur (_loadPreferences)
      await Future.delayed(const Duration(milliseconds: 100));

      // Vérifie que le thème par défaut est light
      expect(themeProvider.themeMode, ThemeMode.light);

      // Vérifie que l'onboarding n'est pas complété initialement
      expect(themeProvider.onboardingComplete, false);
    });

    test('toggleTheme change theme de light à dark et set onboarding', () async {
      // Attend la fin du chargement initial
      await Future.delayed(const Duration(milliseconds: 100));

      // Change le thème (toggle) : light -> dark et complète onboarding
      themeProvider.toggleTheme();

      // Attend les futures async pour que toggleTheme termine ses opérations
      await Future.delayed(const Duration(milliseconds: 100));

      // Vérifie que le thème est bien passé à dark
      expect(themeProvider.themeMode, ThemeMode.dark);

      // Vérifie que l'onboarding est maintenant complété
      expect(themeProvider.onboardingComplete, true);

      // Récupère SharedPreferences pour vérifier la persistance des valeurs
      final prefs = await SharedPreferences.getInstance();

      // Vérifie que 'isDarkMode' est bien true en mémoire
      expect(prefs.getBool('isDarkMode'), true);

      // Vérifie que 'onboarding_complete' est bien true en mémoire
      expect(prefs.getBool('onboarding_complete'), true);
    });

    test('toggleTheme change theme de dark à light sans changer onboarding', () async {
      // Change la valeur mockée pour simuler un thème dark et onboarding complété
      SharedPreferences.setMockInitialValues({
        'isDarkMode': true,
        'onboarding_complete': true,
      });

      // Réinstancie le ThemeProvider avec ces nouvelles valeurs
      themeProvider = ThemeProvider();

      // Attend le chargement async
      await Future.delayed(const Duration(milliseconds: 100));

      // Vérifie que le thème est bien dark et onboarding complété
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(themeProvider.onboardingComplete, true);

      // Change le thème : dark -> light
      themeProvider.toggleTheme();

      // Attend la fin des opérations async
      await Future.delayed(const Duration(milliseconds: 100));

      // Vérifie que le thème est bien passé à light
      expect(themeProvider.themeMode, ThemeMode.light);

      // Vérifie que l'onboarding reste complété (ne change pas)
      expect(themeProvider.onboardingComplete, true);

      // Vérifie la persistance dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), false);
      expect(prefs.getBool('onboarding_complete'), true);
    });
  });
}
