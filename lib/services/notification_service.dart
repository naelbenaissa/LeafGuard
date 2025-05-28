import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificationService {
  // Singleton instance pour garantir un unique gestionnaire de notifications
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Constructeur privé utilisé pour l'instance singleton
  NotificationService._internal()
      : flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Constructeur dédié pour les tests, permettant l'injection d'un mock
  NotificationService.test(this.flutterLocalNotificationsPlugin);

  /// Initialise le plugin de notifications et demande les permissions nécessaires.
  /// Configure notamment les paramètres Android et iOS.
  Future<void> init() async {
    tzData.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Demande des permissions iOS (alertes, badges, sons)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Planifie une notification locale pour une tâche à une date donnée.
  /// Ignore la programmation si la date est passée.
  Future<void> scheduleNotificationForTask({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    final scheduledDate = tz.TZDateTime.from(date, tz.local);

    // Ne programme pas la notification si la date est déjà passée
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Tâches',
          channelDescription: 'Notifications des tâches à faire',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Annule toutes les notifications programmées
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Annule une notification spécifique par son ID
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
