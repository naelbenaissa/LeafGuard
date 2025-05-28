import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Stocke le mode thème actuel (clair ou sombre)
  ThemeMode _themeMode = ThemeMode.light;

  // Indique si l'onboarding a été complété
  bool _onboardingComplete = false;

  ThemeMode get themeMode => _themeMode;
  bool get onboardingComplete => _onboardingComplete;

  // Charge les préférences utilisateur au démarrage
  ThemeProvider() {
    _loadPreferences();
  }

  // Récupère le mode thème et l'état de l'onboarding depuis SharedPreferences
  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    notifyListeners();
  }

  // Change le thème entre clair et sombre, et marque l'onboarding comme terminé si nécessaire
  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);

    if (!_onboardingComplete) {
      _onboardingComplete = true;
      await prefs.setBool('onboarding_complete', true);
    }

    notifyListeners();
  }

  // Marque explicitement l'onboarding comme complété
  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = true;
    await prefs.setBool('onboarding_complete', true);
    notifyListeners();
  }
}
