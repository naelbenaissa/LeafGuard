import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../home/bar/custom_appbar.dart';
import '../home/bar/custom_bottombar.dart';

class TasksCalendarPage extends StatefulWidget {
  const TasksCalendarPage({super.key});

  @override
  _TasksCalendarPageState createState() => _TasksCalendarPageState();
}

class _TasksCalendarPageState extends State<TasksCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(scrollController: ScrollController()),
      body: Column(
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
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
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
          Text(
            "Tâches du ${DateFormat.yMMMMd('fr_FR').format(_selectedDay)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                children: const [
                  ListTile(
                    leading: Icon(Icons.task, color: Colors.green),
                    title: Text("Exemple de tâche 1"),
                  ),
                  ListTile(
                    leading: Icon(Icons.task, color: Colors.green),
                    title: Text("Exemple de tâche 2"),
                  ),
                  ListTile(
                    leading: Icon(Icons.task, color: Colors.green),
                    title: Text("Exemple de tâche 2"),
                  ),
                  ListTile(
                    leading: Icon(Icons.task, color: Colors.green),
                    title: Text("Exemple de tâche 2"),
                  ),
                  ListTile(
                    leading: Icon(Icons.task, color: Colors.green),
                    title: Text("Exemple de tâche 2"),
                  ),
                  ListTile(
                    leading: Icon(Icons.task, color: Colors.green),
                    title: Text("Exemple de tâche 2"),
                  ),
                  ListTile(
                    leading: Icon(Icons.task, color: Colors.green),
                    title: Text("Exemple de tâche 2"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
