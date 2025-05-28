import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/theme/theme.dart';
import 'package:ui_leafguard/theme/theme_provider.dart';
import 'utils/routes.dart';
import 'package:ui_leafguard/services/notification_service.dart';

/// Demande la permission de notifications sur Android si elle n'est pas encore accordée.
Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
}

/// Initialise les services nécessaires au démarrage de l'application.
/// Ici, initialisation des notifications puis demande de permissions.
Future<void> initializeApp() async {
  await NotificationService().init();
  await requestNotificationPermission();
}

void main() async {
  // Assure que les bindings Flutter sont initialisés avant d'exécuter du code async.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Supabase avec l'URL et la clé anonyme de ton projet.
  await Supabase.initialize(
    url: 'https://xweiounkhqtchlapjazt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh3ZWlvdW5raHF0Y2hsYXBqYXp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzNzU2NDMsImV4cCI6MjA0Njk1MTY0M30.4uHffEjSZ6_vS5hXRlKhV0MWKErPMidtAxMyMD7OZtE',
  );

  // Exécution des initialisations complémentaires
  await initializeApp();

  // Lancement de l'application avec un provider pour gérer le thème.
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

/// Widget racine de l'application, écoute les changements de thème via le provider.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          // Thème clair par défaut
          theme: AppTheme.lightTheme,
          // Thème sombre
          darkTheme: AppTheme.darkTheme,
          // Mode thème sélectionné dynamiquement par le provider
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          // Configuration des routes avec condition d'affichage de l'onboarding
          routerConfig: Routes.routerConfiguration(showOnboarding: !themeProvider.onboardingComplete),
        );
      },
    );
  }
}
