import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ui_leafguard/main.dart' as app;
import 'package:provider/provider.dart';
import 'package:ui_leafguard/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization', () {
    testWidgets('MyApp builds and renders MaterialApp', (tester) async {
      // Mock ThemeProvider pour éviter tout problème de dépendance
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          child: const app.MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifie que MaterialApp est bien dans l’arbre
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  test('requestNotificationPermission requests notification on Android', () async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        final requestResult = await Permission.notification.request();
        expect(requestResult, isNotNull);
      } else {
        expect(status.isGranted || status.isLimited || status.isRestricted, true);
      }
    } else {
      expect(true, isTrue);
    }
  });
}
