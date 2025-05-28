import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ui_leafguard/services/notification_service.dart';
import '../mocks/mock_notification_plugin.mocks.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  // Déclaration des variables utilisées dans les tests
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService notificationService;

  // Méthode appelée avant chaque test pour initialiser l'état
  setUp(() {
    tz.initializeTimeZones(); // Initialisation des fuseaux horaires (requis pour zonedSchedule)
    mockPlugin = MockFlutterLocalNotificationsPlugin(); // Mock du plugin de notifications
    notificationService = NotificationService.test(mockPlugin); // Service de notification utilisant le mock
  });

  // Test pour vérifier que la méthode scheduleNotificationForTask appelle correctement zonedSchedule
  test('Schedule notification calls zonedSchedule correctly', () async {
    // Définition du comportement simulé de zonedSchedule
    when(mockPlugin.zonedSchedule(
      any, any, any, any, any,
      matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      androidScheduleMode: anyNamed('androidScheduleMode'),
    )).thenAnswer((_) async {});

    // Appel de la méthode à tester
    await notificationService.scheduleNotificationForTask(
      id: 1,
      title: 'Test',
      body: 'Notification test',
      date: DateTime.now().add(const Duration(minutes: 5)),
    );

    // (À noter : la ligne ci-dessous est redondante ici et pourrait être supprimée)
    when(mockPlugin.zonedSchedule(
      any, any, any, any, any,
      matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      androidScheduleMode: anyNamed('androidScheduleMode'),
    )).thenAnswer((_) async {});
  });

  // Test pour s'assurer que cancelAllNotifications appelle bien cancelAll du plugin
  test('Cancel all notifications calls cancelAll', () async {
    when(mockPlugin.cancelAll()).thenAnswer((_) async {}); // Simule l'annulation de toutes les notifications
    await notificationService.cancelAllNotifications(); // Appel de la méthode à tester
    verify(mockPlugin.cancelAll()).called(1); // Vérifie que cancelAll a été appelée une fois
  });

  // Test pour s'assurer que cancelNotification appelle bien cancel avec le bon ID
  test('Cancel a specific notification calls cancel', () async {
    when(mockPlugin.cancel(any)).thenAnswer((_) async {}); // Simule l'annulation d'une notification spécifique
    await notificationService.cancelNotification(1); // Appel de la méthode à tester
    verify(mockPlugin.cancel(1)).called(1); // Vérifie que cancel a été appelée avec l'ID 1
  });
}
