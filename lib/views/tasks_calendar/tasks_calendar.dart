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
  final SupabaseClient supabase = Supabase.instance.client; // Client Supabase pour accès base de données et authentification
  CalendarFormat _calendarFormat = CalendarFormat.month; // Format actuel du calendrier (mois, semaine, etc.)
  DateTime _selectedDay = DateTime.now(); // Jour sélectionné dans le calendrier
  DateTime _focusedDay = DateTime.now(); // Jour sur lequel est centré le calendrier
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {}; // Map des tâches groupées par date normalisée (sans heure)
  bool _isLoading = true; // État pour afficher un loader pendant le chargement des tâches

  @override
  void initState() {
    super.initState();
    // Initialise la localisation pour les dates en français canadien
    initializeDateFormatting('fr_CA', null);
    // Après le rendu initial, lance la récupération des tâches
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTasks());
  }

  /// Fonction pour récupérer les tâches depuis Supabase
  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true); // Affiche le loader

    final user = supabase.auth.currentUser; // Récupère l'utilisateur connecté
    if (user == null) {
      // Si pas connecté, stoppe et cache le loader
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Récupère toutes les tâches associées à l'utilisateur
      final response =
      await supabase.from('tasks').select('*').eq('user_id', user.id);

      Map<DateTime, List<Map<String, dynamic>>> tasksMap = {};
      List<Future<void>> pendingNotifications = [];

      // Annule toutes les notifications précédemment programmées
      await NotificationService().cancelAllNotifications();

      // Pour chaque tâche récupérée
      for (var task in response) {
        if (task['due_date'] == null) continue; // Ignore si pas de date d'échéance

        DateTime dueDate = DateTime.parse(task['due_date']).toLocal(); // Convertit en locale
        // Normalise la date pour n'avoir que jour/mois/année sans l'heure
        DateTime normalizedDate =
        DateTime(dueDate.year, dueDate.month, dueDate.day);
        // Ajoute la tâche dans la map groupée par date
        tasksMap.putIfAbsent(normalizedDate, () => []).add(task);

        // Planifie une notification à 9h le jour de l'échéance
        DateTime nineAM = DateTime(dueDate.year, dueDate.month, dueDate.day, 9);

        int notificationId = task['id'].toString().hashCode;

        // Planifie la notification
        pendingNotifications.add(NotificationService().scheduleNotificationForTask(
          id: notificationId,
          title: task['title'],
          body: task['description'] ?? '',
          date: nineAM,
        ));
      }

      // Attend que toutes les notifications soient programmées
      await Future.wait(pendingNotifications);

      // Met à jour l'état avec les tâches chargées et stop le loader
      setState(() {
        _tasksByDate = tasksMap;
        _isLoading = false;
      });
    } catch (e) {
      // En cas d'erreur, affiche dans la console et stop le loader
      print("Erreur fetchTasks: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcul du padding haut pour éviter la zone de la barre système + appbar
    double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    // Formate la date sélectionnée en format complet localisé (ex : vendredi 24 mai 2025)
    String formattedDate = DateFormat.yMMMMEEEEd('fr_CA').format(_selectedDay);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const TasksCalendarAppBar(), // AppBar personnalisé
      body: Padding(
        padding: EdgeInsets.only(top: topPadding + 16),
        child: Column(
          children: [
            // Titre de la page
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Gérer vos tâches",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // Calendrier interactif TableCalendar
            TableCalendar(
              locale: 'fr_CA',
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mois',
                CalendarFormat.twoWeeks: '2 semaines',
                CalendarFormat.week: 'Semaine',
              },
              // Quand le format change (mois, semaine...)
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              // Jour sélectionné dans le calendrier
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              // Quand un jour est sélectionné
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              // Charge les événements (tâches) pour chaque jour affiché
              eventLoader: (day) {
                DateTime normalizedDate = DateTime(day.year, day.month, day.day);
                return _tasksByDate[normalizedDate] ?? [];
              },
              // Style du calendrier : décoration jour actuel et sélectionné
              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green[300],
                  shape: BoxShape.circle,
                ),
              ),
              // Personnalisation des marqueurs sous chaque jour (petit point)
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 4,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.teal[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            // Ligne du bas avec la date sélectionnée et le bouton pour ajouter une tâche
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
                        color: Colors.green, size: 30),
                    // Ouvre la boîte de dialogue pour créer une tâche, puis rafraîchit la liste
                    onPressed: () =>
                        CreateTask.show(context, () => _fetchTasks()),
                  ),
                ],
              ),
            ),

            // Zone principale listant les tâches du jour sélectionné
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator()) // Loader pendant chargement
                  : Builder(
                builder: (context) {
                  // Liste des tâches du jour sélectionné (ou vide)
                  final dayTasks = _tasksByDate[DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                  )] ??
                      [];

                  if (dayTasks.isEmpty) {
                    // Message si aucune tâche ce jour
                    return const Center(
                      child: Text(
                        "Aucune tâche ce jour",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Liste des cartes représentant les tâches
                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: dayTasks
                        .map((task) => TaskCard(
                      id: task['id'].toString(),
                      title: task['title'],
                      description: task['description'],
                      priority: task['priority'],
                      refreshTasks: _fetchTasks,
                    ))
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
