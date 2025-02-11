import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ui_leafguard/views/tasks_calendar/appbar/tasksCalendar_appbar.dart';
import '../bar/custom_bottombar.dart';

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

  void _createTask() {
    showDialog(
      context: context,
      builder: (context) {
        String title = "";
        String description = "";
        DateTime selectedDate = DateTime.now();
        String priority = "Faible";

        return AlertDialog(
          title: const Text("Créer une nouvelle tâche"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Titre de la tâche"),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Description"),
                onChanged: (value) => description = value,
              ),
              ListTile(
                title: Text("Date : \${DateFormat.yMMMMd('fr_FR').format(selectedDate)}"),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: "Priorité"),
                items: ["Faible", "Moyen", "Fort"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      priority = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                // Ajouter la logique d'enregistrement ici
                Navigator.of(context).pop();
              },
              child: const Text("Créer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TasksCalendarAppBar(),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding + 16),
        child: SingleChildScrollView(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tâches du ${DateFormat.yMMMMd('fr_FR').format(_selectedDay)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                      onPressed: _createTask,
                    ),
                  ],
                ),
              ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: List.generate(7, (index) => const ListTile(
                  leading: Icon(Icons.task, color: Colors.green),
                  title: Text("Exemple de tâche"),
                )),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
