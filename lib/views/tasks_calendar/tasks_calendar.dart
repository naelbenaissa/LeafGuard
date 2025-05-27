import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/tasks_calendar/appbar/tasks_calendar_appbar.dart';
import 'package:ui_leafguard/views/tasks_calendar/widgets/dialog/create_task_dialog.dart';
import '../../services/notification_service.dart';
import '../bar/custom_bottombar.dart';
import '../widgets/task_card.dart';

class TasksCalendarPage extends StatefulWidget {
  const TasksCalendarPage({super.key});

  @override
  _TasksCalendarPageState createState() => _TasksCalendarPageState();
}

class _TasksCalendarPageState extends State<TasksCalendarPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_CA', null);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTasks());
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);

    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response =
      await supabase.from('tasks').select('*').eq('user_id', user.id);

      Map<DateTime, List<Map<String, dynamic>>> tasksMap = {};
      List<Future<void>> pendingNotifications = [];

      await NotificationService().cancelAllNotifications();

      for (var task in response) {
        if (task['due_date'] == null) continue;

        DateTime dueDate = DateTime.parse(task['due_date']).toLocal();
        DateTime normalizedDate =
        DateTime(dueDate.year, dueDate.month, dueDate.day);
        tasksMap.putIfAbsent(normalizedDate, () => []).add(task);

        DateTime nineAM = DateTime(dueDate.year, dueDate.month, dueDate.day, 9);

        int notificationId = task['id'].toString().hashCode;

        await NotificationService().scheduleNotificationForTask(
          id: notificationId,
          title: task['title'],
          body: task['description'] ?? '',
          date: nineAM,
        );
      }

      // Attend la planification de toutes les notifications en parallèle
      await Future.wait(pendingNotifications);

      setState(() {
        _tasksByDate = tasksMap;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur fetchTasks: $e");
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    String formattedDate = DateFormat.yMMMMEEEEd('fr_CA').format(_selectedDay);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TasksCalendarAppBar(),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding + 16),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Gérer vos tâches",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            TableCalendar(
              locale: 'fr_CA',
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                DateTime normalizedDate =
                    DateTime(day.year, day.month, day.day);
                return _tasksByDate[normalizedDate] ?? [];
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.blue, size: 30),
                    onPressed: () =>
                        CreateTask.show(context, () => _fetchTasks()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: (_tasksByDate[DateTime(_selectedDay.year,
                                  _selectedDay.month, _selectedDay.day)] ??
                              [])
                          .map((task) => TaskCard(
                                id: task['id'].toString(),
                                title: task['title'],
                                description: task['description'],
                                priority: task['priority'],
                                refreshTasks: _fetchTasks,
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}