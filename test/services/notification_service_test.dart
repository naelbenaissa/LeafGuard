import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ui_leafguard/services/notification_service.dart';
import '../mocks/mock_notification_plugin.mocks.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService notificationService;

  setUp(() {
    tz.initializeTimeZones();
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService.test(mockPlugin);
  });

  test('Schedule notification calls zonedSchedule correctly', () async {
    when(mockPlugin.zonedSchedule(
      any, any, any, any, any,
      matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      androidScheduleMode: anyNamed('androidScheduleMode'),
    )).thenAnswer((_) async {});

    await notificationService.scheduleNotificationForTask(
      id: 1,
      title: 'Test',
      body: 'Notification test',
      date: DateTime.now().add(const Duration(minutes: 5)),
    );

    when(mockPlugin.zonedSchedule(
      any, any, any, any, any,
      matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      androidScheduleMode: anyNamed('androidScheduleMode'),
    )).thenAnswer((_) async {});

  });

  test('Cancel all notifications calls cancelAll', () async {
    when(mockPlugin.cancelAll()).thenAnswer((_) async {});
    await notificationService.cancelAllNotifications();
    verify(mockPlugin.cancelAll()).called(1);
  });

  test('Cancel a specific notification calls cancel', () async {
    when(mockPlugin.cancel(any)).thenAnswer((_) async {});
    await notificationService.cancelNotification(1);
    verify(mockPlugin.cancel(1)).called(1);
  });
}
