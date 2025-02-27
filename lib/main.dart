import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_leafguard/theme/theme.dart';
import 'package:ui_leafguard/theme/theme_provider.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xweiounkhqtchlapjazt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh3ZWlvdW5raHF0Y2hsYXBqYXp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzNzU2NDMsImV4cCI6MjA0Njk1MTY0M30.4uHffEjSZ6_vS5hXRlKhV0MWKErPMidtAxMyMD7OZtE',
  );

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          routerConfig: Routes.routerConfiguration(showOnboarding: showOnboarding),
        );
      },
    );
  }
}