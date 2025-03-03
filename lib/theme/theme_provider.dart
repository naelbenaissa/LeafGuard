import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _onboardingComplete = false;

  ThemeMode get themeMode => _themeMode;
  bool get onboardingComplete => _onboardingComplete;

  ThemeProvider() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    notifyListeners();
  }

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

  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = true;
    await prefs.setBool('onboarding_complete', true);
    notifyListeners();
  }
}
