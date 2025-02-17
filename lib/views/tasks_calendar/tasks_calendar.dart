import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/views/tasks_calendar/appbar/tasksCalendar_appbar.dart';
import '../bar/custom_bottombar.dart';
import '../widgets/task_card.dart';

class TasksCalendarPage extends StatefulWidget {
  const TasksCalendarPage({super.key});

  @override
  _TasksCalendarPageState createState() => _TasksCalendarPageState();
}

class _TasksCalendarPageState extends State<TasksCalendarPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTasks());
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;

    if (user != null) {
      final response = await supabase.from('tasks').select('*').eq('user_id', user.id);

      if (response != null && response.isNotEmpty) {
        Map<DateTime, List<Map<String, dynamic>>> tasksMap = {};
        for (var task in response) {
          DateTime dueDate = DateTime.parse(task['due_date']).toLocal();
          DateTime normalizedDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
          tasksMap.putIfAbsent(normalizedDate, () => []).add(task);
        }
        setState(() {
          _tasksByDate = tasksMap;
          _isLoading = false;
        });
      } else {
        setState(() {
          _tasksByDate = {};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

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
              locale: 'fr_FR',
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
                DateTime normalizedDate = DateTime(day.year, day.month, day.day);
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
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                padding: const EdgeInsets.all(16.0),
                children: (_tasksByDate[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? [])
                    .map((task) => TaskCard(
                  title: task['title'],
                  description: task['description'],
                  priority: task['priority'],
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
