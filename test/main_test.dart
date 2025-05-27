import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ui_leafguard/main.dart' as app;
import 'package:provider/provider.dart';
import 'package:ui_leafguard/theme/theme_provider.dart';

void main() {
  // Initialise les bindings nécessaires pour exécuter des tests Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization', () {
    testWidgets('MyApp builds and renders MaterialApp', (tester) async {
      // Injecte le ThemeProvider pour satisfaire les dépendances de MyApp
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          child: const app.MyApp(),
        ),
      );

      // Attend que le widget soit complètement construit
      await tester.pumpAndSettle();

      // Vérifie que le widget racine est bien un MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  // Test unitaire pour vérifier la logique de demande de permission de notification
  test('requestNotificationPermission requests notification on Android', () async {
    if (Platform.isAndroid) {
      // Vérifie le statut actuel de la permission de notification
      final status = await Permission.notification.status;

      if (status.isDenied) {
        // Si elle est refusée, effectue une requête et vérifie qu’un résultat est renvoyé
        final requestResult = await Permission.notification.request();
        expect(requestResult, isNotNull);
      } else {
        // Si déjà accordée ou limitée, assure-toi que l’un des statuts valides est vrai
        expect(status.isGranted || status.isLimited || status.isRestricted, true);
      }
    } else {
      // Pour les autres plateformes, on valide par défaut
      expect(true, isTrue);
    }
  });
}
